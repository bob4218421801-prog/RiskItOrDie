extends "res://scripts/art_hit_button.gd"
const R=preload("res://scripts/foundation_rules.gd")
const FONT=preload("res://scripts/ui_typography.gd")
var rune:="灵"
var locked:=false
var committed:=false
var glow:=0.0
var fade:=1.0
var tile: Texture2D
var icons: Array=[]
func _ready():
 super._ready()
 tile=load("res://assets/foundation_v8/tile.png");set_hit_texture(tile)
 for i in range(9):icons.append(load("res://assets/foundation_v8/rune_%d.png"%i))
 for mode in ["normal","hover","pressed","disabled","focus"]:add_theme_stylebox_override(mode,StyleBoxEmpty.new())
 mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 mouse_entered.connect(queue_redraw);mouse_exited.connect(queue_redraw);button_down.connect(queue_redraw);button_up.connect(queue_redraw)
func _draw():
 if tile==null:return
 var hover: bool=is_hovered() and not disabled
 var tint:=Color(1.3,1.16,.8) if locked else Color(1.16,1.3,1.2) if hover else Color.WHITE
 if is_pressed():tint*=.8
 draw_texture_rect(tile,Rect2(Vector2.ZERO,size),false,tint)
 var c:=Color("ffe49e") if locked else Color("a5ecda")
 if locked or hover or glow>0:
  for j in range(4):draw_arc(size*.5, size.x*.43+j*2,0,TAU,80,Color(c, .7/(j+1)+glow*.07),2,true)
 draw_texture_rect(icons[R.PATTERNS.find(rune)],Rect2(size*Vector2(.27,.37),size*Vector2(.46,.49)),false,Color(1,1,1,fade))
 draw_string(FONT.TITLE,Vector2(size.x*.5-24,65),rune,HORIZONTAL_ALIGNMENT_LEFT,-1,48,Color(c,fade))
 if locked:
  var p:=Vector2(size.x-29,24)
  draw_circle(p,21,Color("163c35"));draw_arc(p,21,0,TAU,40,c,2,true)
  draw_arc(p+Vector2(0,-5),7,PI,TAU,20,c,3,true)
  draw_rect(Rect2(p+Vector2(-9,-5),Vector2(18,16)),c)
  draw_circle(p+Vector2(0,2),2,Color("163c35"))
  draw_line(p+Vector2(0,3),p+Vector2(0,8),Color("163c35"),2)
