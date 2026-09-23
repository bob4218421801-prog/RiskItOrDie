extends Control
var model: RefCounted
var time := 0.0
func _ready():
 name = "AccumulatingFoundationRings"
 mouse_filter = Control.MOUSE_FILTER_IGNORE
func _process(delta):
 time += delta
 queue_redraw()
func _draw():
 if model.foundation == null or model.state != "foundation": return
 var f: RefCounted = model.foundation
 if f.phase in ["silence","freeze"]: return
 var cracked: bool = f.phase in ["crack","burst","silence","freeze"]
 var count: int = f.result.get("final",f.grade) if f.phase in ["rebuild","reveal","result"] else f.grade
 var center := Vector2(207.5,337.5)
 for i in range(count):
  var radius := 68.0+i*10
  var color := Color(.96,.79,.35,.45+.45*f.hold_elapsed/f.P.FOUNDATION_HOLD if f.state == "charging" else .65) if not cracked else Color(.4,.31,.3,.3)
  var wobble := sin(time*40+i)*5 if cracked and f.phase not in ["silence","freeze"] else 0.0
  if cracked:
   for part in range(6): draw_arc(center+Vector2(wobble,0),radius,part*TAU/6,part*TAU/6+.65,12,color,2,true)
  else: draw_arc(center,radius,0,TAU,80,color,2,true)
  if f.phase in ["impact","rebuild","reveal"]:
   var p := center+Vector2.from_angle(time*2+i)*radius
   draw_circle(p,4,Color(1,.9,.5,.8))
 if count == 9 and not cracked: draw_arc(center,158,0,TAU,100,Color(1,.9,.65,.9),5,true)
