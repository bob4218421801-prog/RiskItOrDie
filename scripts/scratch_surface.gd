extends Control
var model: RefCounted
var vibration := Vector2.ZERO
var time := 0.0
var dragging := false
var previous := Vector2.ZERO
var dust: Array[Dictionary] = []
var audio_cooldown := 0.0
func _ready() -> void:
 name = "ScratchSurface"
 clip_contents = true
 custom_minimum_size = Vector2(900,360)
 mouse_filter = Control.MOUSE_FILTER_STOP
 for kind in ["StoneBackground","StoneInterior","StoneGlow","StoneMask","StoneCracks","StoneParticles"]:
  var visual = preload("res://scripts/stone_layer.gd").new()
  visual.name = kind
  visual.layer = kind
  visual.surface = self
  visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
  add_child(visual)
  visual.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
func _gui_input(event: InputEvent) -> void:
 if model.stone.state != "scratching": return
 if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
  dragging = event.pressed
  previous = event.position
  if dragging: stroke(event.position)
 elif event is InputEventMouseMotion and dragging: stroke(event.position)
 elif event is InputEventScreenTouch:
  dragging = event.pressed
  previous = event.position
  if dragging: stroke(event.position)
 elif event is InputEventScreenDrag and dragging: stroke(event.position)
 accept_event()
func stroke(point: Vector2) -> void:
 var distance := previous.distance_to(point)
 var steps := maxi(1,int(ceil(distance/12.0)))
 for i in range(steps+1):
  var sample := previous.lerp(point,float(i)/steps)
  if Rect2(Vector2.ZERO,size).has_point(sample): model.scratch_stone(sample/size)
 previous = point
 dust.append({"point":point,"life":1.0})
 if audio_cooldown <= 0:
  model.sfx_event.emit("stone_scratch")
  audio_cooldown = .12
func _process(delta: float) -> void:
 time += delta
 vibration = Vector2(sin(time*71),cos(time*83))*(.5+model.stone.depth*.35) if dragging and model.stone.state == "scratching" else Vector2.ZERO
 audio_cooldown -= delta
 for d in dust: d.life -= delta*2
 dust = dust.filter(func(d): return d.life > 0)
 for visual in get_children(): visual.queue_redraw()
