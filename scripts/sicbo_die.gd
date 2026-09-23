extends Control
# Presentation only: never accesses simulation RNG or reveals the committed value early.
var value := 0
var order := 0
var elapsed := 0.0
var landed := 0.0
func _ready():
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 custom_minimum_size = Vector2(440,240)
func _process(delta):
 elapsed += delta
 landed = minf(landed+delta,1) if value > 0 else 0.0
 queue_redraw()
func _draw():
 var flying := value == 0
 var bounce := absf(sin(landed*22))*exp(-landed*8)*22 if not flying else 0.0
 var y := -absf(sin(elapsed*8+order))*45 if flying else -bounce
 var center := Vector2(size.x*.5,135+y)
 draw_set_transform(Vector2(size.x*.5,218),0,Vector2(1,.14))
 draw_circle(Vector2.ZERO,76,Color(0,0,0,.24))
 draw_set_transform(center,sin(elapsed*10+order)*.24 if flying else sin(landed*20)*exp(-landed*10)*.12)
 var box := StyleBoxFlat.new()
 box.bg_color = Color("d9e1cf");box.border_color = Color("9aaa87")
 box.set_border_width_all(4);box.set_corner_radius_all(18)
 draw_style_box(box,Rect2(-78,-78,156,156))
 var face := 1+int(elapsed*15+order*2)%6 if flying else value
 var pips: Array[Vector2] = []
 if face%2 == 1: pips.append(Vector2.ZERO)
 if face >= 2: pips.append_array([Vector2(-42,-42),Vector2(42,42)])
 if face >= 4: pips.append_array([Vector2(42,-42),Vector2(-42,42)])
 if face == 6: pips.append_array([Vector2(-42,0),Vector2(42,0)])
 for pos in pips: draw_circle(pos,12,Color("913d38") if face in [1,4] else Color("273e39"),true,-1,true)
 draw_set_transform(Vector2.ZERO)
