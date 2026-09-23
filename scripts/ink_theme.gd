extends RefCounted
const A = preload("res://scripts/ink_assets.gd")
const TEXT = Color("2c302a")
const LIGHT = Color("eee4cd")
static func box(index: int = 0) -> StyleBoxTexture:
 var b := StyleBoxTexture.new();b.texture = A.panel(index)
 for edge in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
  b.set_texture_margin(edge,40)
  b.set_content_margin(edge,24)
 return b
static func button_box(row: int, col: int) -> StyleBoxTexture:
 var b := StyleBoxTexture.new();b.texture = A.button(row,col)
 b.texture_margin_left = 85;b.texture_margin_right = 85
 b.texture_margin_top = 34;b.texture_margin_bottom = 34
 b.content_margin_left = 30;b.content_margin_right = 30;b.content_margin_top = 13;b.content_margin_bottom = 13
 return b
static func apply_button(b: Button, primary: bool = false):
 var row := 0 if primary else 1
 for mode in ["normal","hover","pressed","disabled","focus"]:
  if mode == "focus":
   var focus := StyleBoxFlat.new();focus.bg_color = Color.TRANSPARENT;focus.border_color = Color("dcac55");focus.set_border_width_all(2);focus.set_corner_radius_all(12);b.add_theme_stylebox_override(mode,focus)
  else: b.add_theme_stylebox_override(mode,button_box(3 if mode == "disabled" else row,1 if mode == "hover" else (2 if mode == "pressed" else 0)))
 for key in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]: b.add_theme_color_override(key,LIGHT if primary else TEXT)
 b.add_theme_color_override("font_disabled_color",Color("656762"))
 b.add_theme_font_size_override("font_size",28)
static func theme() -> Theme:
 var t := Theme.new();t.default_font_size = 28
 var font := SystemFont.new();font.font_names = PackedStringArray(["DFKai-SB","KaiTi","Microsoft JhengHei"]);t.default_font = font
 t.set_color("font_color","Label",TEXT)
 t.set_color("font_color","RichTextLabel",TEXT)
 t.set_constant("line_spacing","Label",6)
 t.set_stylebox("panel","Panel",box())
 t.set_stylebox("panel","PanelContainer",box())
 var sample := Button.new();apply_button(sample)
 for mode in ["normal","hover","pressed","disabled","focus"]: t.set_stylebox(mode,"Button",sample.get_theme_stylebox(mode))
 for color in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_disabled_color"]: t.set_color(color,"Button",sample.get_theme_color(color))
 sample.free()
 for key in ["normal","focus"]: t.set_stylebox(key,"LineEdit",box(1))
 t.set_color("font_color","LineEdit",LIGHT)
 return t
