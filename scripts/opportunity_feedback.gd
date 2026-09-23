extends Control
# Visual feedback only; it never intercepts pointer input or expands the button hitbox.
var button: Button
var selected:=false
var was_disabled:=false
func sync_disabled():
 if was_disabled!=button.disabled:
  was_disabled=button.disabled;queue_redraw()
func _ready():
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 button.mouse_entered.connect(queue_redraw);button.mouse_exited.connect(queue_redraw)
 button.button_down.connect(queue_redraw);button.button_up.connect(queue_redraw)
func _draw():
 if button.disabled and not selected:return
 var hovered:=button.is_hovered() and not button.disabled
 if not hovered and not selected:return
 var box:=StyleBoxFlat.new();box.set_corner_radius_all(7);box.set_border_width_all(3 if selected else 2)
 box.border_color=Color("ffe49d") if selected else Color("bbfff0")
 box.bg_color=Color(1,.78,.3,.22 if button.is_pressed() else .1) if selected else Color(.6,1,.88,.22 if button.is_pressed() else .12)
 draw_style_box(box,Rect2(Vector2(4,4),size-Vector2(8,8)))
 if selected:
  draw_circle(Vector2(size.x-13,13),8,Color("173f38"))
  draw_polyline(PackedVector2Array([Vector2(size.x-18,13),Vector2(size.x-14,17),Vector2(size.x-8,9)]),Color("ffe49d"),2,true)
