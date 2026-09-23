extends Node
## One loop, one result channel, one UI channel, serialized breakthrough queue.
signal played(key: String)
const LEVELS := {"cultivation_charge": -6.0, "cultivation_good_release": -14.0, "cultivation_risky_release": -11.0, "cultivation_extreme_release": -9.0, "cultivation_failure": -8.0, "realm_breakthrough": -10.0, "boat_cashout": -12.0, "ui_confirm": -6.0}
var accents: Array[AudioStreamPlayer] = []
var generated: Node
var streams: Dictionary = {}
var charge: AudioStreamPlayer
var boat_flight: AudioStreamPlayer
var result: AudioStreamPlayer
var ui: AudioStreamPlayer
var breakthrough: AudioStreamPlayer
var pending := 0
var spacing := 0.0
var enabled := true
var debug_charge := false
var last_diagnostic := "No event yet"
var diagnostic_logging := false
const EXCLUSIVE_EVENTS = ["boat_launch", "boat_crash", "mines_ordinary"]
var exclusive_event := ""
func _ready() -> void:
 if AudioServer.get_bus_index("SFX") < 0:
  AudioServer.add_bus()
  AudioServer.set_bus_name(AudioServer.bus_count-1,"SFX")
 AudioServer.set_bus_send(AudioServer.get_bus_index("SFX"),"Master")
 AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),-3)
 for key in LEVELS:
  streams[key] = load("res://assets/audio/sfx/sfx_"+key+".mp3")
 charge = player()
 boat_flight = player()
 result = player()
 ui = player()
 breakthrough = player()
 for i in range(3): accents.append(player())
 var loop: AudioStreamMP3 = streams.cultivation_charge.duplicate()
 loop.loop = true
 charge.stream = loop
 boat_flight.stream = loop.duplicate()
 boat_flight.volume_db = -12.0
 generated = preload("res://scripts/generated_audio.gd").new()
 add_child(generated)
 set_enabled(enabled)
func player() -> AudioStreamPlayer:
 var node := AudioStreamPlayer.new()
 node.bus = "SFX"
 add_child(node)
 return node
func set_enabled(value: bool) -> void:
 if enabled and not value:
  stop_charge()
  boat_flight.stop()
  if generated != null: generated.stop_ambient()
 enabled = value
 AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"),not value)
func handle_event(key: String) -> void:
 # Reuse the two existing sounds explicitly selected by the player.
 if key in ["boat_crash", "boat_cashout", "stop_all", "silence"]: boat_flight.stop()
 if key.begins_with("boat_") and key not in ["boat_launch", "boat_crash"]: return
 var host = get_parent()
 if host != null and "run" in host and host.run != null and host.run.activity_id == "flying_boat" and key not in ["boat_launch","boat_crash","stop_all","stop_charge","silence"]: return
 if not enabled and key not in ["stop_all", "stop_charge"]: return
 if key == "mines_danger" and exclusive_event == "mines_ordinary" and result.playing: return
 if key in EXCLUSIVE_EVENTS:
  result.stop()
  for accent in accents: accent.stop()
  generated.stop_ambient()
  generated.stop_preview()
  exclusive_event = key
 match key:
  "boat_launch":
   stop_charge()
   if not boat_flight.playing:
    boat_flight.stream_paused = false
    boat_flight.play()
    played.emit(key)
    diagnose(key, boat_flight)
  "boat_crash":
   result.stream = generated.stream_for("stone_shatter")
   if result.stream != null:
    result.volume_db = -14.0
    result.play()
    played.emit(key)
    diagnose(key, result)
  "stop_all":
   exclusive_event = ""
   stop_charge()
   if generated != null:
    generated.stop_preview()
    generated.stop_ambient()
   result.stop()
   for accent in accents: accent.stop()
   ui.stop()
   breakthrough.stop()
   pending = 0
   spacing = 0
  "silence":
   exclusive_event = ""
   stop_charge()
   result.stop()
   for accent in accents: accent.stop()
   breakthrough.stop()
   pending = 0
   generated.stop_ambient()
  "foundation_charge": generated.set_ambient(key)
  "stop_foundation_charge": generated.stop_ambient()
  "stone_scratch": generated.scratch_left = .18
  "stop_charge": stop_charge()
  "charge":
   if not charge.playing:
    var chosen: AudioStream = streams.cultivation_charge.duplicate()
    charge.stream = chosen if chosen != null else streams.cultivation_charge.duplicate()
    charge.stream.loop = true
    charge.pitch_scale = 1.0
    charge.volume_db = LEVELS.cultivation_charge
    charge.play()
    played.emit(key)
    diagnose(key, charge)
  "realm_breakthrough": pending += 1
  _:
   var chosen: AudioStream = streams.get(key) if LEVELS.has(key) else generated.stream_for(key)
   if chosen == null: chosen = streams.get(key)
   if chosen == null: return
   var channel: AudioStreamPlayer = ui if key in ["ui_confirm","ui_cancel","opportunity_notice","ticket_obtained","shop_purchase","result_confirm"] else result
   if channel == result and key not in LEVELS and result.playing:
    for accent in accents:
     if not accent.playing:
      channel = accent
      break
   if channel == result and key not in EXCLUSIVE_EVENTS: exclusive_event = ""
   channel.stream = chosen
   channel.volume_db = LEVELS.get(key,-14.0)
   channel.play()
   played.emit(key)
   diagnose(key, channel)
   if channel == result: spacing = .18
func stop_charge() -> void:
 debug_charge = false
 if is_instance_valid(charge): charge.stop()
func update_charge(delta: float, instability: float, active: bool) -> void:
 if debug_charge: return
 if not active or not enabled:
  stop_charge()
  return
 if not charge.playing: return # Start only from the begin event, never from _process.
 var tension := smoothstep(0.0,1.0,clampf(instability,0,1))
 var weight := 1.0-exp(-delta/0.18)
 charge.pitch_scale = lerpf(charge.pitch_scale,lerpf(1.0,1.18,tension),weight)
 charge.volume_db = lerpf(charge.volume_db,lerpf(LEVELS.cultivation_charge,-2.0,tension),weight)
func _process(delta: float) -> void:
 spacing = maxf(spacing-delta,0)
 if pending > 0 and not result.playing and not breakthrough.playing and spacing <= 0:
  pending -= 1
  breakthrough.stream = streams.realm_breakthrough
  if breakthrough.stream == null: breakthrough.stream = streams.realm_breakthrough
  breakthrough.volume_db = LEVELS.realm_breakthrough
  breakthrough.play()
  played.emit("realm_breakthrough")
  diagnose("realm_breakthrough", breakthrough)
func _exit_tree() -> void:
 handle_event("stop_all")

func debug_test(key: String) -> void:
 if not OS.is_debug_build(): return
 if key == "stop_charge":
  stop_charge()
 elif key == "charge":
  handle_event(key)
  debug_charge = enabled
 else:
  handle_event(key)
func diagnose(key: String, channel: AudioStreamPlayer) -> void:
 var bus_index := AudioServer.get_bus_index(channel.bus)
 last_diagnostic = "event=%s resource=%s loaded=%s assigned=%s play_called=true playing=%s\nbus=%s mute=%s Master_mute=%s volume=%.1f pitch=%.3f" % [key, channel.stream.resource_name if not channel.stream.resource_name.is_empty() else channel.stream.resource_path, channel.stream != null, channel.stream != null, channel.playing, channel.bus, AudioServer.is_bus_mute(bus_index), AudioServer.is_bus_mute(0), channel.volume_db, channel.pitch_scale]
 if diagnostic_logging and OS.is_debug_build(): print(last_diagnostic)

func update_activity_audio(model: RefCounted, paused: bool) -> void:
 if generated == null: return
 var flying: bool = model.activity_id == "flying_boat" and model.state == "ship" and model.boat != null and model.boat.state == "flying"
 if not flying or not enabled:
  boat_flight.stop()
 else:
  var blocked: bool = paused or not model.modal.is_empty() or model.result_delay > 0 or model.focus_paused
  boat_flight.stream_paused = blocked
  # Also restore the loop when loading a saved flight or re-enabling sound.
  if not blocked and not boat_flight.playing:
   boat_flight.play()
 var event := ""
 if enabled and not paused and model.modal.is_empty() and model.result_delay <= 0 and not model.focus_paused:
  if model.activity_id == "stone_gambling" and model.stone != null and model.stone.state == "scratching" and generated.scratch_left > 0: event = "stone_scratch_loop"
  if model.state == "foundation" and model.foundation != null and model.foundation.state == "charging": event = "foundation_charge"
  # Flight uses its own cultivation loop; keep legacy boat ambience muted.
  if model.state == "ship": event = ""
  if model.activity_id == "alchemy" and model.alchemy != null and model.alchemy.state in ["idle","heating"] and model.alchemy.heat > .1:
   event = ["alchemy_low_loop","alchemy_medium_loop","alchemy_high_loop","alchemy_high_loop"][model.alchemy.zone()]
   if model.alchemy.extra and model.alchemy.zone() >= 2: event = "alchemy_reforge"
 if event.begins_with("boat_"): event = ""
 if exclusive_event in EXCLUSIVE_EVENTS and result.playing: event = ""
 generated.set_ambient(event)
 if model.modal.get("id","") == "opening": generated.ambient.volume_db = -32
 elif event.begins_with("alchemy_") and model.alchemy != null:
  generated.ambient.volume_db = lerpf(-24,-14,model.alchemy.heat)+(2 if model.alchemy.extra else 0)
 elif event == "foundation_charge":
  generated.ambient.volume_db = lerpf(-24,-12,model.foundation.hold_elapsed/model.foundation.P.FOUNDATION_HOLD)
 else: generated.ambient.volume_db = -22
