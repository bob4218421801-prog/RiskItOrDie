extends Control
## A swappable lane visual; the race model alone determines position/outcome.
var race: RefCounted
var index := 0
var art: TextureRect
func _ready():
 custom_minimum_size = Vector2(500,62)
 size_flags_horizontal = Control.SIZE_EXPAND_FILL
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 art = preload("res://scripts/ink_assets.gd").sprite(preload("res://scripts/ink_assets.gd").sword(index))
 art.size = Vector2(180,58);add_child(art)
func _process(_delta):
 art.position = Vector2(lerpf(90,size.x-100,race.progress(index))-90,2)
 queue_redraw()
func _draw():
 var colors := [Color("76dfc2"),Color("e99382"),Color("b9cce7"),Color("c5a0ea"),Color("e8c67e")]
 var color: Color = colors[index]
 var origin := Vector2(28,size.y*.5)
 var finish := Vector2(size.x-45,origin.y)
 draw_line(origin,finish,Color("8d8064"),2,true)
 draw_line(finish+Vector2(0,-21),finish+Vector2(0,21),Color("564a38"),2,true)
 var point: Vector2 = origin.lerp(finish,race.progress(index))
 draw_line(point-Vector2(50,0),point-Vector2(19,0),Color(color,.3),7,true)
