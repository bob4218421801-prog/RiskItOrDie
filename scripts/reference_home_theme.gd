extends RefCounted
## Generated PNGs only. Source jobs/crops: assets/ui_v3/reference_home/manifest.json.
const ROOT := "res://assets/ui_v3/reference_home/"
const TEXT := Color("f4f0df")
const MUTED := Color("b9c9bc")
const JADE := Color("c9e6d8")
const GOLD := Color("e5d2a1")
const INK := Color("29372f")
const FONT = preload("res://scripts/ui_typography.gd")
static func skin(file: String) -> StyleBoxTexture:
 var s := StyleBoxTexture.new();s.texture = load(ROOT+file+".png")
 for side in [SIDE_LEFT,SIDE_RIGHT]: s.set_content_margin(side,24)
 for side in [SIDE_TOP,SIDE_BOTTOM]: s.set_content_margin(side,8)
 return s
static func button_skin(state: String = "normal") -> StyleBoxTexture: return skin("nav_"+state)
static func theme() -> Theme:
 var t := Theme.new();FONT.apply(t)
 t.set_color("font_color","Label",TEXT)
 for state in ["normal","hover","pressed","disabled"]: t.set_stylebox(state,"Button",skin("small_"+state))
 for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]: t.set_color(state,"Button",TEXT)
 t.set_color("font_hover_color","Button",INK)
 t.set_color("font_disabled_color","Button",Color("96a69b"))
 t.set_stylebox("focus","Button",StyleBoxEmpty.new())
 var panel := skin("destiny_scroll")
 # Scroll ornament is a fixed-proportion image, never nine-slice its rods/tassels.
 panel.content_margin_left=82;panel.content_margin_right=82
 panel.content_margin_top=112;panel.content_margin_bottom=100
 t.set_stylebox("panel","PanelContainer",panel)
 return t
static func button(b: Button) -> void:
 for state in ["normal","hover","pressed","disabled"]: b.add_theme_stylebox_override(state,button_skin(state))
 b.add_theme_font_override("font",FONT.TITLE);b.add_theme_font_size_override("font_size",30)
 b.add_theme_stylebox_override("focus",StyleBoxEmpty.new())
static func small(b: Button) -> void:
 for state in ["normal","hover","pressed","disabled"]: b.add_theme_stylebox_override(state,skin("small_"+state))
 b.add_theme_stylebox_override("focus",StyleBoxEmpty.new())
 b.add_theme_font_override("font",FONT.TITLE);b.add_theme_font_size_override("font_size",23)
 for state in ["font_color","font_pressed_color","font_focus_color"]: b.add_theme_color_override(state,TEXT)
 b.add_theme_color_override("font_hover_color",INK)
 b.add_theme_color_override("font_disabled_color",Color("aebcaf"))
static func primary(b: Button) -> void:
 for state in ["normal","hover","pressed","disabled"]:
  var plate := skin("primary_"+state);plate.content_margin_top=24;plate.content_margin_bottom=6
  b.add_theme_stylebox_override(state,plate)
 b.add_theme_font_override("font",FONT.TITLE);b.add_theme_font_size_override("font_size",32)
 for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]: b.add_theme_color_override(state,INK)
