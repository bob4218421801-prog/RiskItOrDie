extends RefCounted
# Data-only binary snapshots. Never deserialize objects or paths supplied by a save file.
const TYPES = {
 "story_duel.gd": preload("res://scripts/story_duel.gd"),
 "sect_state.gd": preload("res://scripts/sect_state.gd"),
 "sicbo_state.gd": preload("res://scripts/sicbo_state.gd"),
 "blood_state.gd": preload("res://scripts/blood_state.gd"),
 "tournament_state.gd": preload("res://scripts/tournament_state.gd"),
 "duel_state.gd": preload("res://scripts/duel_state.gd"),
 "alchemy_state.gd": preload("res://scripts/alchemy_state.gd"),
 "stone_state.gd": preload("res://scripts/stone_state.gd"),
 "spirit_boat.gd": preload("res://scripts/spirit_boat.gd"),
 "sword_race.gd": preload("res://scripts/sword_race.gd"),
 "mines_state.gd": preload("res://scripts/mines_state.gd"),
 "foundation_state.gd": preload("res://scripts/foundation_state.gd")}
const SKIP = ["persistence_path","developer_test_session","overrides","force","master_clicks","master_click_attempt","master_click_age"]
static func encode(value: Variant) -> Variant:
 if value is RandomNumberGenerator: return {"rng_state":str(value.state),"rng_seed":str(value.seed)}
 if value is RefCounted:
  var fields := {}
  for property in value.get_property_list():
   if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and property.name not in SKIP:
    fields[property.name] = encode(value.get(property.name))
    if property.name == "pool_bags":
     fields[property.name] = fields[property.name].duplicate(true)
     for key in fields[property.name].keys():
      if str(key).begins_with("master_"): fields[property.name].erase(key)
  return {"type":value.get_script().resource_path.get_file(),"fields":fields}
 return value
static func fill(object: RefCounted, fields: Dictionary, merge_defaults: bool=true):
 for property in object.get_property_list():
  var key: String = property.name
  if not property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE or key in SKIP or not fields.has(key): continue
  var value: Variant = fields[key]
  if value is Dictionary and value.has("rng_state"):
   var generator := RandomNumberGenerator.new()
   generator.seed = int(value.rng_seed)
   generator.state = int(value.rng_state)
   object.set(key,generator)
  elif value is Dictionary and value.has("type") and TYPES.has(value.type):
   var child: RefCounted = TYPES[value.type].new()
   fill(child,value.fields)
   object.set(key,child)
  elif value is Array and object.get(key) is Array: object.get(key).assign(value)
  elif value is Dictionary and object.get(key) is Dictionary:
   var merged: Dictionary=object.get(key).duplicate(true) if merge_defaults else {};merged.merge(value,true);object.set(key,merged)
  else: object.set(key,value)
static func save_run(model: RefCounted, path: String) -> bool:
 return preload("res://scripts/save_archive.gd").write(encode(model).fields,path)
static func load_run(model: RefCounted, path: String) -> bool:
 var data: Dictionary=preload("res://scripts/save_archive.gd").load_fields(path)
 if not data.ok: return false
 var fields: Dictionary=data.fields
 var fresh: RefCounted=model.get_script().new()
 fill(fresh,fields)
 fill(model,encode(fresh).fields,false)
 # Extend an existing board without refreshing or restoring spent invitations.
 if not model.board.is_empty() and not model.board[0].has("npc_id"):
  for i in range(model.board.size()): model.board[i]["npc_id"]=[0,1,2,3][clampi(model.board[i].archetype,0,3)]
  for i in range(model.board.size(),model.NPC.NPCS.size()): model.board.append({"npc_id":i,"archetype":model.NPC.NPCS[i].economy,"used":false})
 # Repair older saves written after the lesson without the location unlock.
 if model.sect.duel_taught and not model.sect.junior_met:
  model.sect.junior_met=true;model.sect.away["小師妹"]=0;model.sect.seen["junior_intro"]=true;model.sect.pending.erase("junior_intro")
 if not fields.has("first_rebirth_complete"): model.first_rebirth_complete = model.rebirths > 0 or model.realm >= model.C.FOUNDATION_REALM
 if not fields.has("sect"):
  model.sect.intro_done = true
  model.sect.stipend_cursor = model.age
  model.sect.tianji_seen = int(floor(model.world_year()/model.P.TIANJI_INTERVAL))*model.P.TIANJI_INTERVAL
  for key in ["success","failure","rebirth"]: model.sect.seen[key] = true
  model.blood_threshold = model.blood_counter+model.blood_schedule_rng.randi_range(45,70)
 # An already-running old five-match bracket finishes under its saved rules.
 if model.tournament != null and not fields.get("tournament",{}).get("fields",{}).has("legacy_five"):
  model.tournament.legacy_five = true
 if model.sect.inventory.get("天機券",0) > 0: model.sect.pavilion_unlocked = true
 if not fields.has("entry_shares"):
  model.entry_shares = 1
  if model.activity_id in model.E.TICKETS and not model.entry_paid: model.reset_stake(model.activity_id)
 # Upgrade old long passive schedules once; preserve counters and pending invitations.
 if fields.get("duel_schedule_version",0) < 2:
  model.duel_schedule_version = 2
  model.first_passive_seen = model.duel_count > 0
  var interval = model.D.INTERVAL if model.first_passive_seen else model.D.FIRST_INTERVAL
  model.duel_threshold = mini(model.duel_threshold,model.economy_rng.randi_range(interval[0],interval[1]))
  if model.sect.duel_taught and model.duel_counter >= model.duel_threshold: model.duel_due = true
 if not model.sect.duel_taught and model.realm >= 10 and not model.sect.foundation_started:
  model.sect.foundation_started = true
  model.sect.junior_duel_due_attempt = model.attempts+model.sect.rng.randi_range(3,5)
 # Completed legacy foundations retain their grade and original multiplier table.
 if model.foundation_grade > 0:
  model.foundation_completed = true
  model.foundation_multiplier = model.C.foundation_modifier(model.foundation_grade)
  if model.dao_foundation_type.is_empty(): model.dao_foundation_type = "legacy"
 elif model.foundation != null and not fields.get("foundation",{}).get("fields",{}).has("version"):
  model.foundation = TYPES["foundation_state.gd"].new()
  model.foundation_seen = 0
  model.state = "foundation"
  model.modal.clear();model.pending_result.clear();model.result_delay = 0
 model.overrides.clear()
 if model.duel != null and model.duel.active_challenge: model.duel.source = "active"
 if model.tournament != null and model.tournament.stage == "fighting" and model.duel != null: model.duel.source = "tournament"
 # Older saves kept paid duel results on the battlefield without a return modal.
 # Migrate presentation only: never call finish_duel or award the result again.
 if model.activity_id == "duel" and model.duel != null:
  var d: RefCounted = model.duel
  if d.story_mode.is_empty() and d.state == "playing" and d.player == 21: d.peak()
  if d.state in ["natural_wait","natural_glow"] and d.natural_return == "playing": d.natural_return = "auto_stand"
  if d.state == "result" and d.paid_out:
   if model.tournament != null and model.tournament.stage != "done": d.source = "tournament"
   if not model.modal.has("route") and not model.pending_result.has("route"):
    if model.modal.get("kind","") == "result":
     model.pending_result = model.modal.duplicate();model.modal.clear()
    elif model.pending_result.is_empty():
     model.queue_result("問劍告捷" if d.score[0] >= 3 else "問劍已了",d.message,"collect")
    model.set_duel_result_route()
   d.message = ""
 if model.sect.senior_lesson_complete: model.sect.probe_learned = true
 if model.duel != null and model.duel.source == "tournament":
  model.duel.fair = true;model.duel.peeked = false;model.duel.player_level = 0;model.duel.card_enabled.clear()
 elif model.duel != null:
  model.duel.player_level = model.realm
  if model.duel.story_mode.is_empty() and model.sect.probe_learned:
   model.duel.learned_probe = true;model.duel.peeked = true
 if model.tournament != null and model.tournament.paid and model.tournament.reward_text.is_empty(): model.tournament.reward_text = "本屆獎勵已收入行囊。"
 # Displayed unlocks never replay; all other gameplay state is resumed coherently.
 if model.modal.get("kind","") == "unlock": model.modal.clear()
 for key in ["duel","alchemy","foundation","blood"]:
  var child: Variant = model.get(key)
  if child != null: child.cue.connect(model._foundation_cue)
 # A physical hold cannot survive a process restart. Resume safely without a stuck input.
 if model.foundation != null: model.foundation.release_hold()
 if model.alchemy != null: model.alchemy.release_fire()
 if model.state == "holding": model.focus_paused = true

 return true
