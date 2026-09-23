extends Control
## Pure drawing; no simulation RNG, movement of hit targets or altered time scale.
var model: RefCounted
var time := 0.0
func _ready():
 name = "ActivityFeedback"
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 size = Vector2(1920,1080)
func _process(delta):
 mouse_filter = Control.MOUSE_FILTER_STOP if model.result_delay > 0 else Control.MOUSE_FILTER_IGNORE
 time += delta
 queue_redraw()
func _draw():
 if model.result_delay > 0:
  var t: float = 1-model.result_delay/maxf(model.feedback_duration,.001)
  var failure: bool = model.feedback_kind in ["mines_failure","furnace_explosion","stone_shatter","boat_crash"]
  var center := Vector2(960,485)
  var color := Color(.92,.3,.14,1-t) if failure else Color(.94,.81,.35,1-t)
  if model.feedback_kind == "furnace_explosion":
   center += Vector2(sin(t*91),cos(t*81))*18*(1-t)
   draw_circle(center,90+t*180,Color(1,.26,.06,(1-t)*.22))
   draw_circle(center,75,Color("614842"))
   draw_rect(Rect2(center-Vector2(87,63),Vector2(174,17)),Color("b6a183"))
   draw_arc(center,100,0,TAU,64,color,12,true)
   for i in range(14):
    var a := TAU*i/14
    draw_line(center+Vector2.from_angle(a)*65,center+Vector2.from_angle(a)*(110+150*t),color,9,true)
  if failure:
   draw_rect(Rect2(Vector2.ZERO,size),Color(.1,.02,.03,.13*(1-t)))
   if t < .18: draw_rect(Rect2(Vector2.ZERO,size),Color(1,.8,.6,(.18-t)*1.2))
   for i in range(18):
    var a := TAU*i/18
    var v := Vector2.from_angle(a)
    var p := center+v*(90+470*t)+Vector2(0,210*t*t)
    draw_line(center+v*70,center+v*(90+t*350)+Vector2(sin(i*7)*30,0),Color(.35,.12,.3,.5*(1-t)),3,true)
    draw_rect(Rect2(p,Vector2(9+i%4*3,7)),color)
    draw_circle(p+Vector2(0,-45*t),24+50*t,Color(.24,.21,.28,.12*(1-t)))
  else:
   draw_arc(center,90+300*t,0,TAU,80,color,4,true)
   for i in range(20): draw_circle(center+Vector2.from_angle(i*TAU/20)*(100+400*t),4,color)
 if model.activity_id == "mines" and model.mines != null and model.mines.state == "mining":
  var pressure: float = clampf(model.mines.reward/1600.0,0,1)
  for side in [0,1]:
   var x := 110 if side == 0 else 1810
   for i in range(8):
    var y: float = 200+i*90+sin(time*2+i)*pressure*5
    draw_line(Vector2(x,y),Vector2(x+(25 if side == 0 else -25),y+38),Color(.7,.24,.4,pressure*.5),3,true)
    draw_circle(Vector2(x,y),25+sin(time+i)*10,Color(.35,.13,.38,pressure*.09))
