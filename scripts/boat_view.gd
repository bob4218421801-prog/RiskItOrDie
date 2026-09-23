extends Control
var model: RefCounted
var clock := 0.0
var crash_age := 0.0
var ship: TextureRect
func _ready():
 ship = preload("res://scripts/ink_assets.gd").sprite(preload("res://scripts/ink_assets.gd").boat())
 ship.size = Vector2(360,220);ship.pivot_offset = ship.size*.5;add_child(ship)

func _process(delta: float) -> void:
 if not is_visible_in_tree() or model == null: return
 if not model.focus_paused:
  clock += delta
 if model.boat.state == "crashed": crash_age += delta
 else: crash_age = 0.0
 var intensity := clampf(log(model.boat.multiplier)/log(12.0),0,1)
 ship.position = Vector2(550,390-80*intensity)-ship.size*.5
 ship.rotation = -.04*intensity
 ship.modulate.a = 1.0
 if model.boat.state == "crashed":
  ship.position.y += crash_age*180
  ship.rotation = crash_age*.8
  ship.modulate.a = maxf(0,1-crash_age)
 ship.visible = model.state != "ship_ready"
 queue_redraw()

func _draw() -> void:
 if model == null: return
 draw_texture_rect(preload("res://scripts/ink_assets.gd").texture("landscape"),Rect2(Vector2.ZERO,size),false)
 if model.state == "ship_ready": return
 var intensity := clampf(log(model.boat.multiplier) / log(12.0), 0.0, 1.0)
 var flow: float = model.boat.elapsed * 35 + pow(model.boat.elapsed, 2) * 8
 for index in range(32):
  var x := 40.0 + fmod(index * 137.3, 1020)
  var y := 210.0 + fmod(index * 41.7 + flow, 300)
  draw_line(Vector2(x, y), Vector2(x - 7, y + 10 + intensity * 38), Color(0.5, 0.8, 0.9, 0.1 + 0.3 * intensity), 1.5, true)
 var center := Vector2(550, 420 - 80 * intensity)
 center += Vector2(sin(clock * 19), cos(clock * 23)) * intensity * 3.5
 if model.boat.state == "crashed":
  var burst := minf(crash_age * 2, 1.0)
  for index in range(18):
   var direction := Vector2.from_angle(index * TAU / 18.0)
   draw_line(center + direction * (15 + burst * 50), center + direction * (40 + burst * 100), Color(1, 0.4, 0.2, 1.0 - burst * 0.7), 3, true)
  return
 var jade := Color("76dfc2")
 for index in range(9):
  var spread := (index - 4) * 7.0
  draw_line(center + Vector2(spread, 30), center + Vector2(spread * 1.9, 100 + intensity * 65), Color(jade, 0.08 + intensity * 0.2), 2, true)
 if model.boat.state == "collected":
  draw_arc(center, 145, 0, TAU, 96, Color("f5d48b"), 3, true)
