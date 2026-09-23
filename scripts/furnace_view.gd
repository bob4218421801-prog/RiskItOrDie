extends Control
var model: RefCounted
var time := 0.0
func _ready():
 name = "FurnaceVisual"
 custom_minimum_size = Vector2(300,160)
 mouse_filter = Control.MOUSE_FILTER_IGNORE
func _process(delta):
 time += delta
 queue_redraw()
func _draw():
 var a: RefCounted = model.alchemy
 var center := size*.5
 var shake: Vector2 = Vector2(sin(time*41),cos(time*47))*a.instability*4
 center += shake
 draw_texture_rect(preload("res://scripts/ink_assets.gd").icon(9),Rect2(center-Vector2(83,80),Vector2(166,160)),false)
 var hot: float = a.heat
 for i in range(9):
  var point := center+Vector2((i-4)*17,78)
  draw_line(point,point+Vector2(sin(time*6+i)*8,-20-hot*60*(.7+.3*sin(time*12+i))),Color("fa9864"),7,true)


 # The pill forms visibly; no numeric progress display.
 var progress: float = a.refinement
 draw_circle(center,12+progress*20,Color(.5+progress*.4,.7,.4, .45+progress*.55),true,-1,true)
 for i in range(int(progress*12)):
  var angle: float = time*.8+i*TAU/12
  draw_circle(center+Vector2(cos(angle),sin(angle))*(55-progress*20),3,Color("b9ecd5"))
 if a.quality == 1: draw_arc(center,37,0,TAU,32,Color.GOLD,3,true)
 if a.warning:
  for i in range(7):
   var drift := fmod(time*30+i*19,105.0)
   draw_circle(center+Vector2(sin(time+i)*45,-50-drift),10+drift*.1,Color(.35,.3,.3,.5*(1-drift/110)))
