extends RefCounted
## Formal home art: exclusively Meowa PNGs. See assets/ui_v2/home/manifest.json.
const ROOT := "res://assets/ui_v2/home/"
const TEXT := Color("ecf1e5")
const MUTED := Color("c0d1c9")
const JADE := Color("bedecb")
const GOLD := Color("e2d2a7")
static func skin(file: String, margin: int = 22) -> StyleBoxTexture:
 var s := StyleBoxTexture.new();s.texture = load(ROOT+file+".png")
 for side in [SIDE_LEFT,SIDE_RIGHT,SIDE_TOP,SIDE_BOTTOM]:
  s.set_texture_margin(side,0);s.set_content_margin(side,14)
 return s
static func button_skin(state: String = "normal") -> StyleBoxTexture:
 return skin("nav_"+state,22)
static func theme() -> Theme:
 var t := Theme.new();preload("res://scripts/ui_typography.gd").apply(t)
 t.set_color("font_color","Label",TEXT)
 var panel := skin("book",34)
 panel.texture_margin_left = 76;panel.texture_margin_right = 32
 panel.texture_margin_top = 40;panel.texture_margin_bottom = 40
 panel.content_margin_left = 100;panel.content_margin_right = 36
 panel.content_margin_top = 42;panel.content_margin_bottom = 38
 t.set_stylebox("panel","PanelContainer",panel)
 for state in ["normal","hover","pressed","disabled"]: t.set_stylebox(state,"Button",skin("small_"+state))
 var focus := skin("small_hover");focus.modulate_color.a = .25;t.set_stylebox("focus","Button",focus)
 for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]: t.set_color(state,"Button",TEXT)
 t.set_color("font_disabled_color","Button",Color("84938d"))
 return t
static func button(b: Button) -> void:
 for state in ["normal","hover","pressed","disabled"]: b.add_theme_stylebox_override(state,button_skin(state))
 var focus := button_skin("hover");focus.modulate_color.a = .25;b.add_theme_stylebox_override("focus",focus)
 b.add_theme_font_override("font",preload("res://scripts/ui_typography.gd").EMPHASIS)
 b.add_theme_font_size_override("font_size",26);b.custom_minimum_size.y = 50
 for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]: b.add_theme_color_override(state,TEXT)
static func primary(b: Button) -> void:
 for state in ["normal","hover","pressed","disabled"]: b.add_theme_stylebox_override(state,skin("primary_"+state,36))
 var focus := skin("primary_hover");focus.modulate_color.a = .2;b.add_theme_stylebox_override("focus",focus)
 b.add_theme_font_size_override("font_size",30)
 for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]: b.add_theme_color_override(state,Color("214a43"))
static func small(b: Button) -> void:
 b.custom_minimum_size.y = 42;b.add_theme_font_size_override("font_size",23)
 for state in ["normal","hover","pressed","disabled"]:
  var surface := skin("small_"+state)
  surface.content_margin_top = 8;surface.content_margin_bottom = 8
  surface.content_margin_left = 24;surface.content_margin_right = 24
  b.add_theme_stylebox_override(state,surface)
 var focus := skin("small_hover");focus.modulate_color.a = .2;b.add_theme_stylebox_override("focus",focus)
