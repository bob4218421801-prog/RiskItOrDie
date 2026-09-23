extends Node
const POLICY = preload("res://scripts/audio_policy.gd")
const BASE = "res://assets/audio/sfx/ai_generated/"
var candidates: Array = []
var catalog: Array = []
var selected: Dictionary = {}
var preview: AudioStreamPlayer
var ambient: AudioStreamPlayer
var ambient_key := ""
var scratch_left := 0.0
var diagnostic := ""
func _ready():
 preview = AudioStreamPlayer.new()
 preview.bus = "SFX"
 preview.volume_db = -12
 add_child(preview)
 ambient = AudioStreamPlayer.new()
 ambient.bus = "SFX"
 ambient.volume_db = -22
 add_child(ambient)
 reload_bank()
func json_file(path: String, fallback: Variant) -> Variant:
 if not FileAccess.file_exists(path): return fallback
 var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
 return value if value != null else fallback
func reload_bank():
 candidates = json_file(BASE+"generated_sfx.json",{}).get("candidates",[])
 catalog = json_file(BASE+"catalog.json",[])
 selected = json_file(BASE+"selected.json",{})
func latest(event: String, candidate: String) -> Dictionary:
 event = POLICY.ALIASES.get(event,event)
 for i in range(candidates.size()-1,-1,-1):
  if candidates[i].event == event and candidates[i].candidate == candidate: return candidates[i]
 return {}
func read_stream(record: Dictionary) -> AudioStream:
 if record.is_empty(): return null
 var path: String = ("res://"+str(record.get("file",""))).simplify_path()
 if not path.begins_with(BASE) or not path.ends_with(".mp3"): return null
 var stream: AudioStreamMP3
 if FileAccess.file_exists(path):
  # Newly generated files can be auditioned before the editor imports them.
  stream = AudioStreamMP3.new()
  stream.data = FileAccess.get_file_as_bytes(path)
 elif ResourceLoader.exists(path):
  # Exported MP3s are remapped imported resources, not loose source files.
  var imported = load(path)
  if not imported is AudioStreamMP3: return null
  stream = imported.duplicate()
 else: return null
 if stream.get_length() <= 0: return null
 stream.loop = record.get("loop",false)
 stream.resource_name = path
 return stream
func stream_for(event: String) -> AudioStream:
 return read_stream(selected.get(event,selected.get(POLICY.ALIASES.get(event,event),{})))
func audition(event: String, candidate: String):
 if not OS.is_debug_build(): return
 preview.stop()
 var record := latest(event,candidate)
 preview.stream = read_stream(record)
 if preview.stream != null:
  preview.play()
  diagnostic = event+" / "+candidate
 else: diagnostic = "尚未生成或檔案無效："+event+" / "+candidate
func adopt(event: String, candidate: String) -> bool:
 if not OS.is_debug_build(): return false
 var record := latest(event,candidate)
 if read_stream(record) == null: return false
 selected[event] = record.duplicate(true)
 var f := FileAccess.open(BASE+"selected.json",FileAccess.WRITE)
 if f == null: return false
 f.store_string(JSON.stringify(selected,"  "))
 diagnostic = "已採用 "+event+" / "+candidate+"；下次事件生效"
 return true
func stop_preview():
 if preview != null: preview.stop()
func stop_ambient():
 ambient_key = ""
 if ambient != null: ambient.stop()
func set_ambient(event: String):
 if event == ambient_key: return
 stop_ambient()
 if event.is_empty(): return
 ambient.stream = stream_for(event)
 if ambient.stream is AudioStreamMP3: ambient.stream.loop = true
 if ambient.stream != null:
  ambient_key = event
  ambient.play()
func regenerate_request(event: String, candidate: String):
 if not OS.is_debug_build(): return
 # Development request only; an explicit local generator command performs network calls.
 var f := FileAccess.open("res://tools/audio_gen/request.json",FileAccess.WRITE)
 if f != null:
  f.store_string(JSON.stringify({"event":event,"candidate":candidate,"regenerate":true}))
  var pid := OS.create_process("powershell.exe",["-NoProfile","-WindowStyle","Hidden","-ExecutionPolicy","Bypass","-File",ProjectSettings.globalize_path("res://tools/audio_gen/regenerate.ps1"),event,candidate],false)
  diagnostic = "已啟動單一候選重生；完成後按重讀清單，已採用版本保留。" if pid > 0 else "無法啟動；本機執行 generate.py --from-request。"

func _process(delta):
 scratch_left = maxf(0,scratch_left-delta)
