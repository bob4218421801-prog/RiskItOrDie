extends RefCounted
const REAR=preload("res://assets/ui_v6/vfx/array_rear.png")
const GROUND=preload("res://assets/ui_v6/vfx/array_ground.png")
const BEAM=preload("res://assets/ui_v6/vfx/beam.png")
# All motion is presentation-only: no simulation RNG, time scale or reward mutations.
static func paint(host: Control) -> void:
 var m=host.run
 var time: float=host.animation_time
 var danger: float=host.C.feedback_intensity(m.risk)
 var holding: bool=m.state=="holding"
 var rupture: bool=m.state=="rupture"
 var failure: bool=rupture and m.phase in ["loss","silence"]
 var jackpot: bool=rupture and not failure
 var result: bool=not holding and not rupture and host.feedback_left>0 and not m.last_result.is_empty()
 var fade: float=clampf(host.feedback_left/host.C.COMMENT_SECONDS,0,1)
 var result_risk: float=m.last_result.get("instability",0.0)
 var result_kind: String=m.last_result.get("outcome","")
 var active: bool=holding or rupture or result
 var phase_age: float=m.phase_duration-m.pause_left
 if failure or (result and result_kind=="failure"):
  var offset:=Vector2.ZERO
  if failure and m.phase=="loss": offset=Vector2(sin(time*49),cos(time*61))*6*maxf(0,1-phase_age/.28)
  host.draw_texture_rect(host.character.texture(),host.seat_anchor.actor_rect(offset),false)
  return
 var radius: float=210+100*minf(m.hold/2,1)+190*danger*danger
 var strength: float=.7+danger*.4
 var tint:=Color(1,.93,.65)
 if result:
  radius=(380+130*result_risk if result_kind=="success" else 620 if result_kind=="rebirth" else 430)*(1.08-.08*fade)
  strength=fade*.9
 if jackpot:
  radius=lerpf(330,650,1-pow(1-clampf(phase_age/.45,0,1),3)) if m.phase=="burst" else 650
  strength=1.05
 var center: Vector2=host.seat_anchor.dantian_position()+Vector2(0,-70)
 var floor_center: Vector2=host.seat_anchor.contact_position()+Vector2(0,8)
 var agitation: float=danger*danger if holding else maxf(0,1-phase_age/.28) if rupture else 0
 var shake:=Vector2(sin(time*49),cos(time*61))*agitation*10
 if active:
  var rear: Texture2D=REAR
  var ground: Texture2D=GROUND
  var deform:=Vector2(1+sin(time*17)*agitation*.12,1+cos(time*23)*agitation*.09)
  host.draw_set_transform(center+shake,time*(.08+danger*.15),deform)
  host.draw_texture_rect(rear,Rect2(-Vector2.ONE*radius,Vector2.ONE*radius*2),false,Color(tint,strength))
  host.draw_set_transform(floor_center,0,Vector2(1,.27))
  host.draw_set_transform_matrix(Transform2D(0,Vector2(1,.27),0,floor_center)*Transform2D(-time*.13,Vector2.ZERO))
  var floor_radius: float=radius*1.2
  host.draw_texture_rect(ground,Rect2(-Vector2.ONE*floor_radius,Vector2.ONE*floor_radius*2),false,Color(1,1.25,1.8,strength*.82) if not failure else Color(tint,strength))
  host.draw_set_transform(Vector2.ZERO)
  if jackpot:
   var beam: Texture2D=BEAM
   if beam: host.draw_texture_rect(beam,Rect2(center.x-460,-10,920,1040),false,Color(1,.98,.8,.65))
  if rupture and phase_age<.22 and m.phase in ["loss","burst"]:
   host.draw_rect(Rect2(320,100,1035,850),Color(tint,.15*(1-phase_age/.22)))
 host.draw_texture_rect(host.character.texture(),host.seat_anchor.actor_rect(shake),false)
 if not active: return
 var spark: Texture2D=preload("res://assets/ui_v4/wisps_spark.png")
 var stream: Texture2D=preload("res://assets/ui_v4/wisps_stream.png")
 for side in [-1,1]:
  var dims:=Vector2(150+danger*100,400+danger*220)
  host.draw_texture_rect(stream,Rect2(center+Vector2(side*220-dims.x*.5,-160),dims),false,Color(tint,strength*.55))
 var count: int=110 if jackpot else 30+int(danger*65) if holding else 64
 for i in count:
  var angle: float=i*2.399+time*(.28+danger*.7)
  var cycle: float=fposmod(time*(.25+danger*.45)+i*.137,1.0)
  var escaping: bool=rupture or result or (i%3==0 and danger>.25)
  var distance: float=lerpf(65,radius*1.1,cycle) if escaping else lerpf(radius,70,cycle)
  var pos: Vector2=center+Vector2(cos(angle)*distance,sin(angle)*distance*.75)+Vector2(0,-cycle*65)
  var dim: float=12+danger*9+(9 if jackpot else 0)
  host.draw_texture_rect(spark,Rect2(pos-Vector2.ONE*dim*.5,Vector2.ONE*dim),false,Color(tint,strength*sin(cycle*PI)))
