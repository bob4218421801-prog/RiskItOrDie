extends Control
var surface: Control
var layer := ""
const E = preload("res://scripts/economy_config.gd")
func _draw() -> void:
 var stone: RefCounted = surface.model.stone
 if stone == null or stone.state == "ready": return
 draw_set_transform(surface.vibration)
 var base := Rect2(Vector2.ZERO,size)
 var colors := [Color("78cda2"),Color("e5a27e"),Color("b19bed"),Color("f8d573"),Color("ecfaff")]
 var color: Color = colors[stone.rewards[stone.depth].material]
 match layer:
  "StoneBackground": draw_rect(base,Color("1a2630"))
  "StoneInterior":
   draw_rect(base,Color(color,.35))
   for i in range(15):
    var center := Vector2(fmod(i*137.1,size.x),fmod(i*73.7,size.y))
    draw_circle(center,8+stone.depth*5,Color(color,.65),true,-1,true)
  "StoneGlow":
   draw_circle(size*.5,90+stone.depth*35,Color(color,.12+stone.coverage()*.2),true,-1,true)
  "StoneMask":
   var cell := size/Vector2(E.SCRATCH_COLUMNS,E.SCRATCH_ROWS)
   for y in range(E.SCRATCH_ROWS):
    for x in range(E.SCRATCH_COLUMNS):
     if not stone.covered.has(y*E.SCRATCH_COLUMNS+x):
      var shade := .23+fmod(x*3+y*7,5)*.014
      draw_rect(Rect2(Vector2(x,y)*cell,cell+Vector2.ONE),Color(shade,shade+.02,shade+.035))
  "StoneCracks":
   if stone.depth > 0 or stone.state == "result" and stone.result.get("failed",false):
    for i in range(3+stone.depth*2):
     var a := size*.5+Vector2.from_angle(i*1.41)*70
     var b := a+Vector2.from_angle(i*1.73)*85
     draw_line(a,b,Color("e9bb85"),2,true)
  "StoneParticles":
   for i in range(surface.dust.size()):
    var d: Dictionary = surface.dust[i]
    draw_circle(d.point+Vector2(sin(i*2.3)*35,-(1-d.life)*60),3*d.life,Color("b2a99c"),true,-1,true)
