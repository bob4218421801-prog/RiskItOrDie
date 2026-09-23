extends RefCounted
const A = preload("res://scripts/alchemy_config.gd")
signal cue(key: String)
var practice := false
var state := "ready"
var recipe := -1
var heat := 0.0
var refinement := 0.0
var instability := 0.0
var fires := 0 # Legacy diagnostic only, never drives progression.
var extra := false
var extra_used := false
var quality := 0
var result := ""
var message := "按住升火，鬆手降火。"
var paid_out := false
var holding := false
var elapsed := 0.0
var warning := false
var lesson := 0
var accumulator := 0.0
var overrides: RefCounted
var force := ""
func start(index: int, _forced: String = ""):
 if state != "ready": return
 recipe = index
 state = "idle"
func begin_fire():
 if state not in ["idle","heating"]: return
 holding = true
 state = "heating"
func release_fire():
 holding = false
 if state == "heating": state = "idle"
func target() -> Vector2:
 var center: float = A.CENTER+sin(elapsed*.55)*A.DRIFT[recipe]
 var width: float = A.WIDTHS[recipe]*(A.EXTRA_WIDTH if extra else 1.0)
 return Vector2(center-width*.5,center+width*.5)
func zone() -> int:
 if heat < .25: return 0
 if heat < target().x: return 1
 if heat <= target().y: return 2
 return 3
func stage_text() -> String:
 if state == "choice": return "丹紋浮現 · 上品" if quality == 1 else "丹成 · 此刻開爐便可安全收丹"
 if state == "result": return "丹火暴走 · 爐毀丹失" if result == "failure" else "丹香滿室"
 if warning: return "爐壁震顫！鬆手降火，莫讓丹火暴走。"
 if lesson == 0: return "按住升火，鬆手降火。"
 return ["藥液流轉", "靈氣聚攏", "丹胚成形", "丹丸漸整"][mini(3,int(refinement*4))]+" · 將爐火穩在丹火之中，丹胚自會成形。"
func advance(delta: float):
 if state not in ["idle","heating"]: return
 accumulator += delta
 while accumulator >= A.STEP and state in ["idle","heating"]:
  accumulator -= A.STEP
  step(A.STEP)
func step(dt: float):
 elapsed += dt
 var speed: float = A.EXTRA_SPEED if extra else 1.0
 heat = clampf(heat+dt*(A.RISE[recipe] if holding else -A.FALL[recipe])*speed,0,1)
 if heat > .25: lesson = 1
 var was_warning := warning
 warning = heat >= A.WARNING or instability > .3
 if warning and not was_warning: cue.emit("alchemy_unstable")
 if heat >= A.OVERHEAT:
  instability += dt/A.EXPLODE_SECONDS[recipe]*(A.EXTRA_PRESSURE if extra else 1.0)
 else: instability = maxf(0,instability-dt*A.PRESSURE_RECOVERY)
 if instability >= 1:
  result = "failure"
  state = "result"
  holding = false
  return
 var band := target()
 if heat >= band.x and heat <= band.y:
  refinement += dt/A.FORM_SECONDS[recipe]
 if refinement >= 1:
  refinement = 1
  quality = 1 if extra else 0
  state = "choice"
  holding = false
  heat = 0
  warning = false
  cue.emit("alchemy_upper" if extra else "alchemy_open")
func extra_fire():
 if state != "choice" or extra_used: return
 extra_used = true
 extra = true
 refinement = 0
 heat = .45
 instability = .1
 state = "idle"
 message = "丹已成，仍願再淬？這一輪失手，普通丹也會盡失。"
func collect():
 if state != "choice": return
 result = "success"
 state = "result"

