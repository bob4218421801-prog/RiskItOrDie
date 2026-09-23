extends RefCounted
const M = preload("res://scripts/master_dialogue.gd")
var master_last_visit := -1
var master_clicks := 0
var master_click_attempt := -1
var master_click_age := -1.0
var master_risk_streak := 0
var junior_visit_count := 0
const L = preload("res://scripts/dialogue_content.gd")
var foundation_attempts := 0
var foundation_started := false
var duel_taught := false
var junior_duel_due_attempt := -1
var senior_lesson_complete := false
var probe_learned := false
var pavilion_unlocked := false
var dialogue_rng := RandomNumberGenerator.new()
var pool_last: Dictionary = {}
var junior_spar_visits := 0
var jade_visits := 0
var pool_bags := {}
var recent_dialogues: Array[String] = []
var dialogue_seen := {}
var context_seen := {}
var context_cooldowns := {}
var chat := {}
var festival_visits := 0
var festival_result := -1
var festival_serial := 0
var runner_up_seen := false
var duel_streak := 0
var last_duel_attempt := -100
var last_cultivation := ""
var last_cultivation_attempt := -100
var sicbo_lost := false
const C = preload("res://scripts/sect_config.gd")
var rng := RandomNumberGenerator.new()
var intro_done := false
var seen: Dictionary = {}
var pending: Array[String] = []
var junior_count := 0
var junior_threshold := 0
var junior_met := false
var senior_met := false
var senior_defeated := false
var senior_realm_seen := 11
var affection := 0
var last_interaction := -100
var reaction := ""
var away := {"師父":0,"小師妹":0,"大師姐":0}
var away_reason := {}
var returned := ""
var stipend_cursor := 16.0
var stipends: Array[int] = []
var stipend_bonus := false
var inventory: Dictionary = {}
var card_choices := 0
var sicbo_seen := false
var tianji_seen := 725
var tianji_pending := 0
var offer_kind := "sect"
var event_until := 0
var player_demonic_wins:=0
var demonic_encounters:=0
var blood_title := ""
var blood_name := ""
var blood_elite := false
var last_blood_serial := -1
var blood_long_seen := false
func _init():
 dialogue_rng.randomize();rng.randomize();junior_threshold = rng.randi_range(C.JUNIOR_INTERVAL[0],C.JUNIOR_INTERVAL[1])
 for key in C.CARDS+C.RELICS.keys()+["天機券","金丹神通體驗券"]: inventory[key] = 0
func grant(key: String, amount: int = 1):
 inventory[key] = inventory.get(key,0)+amount
 if key == "天機券" and amount > 0: pavilion_unlocked = true
func consume(key: String) -> bool:
 if inventory.get(key,0) <= 0: return false
 inventory[key] -= 1;return true
func stage() -> String:
 var index := 0
 for i in range(C.AFFECTION_STAGES.size()):
  if affection >= C.AFFECTION_STAGES[i]: index = i
 return C.AFFECTION_NAMES[index]
func present(npc: String, attempts: int) -> bool: return away.get(npc,0) <= attempts
func interaction(m):
 if m.attempts-last_interaction < C.AFFECTION_INTERVAL: return
 affection += 1;last_interaction = m.attempts
func tick(m):
 if m.realm >= 10 and not foundation_started:
  foundation_started = true;foundation_attempts = 0
  junior_duel_due_attempt = m.attempts+rng.randi_range(C.JUNIOR_DUEL_DELAY[0],C.JUNIOR_DUEL_DELAY[1])
 if m.realm >= 10 and junior_met and not duel_taught and not seen.has("junior_duel_intro"):
  if m.attempts >= junior_duel_due_attempt and "junior_duel_intro" not in pending: pending.push_front("junior_duel_intro")
 if m.realm >= 12 and duel_taught and not senior_lesson_complete and "senior_lesson_intro" not in pending and not seen.has("senior_lesson_intro"): pending.push_front("senior_lesson_intro")
 var periods := int(floor((m.age-stipend_cursor+.00001)/C.STIPEND_YEARS))
 if periods > 0:
  stipend_cursor += periods*C.STIPEND_YEARS
  var amount := int(C.STIPEND[1 if m.realm >= 10 else 0]*(1+C.STIPEND_BONUS if stipend_bonus else 1.0))
  for i in range(mini(periods,C.STIPEND_CAP-stipends.size())): stipends.append(amount)
 if m.challenges_enabled:
  var cycle: int = int(floor((m.world_year()+.000001)/m.P.TIANJI_INTERVAL))*m.P.TIANJI_INTERVAL
  if cycle > tianji_seen:
   tianji_seen = cycle
   if m.realm >= 10: tianji_pending = cycle;pavilion_unlocked = true
func completed(m, outcome: String):
 last_cultivation = outcome;last_cultivation_attempt = m.attempts
 if m.realm >= 10 and foundation_started: foundation_attempts += 1
 master_risk_streak = master_risk_streak+1 if m.risk >= .85 else 0
 if m.realm >= 10 and not junior_met:
  junior_count += 1
  if junior_count >= 1 and "junior_intro" not in pending: pending.push_front("junior_intro")

 if not seen.has(outcome) and outcome in ["success","failure","rebirth"] and outcome not in pending: pending.append(outcome)
 if outcome in ["failure","rebirth"]: reaction = outcome
 for npc in away:
  if away[npc] > 0 and away[npc] <= m.attempts: away[npc] = 0;returned = npc+"回來了"
 if m.attempts%C.ABSENCE_INTERVAL == 0:
  var npc: String = ["師父","小師妹","大師姐"][rng.randi_range(0,2)]
  away[npc] = m.attempts+rng.randi_range(C.ABSENCE_LENGTH[0],C.ABSENCE_LENGTH[1])
  var reasons: Array = {"師父":["外出訪友","閉關授法","處理宗門事務"],"小師妹":["被師父叫去修煉","下山買東西","去丹堂幫忙"],"大師姐":["下山問劍","獨自閉關","出門辦事"]}[npc]
  away_reason[npc] = reasons[rng.randi_range(0,reasons.size()-1)]
func safe(m) -> bool:
 return m.state == "idle" and m.activity_id.is_empty() and m.pending_activity.is_empty() and m.modal.is_empty() and m.result_delay <= 0
func offer_story(m) -> bool:
 if not m.tutorials_enabled or not safe(m) or not m.unlock_queue.is_empty(): return false
 if not intro_done:
  story(m,"opening");return true
 if pending.is_empty(): return false
 var id: String = pending.pop_front()
 if seen.has(id): return false
 if id in ["success","failure","rebirth"]: away["師父"] = 0
 if id == "junior_intro": junior_met = true;away["小師妹"] = 0
 if id == "senior_intro": senior_met = true;away["大師姐"] = 0
 if id == "junior_duel_intro":
  junior_met = true;away["小師妹"] = 0;pending.erase("junior_intro")
  story(m,id,[["小師妹","師兄，我聽他們說，築基修士之間經常會互相問劍。"],["小師妹","你先別急著去跟外面的人打。"],["小師妹","陪我走幾局，先把規矩摸熟再說。"]])
 elif id == "senior_lesson_intro":
  senior_met = true;away["大師姐"] = 0;story(m,id,L.SENIOR_INTRO)
 else: story(m,id)
 return true
func story(m, id: String, custom: Array = []):
 if not m.modal.is_empty(): return
 seen[id] = true
 var lines: Array = custom if not custom.is_empty() else C.STORIES.get(id,[])
 if lines.is_empty(): return
 m.modal = {"kind":"dialogue","id":id,"lines":lines.duplicate(true),"index":0,"title":lines[0][0],"text":lines[0][1]}
 m.sfx_event.emit("stop_all")
 m.save_session()
func next_dialogue(m, choice: int = 0):
 var id: String = m.modal.id
 if id == "junior_close":
  m.modal.clear()
  story(m,"junior_reply",[["小師妹","……哦。\n那你站那麼遠幹嘛？" if choice == 1 else "你怎麼每次來都先看我有沒有帶玉骨？"]]);return
 var index: int = m.modal.index+1
 if index < m.modal.lines.size():
  m.modal.index = index;m.modal.title = m.modal.lines[index][0];m.modal.text = m.modal.lines[index][1]
 else:
  m.modal.clear();event_until = m.attempts+C.EVENT_GAP
  if id == "opening": intro_done = true
  elif id == "junior_intro": start_jade(m)
  elif id == "junior_duel_intro": start_lesson(m,"junior")
  elif id in ["junior_spar_open","senior_spar_open"]: m.duel.accept()
  elif id in ["senior_intro","senior_lesson_intro"]: start_lesson(m,"senior")
  elif id == "senior_reunion": start_senior(m)
  elif id == "senior_post":
   probe_learned = true;senior_lesson_complete = true;m.unlock_notified.erase("skill0");m.check_unlocks();m.save_session()
  elif id == "runner_up": runner_up_seen = true
  elif id == "junior_gift": grant("天命劍符")
  elif id == "senior_win": grant("回天玉符")
  elif id == "sicbo_intro":
   m.sicbo = preload("res://scripts/sicbo_state.gd").new();m.sicbo.start(true)
  elif id == "sicbo_after": m.sicbo = preload("res://scripts/sicbo_state.gd").new()
 m.save_session()
func talk(m, npc: String):
 if m.activity_id != "sect" or not m.modal.is_empty(): return
 if not chat.is_empty(): next_chat(m);return
 if npc == "小師妹":
  var event := "junior_gift" if affection >= C.AFFECTION_STAGES[2] and not seen.has("junior_gift") else ("junior_close" if affection >= C.AFFECTION_STAGES[1] and not seen.has("junior_close") else "")
  if not event.is_empty(): away[npc] = 0;story(m,event);return
 if not present(npc,m.attempts): return
 if npc == "師父":
  talk_master(m);return
 var prefix := "junior" if npc == "小師妹" else "senior"
 if prefix == "junior": interaction(m);junior_visit_count += 1
 if npc == "大師姐" and senior_lesson_complete and m.realm > senior_realm_seen and m.realm in C.SENIOR_REALM:
  senior_realm_seen = m.realm
  if m.realm == 16: story(m,"senior_reunion",[[npc,"終於到了。"],["你","築基七層。"],[npc,"我知道。\n所以今天不讓你了。"]]);return
  begin_chat(m,npc,C.SENIOR_REALM[m.realm],"realm"+str(m.realm));return
 var context := context_for(m,prefix)
 if not context.is_empty():
  var key: String = prefix+context.id
  begin_chat(m,npc,context.text,key);chat["context_stamp"] = context.stamp;m.save_session();return
 var pool: String = prefix+"_daily"
 var index := pick(pool,m)
 begin_chat(m,npc,L.POOLS[pool][index],pool+str(index))
func context_for(m, prefix: String) -> Dictionary:
 var possibilities: Array = []
 if last_cultivation in ["failure","rebirth"] and m.attempts-last_cultivation_attempt <= 8:
  var index := (0 if last_cultivation == "failure" else 1) if prefix == "junior" else (2 if last_cultivation == "failure" else 3)
  possibilities.append({"id":"cultivation","stamp":last_cultivation_attempt,"text":L.POOLS[prefix+"_context"][index]})
 if festival_result >= 0:
  if prefix == "senior" and festival_result == 3:
   possibilities.append({"id":"runner","stamp":festival_serial,"text":L.POOLS.senior_context[4]})
  var pool := prefix+"_result"+str(festival_result)
  if context_seen.get(prefix+"festival",-1) != festival_serial:
   possibilities.append({"id":"festival","stamp":festival_serial,"pool":pool})
  elif context_seen.get(prefix+"champion",-1) != festival_serial:
   pool = prefix+"_champion"
   possibilities.append({"id":"champion","stamp":festival_serial,"pool":pool})
 if m.attempts-last_duel_attempt <= 8 and duel_streak != 0:
  var index := (3 if duel_streak > 0 else 2) if prefix == "junior" else (1 if duel_streak > 0 else 0)
  possibilities.append({"id":"duel","stamp":last_duel_attempt,"text":L.POOLS[prefix+"_context"][index]})
 if m.requirement() > 0 and m.cultivation >= m.requirement()*.8 and (prefix == "junior" or m.realm in [15,16]):
  possibilities.append({"id":"near","stamp":m.realm,"text":L.POOLS[prefix+"_context"][4 if prefix == "junior" else 5]})
 if prefix == "junior" and m.realm >= 17: possibilities.append({"id":"late","stamp":m.realm,"text":L.POOLS.junior_context[5]})
 for entry in possibilities:
  if context_seen.get(prefix+entry.id,-1) != entry.stamp and m.attempts-int(context_cooldowns.get(prefix+entry.id,-100)) >= C.CONTEXT_GAP:
   if entry.has("pool"): entry["text"] = L.POOLS[entry.pool][pick(entry.pool,m)]
   return entry
 return {}
func eligible_line(words: String, m) -> bool:
 if (words.contains("神識") or words.contains("十六對六")) and not probe_learned: return false
 if words.contains("天機閣") and not pavilion_unlocked: return false
 if words.contains("第一次骰寶") and not sicbo_seen: return false
 if words.contains("八九層") and m.realm < 17: return false
 return true
func pick(pool: String, m) -> int:
 var choices: Array = M.POOLS[pool] if pool.begins_with("master_") else L.POOLS[pool]
 var bag: Array = pool_bags.get(pool,[])
 if bag.is_empty():
  for i in range(choices.size()):
   if eligible_line(choices[i],m): bag.append(i)
  for i in range(bag.size()-1,0,-1):
   var j := dialogue_rng.randi_range(0,i);var temp = bag[i];bag[i] = bag[j];bag[j] = temp
 var chosen := -1
 for i in range(bag.size()):
  var candidate: int = bag[i];var key := pool+str(candidate)
  if key in recent_dialogues or candidate==pool_last.get(pool,-1): continue
  chosen = i;break
 if chosen < 0:
  # A small contextual pool may have fewer than five entries. Exhaust it before refilling.
  chosen = 0
  for i in range(bag.size()):
   if bag[i]!=pool_last.get(pool,-1): chosen = i;break
 var result: int = bag.pop_at(chosen);pool_bags[pool] = bag;pool_last[pool]=result
 recent_dialogues.append(pool+str(result))
 if recent_dialogues.size() > C.DIALOGUE_RECENT: recent_dialogues.pop_front()
 return result
func begin_chat(m, npc: String, words: String, id: String):
 if words.contains("第一次骰寶"):
  words = words.replace("\n……後來輸掉多少不重要。", "")
  var first_part: String = words
  chat = {"who":npc,"pages":[first_part,"……後來輸掉多少不重要。"],"index":0,"id":id};m.save_session();return
 var pages: Array[String] = [];var lines := words.split("\n")
 for i in range(0,lines.size(),3): pages.append("\n".join(lines.slice(i,mini(i+3,lines.size()))))
 chat = {"who":npc,"pages":pages,"index":0,"id":id};m.save_session()
func next_chat(m):
 if chat.is_empty(): return
 chat.index += 1
 if chat.index >= chat.pages.size():
  dialogue_seen[chat.id] = true
  if chat.has("context_stamp"): context_seen[chat.id] = chat.context_stamp;context_cooldowns[chat.id] = m.attempts
  if chat.who == "小師妹": reaction = ""
  chat.clear()
 m.save_session()
func start_lesson(m, mode: String):
 if not m.activity_id.is_empty() and m.activity_id != "sect": return
 if m.activity_id.is_empty(): m.auto_before_activity = m.auto_enabled;m.auto_enabled = false
 m.modal.clear();m.activity_id = "duel";m.state = "activity";chat.clear()
 m.duel = preload("res://scripts/story_duel.gd").new();m.duel.setup(mode);m.duel.cue.connect(m._foundation_cue);m.save_session()

func festival_intro(m):
 if m.tournament.kind != "sect" or not m.tutorials_enabled: return
 festival_visits += 1
 m.modal.clear()
 if festival_visits == 1: story(m,"first_festival",L.FIRST_FESTIVAL)
 else:
  var pool := "junior_pre" if festival_visits%2 == 0 else "senior_pre"
  begin_chat(m,"小師妹" if pool == "junior_pre" else "大師姐",L.POOLS[pool][pick(pool,m)],pool+str(festival_visits))
func start_junior_spar(m):
 if not duel_taught: start_lesson(m,"junior");return
 if not m.modal.is_empty(): return
 m.activity_id = "duel";m.state = "activity";chat.clear()
 m.duel = preload("res://scripts/duel_state.gd").new();m.duel.source = "junior";m.duel.custom_name = "小師妹";m.duel.custom_sect = "同門";m.duel.player_level = m.realm;m.duel.learned_probe = probe_learned
 m.duel.cue.connect(m._foundation_cue)
 var pool := "junior_spar_open"
 var lines: Array=[]
 if junior_spar_visits>0: lines.append(["小師妹",L.POOLS.junior_spar_again[pick("junior_spar_again",m)]])
 lines.append(["小師妹",L.POOLS[pool][pick(pool,m)]])
 junior_spar_visits+=1
 story(m,pool,lines);m.save_session()
func start_jade(m):
 if not m.modal.is_empty(): return
 if m.activity_id.is_empty(): m.enter_side_activity("jade")
 else: m.activate_activity("jade")
 last_blood_serial = -1;blood_long_seen = false
 m.blood.practice = true
 m.blood.message = ""
 var lines: Array=[]
 if jade_visits>0: lines.append(["小師妹",L.POOLS.junior_jade_again[pick("junior_jade_again",m)]])
 lines.append(["小師妹",L.POOLS.junior_jade_open[pick("junior_jade_open",m)]])
 if jade_visits==0: lines.append(["小師妹","先掷一次。七或十一，你直接赢；二、三、十二则输。其他点数成为生门，之后先掷到生门便赢，先遇七便输。"])
 jade_visits+=1
 story(m,"jade_open",lines);m.save_session()

func start_senior(m):
 if senior_lesson_complete: probe_learned = true
 var saved := [m.duel_counter,m.duel_threshold,m.duel_due,m.duel_count,m.first_passive_seen,m.last_passive_npc]
 if m.activity_id.is_empty(): m.enter_side_activity("duel")
 else: m.activate_activity("duel")
 m.modal.clear()
 m.duel_counter = saved[0];m.duel_threshold = saved[1];m.duel_due = saved[2];m.duel_count = saved[3];m.first_passive_seen = saved[4]
 m.last_passive_npc = saved[5]
 m.duel.source = "senior";m.duel.custom_name = "大師姐";m.duel.custom_sect = "同門 · 築基七層"
 m.duel.senior = true;m.duel.archetype = 3;m.duel.player_level = m.realm;m.duel.learned_probe = probe_learned
 var pool := "senior_spar_open"
 story(m,pool,[["大師姐",L.POOLS[pool][pick(pool,m)]]]);m.save_session()
func stipend(m, gamble: bool):
 if m.activity_id != "sect" or not m.modal.is_empty() or stipends.is_empty(): return
 if gamble:
  m.activate_activity("sicbo");m.sicbo = preload("res://scripts/sicbo_state.gd").new()
  if not sicbo_seen:
   m.modal.clear();m.help_seen["sicbo"] = true
   story(m,"sicbo_intro")
 else:
  var amount: int = stipends.pop_front();m.spirit_stones += amount
  m.history.append("宗門俸祿｜靈石 +%d" % amount);m.save_session()
func start_sicbo(m, bet: String, target: int):
 if m.activity_id != "sicbo" or not m.modal.is_empty() or m.sicbo.state != "ready" or stipends.is_empty(): return
 if bet not in C.SICBO_PAYOUT and bet != "指定總點數": return
 if bet == "指定總點數" and not C.SICBO_TOTAL.has(target): return
 m.sicbo.stake = stipends.pop_front();m.sicbo.bet = bet;m.sicbo.target = target;m.sicbo.start();m.save_session()
func finish_sicbo(m):
 var s = m.sicbo
 if s.state != "result" or s.paid: return
 s.paid = true
 if s.demo:
  sicbo_seen = true
  var lines: Array = C.STORIES.sicbo_after.duplicate(true)
  if senior_met and present("大師姐",m.attempts): lines.append_array([["大師姐","叫運氣。"],["小師妹","你不說話沒人當你不在。"]])
  m.queue_result("五・五・五　豹子通殺","出現豹子時，大小與單雙等普通下注全部落空。","collect")
  m.pending_result.route = "sicbo_demo";m.pending_result.lines = lines
 else:
  sicbo_lost = s.reward == 0
  m.spirit_stones += s.reward
  m.queue_result("骰寶揭盅","%d・%d・%d\n%s\n靈石 +%d" % [s.dice[0],s.dice[1],s.dice[2],"豹子通殺" if s.dice[0] == s.dice[1] and s.dice[1] == s.dice[2] else "合計 %d" % (s.dice[0]+s.dice[1]+s.dice[2]),s.reward],"collect")
  m.pending_result.route = "sect_return";m.history.append("宗門骰寶｜俸祿 %d · 收回 %d" % [s.stake,s.reward])
 m.save_session()
func buy(m, key: String):
 if m.activity_id != "pavilion" or not m.modal.is_empty() or key not in C.RELICS: return
 if inventory.get("天機券",0) < C.RELICS[key]: return
 inventory["天機券"] -= C.RELICS[key];grant(key);m.save_session()
func choose_card(m, key: String):
 if m.activity_id not in ["sect","tournament"] or not m.modal.is_empty() or card_choices <= 0 or key not in C.CARDS: return
 card_choices -= 1;grant(key);m.save_session()

func reset_master_clicks():
 master_clicks = 0;master_click_attempt = -1;master_click_age = -1
func master_line(m, pool: String, stamp: int, important: bool = false) -> bool:
 var id := pool
 if important and dialogue_seen.has(id): return false
 if not important and (context_seen.get(id,-999) == stamp or m.attempts-int(context_cooldowns.get(id,-100)) < C.CONTEXT_GAP): return false
 var text: String = M.POOLS[pool][pick(pool,m)]
 begin_chat(m,"師父",text,id);chat["context_stamp"] = stamp
 master_last_visit = m.attempts;m.save_session();return true
func talk_master(m):
 if m.attempts-master_click_attempt >= M.CLICK_RESET_ATTEMPTS or m.age-master_click_age >= M.CLICK_RESET_YEARS: reset_master_clicks()
 var gap: int = m.attempts-master_last_visit
 master_clicks += 1;master_click_attempt = m.attempts;master_click_age = m.age
 if m.realm >= 10 and master_line(m,"master_foundation",10,true): return
 if m.realm >= 17 and master_line(m,"master_late",17,true): return
 if m.rebirths > 0 and master_risk_streak >= 3 and master_line(m,"master_reckless",m.attempts): return
 if last_cultivation in ["failure","rebirth"] and m.attempts-last_cultivation_attempt <= 8:
  if master_line(m,"master_"+last_cultivation,last_cultivation_attempt): return
 if festival_result >= 0:
  var pool := "master_good" if festival_result == 3 else ("master_zero" if festival_result == 0 else "master_bad")
  if master_line(m,pool,festival_serial): return
 if m.attempts-last_duel_attempt <= 8 and absi(duel_streak) >= 2:
  if master_line(m,"master_win" if duel_streak > 0 else "master_loss",last_duel_attempt): return
 if master_last_visit >= 0 and gap >= M.RETURN_GAP and master_line(m,"master_return",m.attempts): return
 if m.realm >= 10 and m.next_festival_year()-m.world_year() <= m.P.PREVIEW_YEARS:
  if master_line(m,"master_pre",m.next_festival_year()): return
 if junior_visit_count >= 6 and master_line(m,"master_junior",m.attempts): junior_visit_count = 0;return
 if m.attempts-last_duel_attempt <= 8 and master_clicks == 1 and master_line(m,"master_duel",last_duel_attempt): return
 master_last_visit = m.attempts
 if master_clicks > 1:
  begin_chat(m,"師父",M.REPEAT[mini(master_clicks-2,M.REPEAT.size()-1)],"master_repeat");return
 var i := pick("master_daily",m)
 begin_chat(m,"師父",M.POOLS.master_daily[i],"master_daily"+str(i))
