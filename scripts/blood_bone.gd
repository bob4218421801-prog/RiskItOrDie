extends Control
var number := 0
var jade := false
var glyph: Label
var art: TextureRect
var art_key := ""
func _ready():
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 art = preload("res://scripts/ink_assets.gd").sprite(load("res://assets/ui_v4/bone_jade.png"))
 art.position = Vector2(-104,-132);art.size = Vector2(208,264);add_child(art)
 glyph = Label.new()
 glyph.position = Vector2(-75,-75)
 glyph.size = Vector2(150,150)
 glyph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 glyph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
 glyph.add_theme_font_size_override("font_size",66)
 glyph.add_theme_color_override("font_color",Color("e9d9bf"))
 add_child(glyph)
func _process(_delta):
 glyph.modulate = Color("315d50") if jade else Color("f4dcab")
 var key := str(jade)+str(number > 0)
 if key != art_key:
  art_key = key
  art.texture=load("res://assets/ui_v4/bone_jade.png" if jade else "res://assets/ui_v4/bone_demonic.png")
 glyph.text = str(number) if number > 0 else "·"
 queue_redraw()
func _draw():
 var points := PackedVector2Array([Vector2(-76,-94),Vector2(67,-89),Vector2(88,-48),Vector2(74,96),Vector2(-67,91),Vector2(-88,48)])
 for i in range(points.size()): points[i] *= .76
 pass
