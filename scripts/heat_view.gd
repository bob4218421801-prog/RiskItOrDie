extends Control
var model: RefCounted
func _ready():
 custom_minimum_size = Vector2(900,105)
 mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw():
 var a: RefCounted = model.alchemy
 var band: Vector2 = a.target()
 var x := 20.0
 var width := size.x-40
 var bounds := [0.0,.25,band.x,band.y,.83,1.0]
 var names := ["火弱","文火","最佳丹火區","猛火","失控"]
 var colors := [Color("304353"),Color("526b83"),Color("368a76"),Color("b47842"),Color("a63847")]
 for i in range(5):
  draw_rect(Rect2(x+width*bounds[i],34,width*(bounds[i+1]-bounds[i]),40),colors[i])
  draw_string(get_theme_default_font(),Vector2(x+width*(bounds[i]+bounds[i+1])*.5-55,25),names[i],HORIZONTAL_ALIGNMENT_LEFT,-1,21,Color.WHITE)
 var pointer: float = x+width*a.heat
 draw_line(Vector2(pointer,29),Vector2(pointer,86),Color("fff3ca"),5,true)
 draw_circle(Vector2(pointer,88),6,Color("fff3ca"))

