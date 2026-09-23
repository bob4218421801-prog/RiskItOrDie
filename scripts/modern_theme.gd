extends RefCounted
const TEXT := Color("eff3e6")
const MUTED := Color("c3d7d1")
const JADE := Color("a3d7bf")
const GOLD := Color("e1cc97")
static func panel(fill: Color = Color("34575bdb"), edge: Color = Color("adb99b99")) -> StyleBoxFlat:
 var s := StyleBoxFlat.new()
 s.bg_color = fill
 s.border_color = edge
 s.set_border_width_all(1)
 s.set_corner_radius_all(16)
 s.content_margin_left = 28
 s.content_margin_right = 28
 s.content_margin_top = 20
 s.content_margin_bottom = 20
 return s
static func theme() -> Theme:
 var t := Theme.new()
 var f := SystemFont.new()
 f.font_names = PackedStringArray(["Microsoft JhengHei", "Noto Sans CJK TC", "Microsoft YaHei"])
 t.default_font = f
 t.default_font_size = 28
 t.set_color("font_color", "Label", TEXT)
 t.set_stylebox("panel", "PanelContainer", panel())
 for state in ["normal", "hover", "pressed", "disabled"]:
  t.set_stylebox(state, "Button", button_skin(state))
 var focus := panel(Color.TRANSPARENT,GOLD)
 focus.set_corner_radius_all(14)
 focus.set_border_width_all(2)
 t.set_stylebox("focus","Button",focus)
 for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]: t.set_color(state, "Button", TEXT)
 t.set_color("font_disabled_color", "Button", Color("91a1a4"))
 return t
static func button(b: Button) -> void:
 for state in ["normal", "hover", "pressed", "disabled", "focus"]: b.remove_theme_stylebox_override(state)
 for state in ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color", "font_focus_color"]: b.remove_theme_color_override(state)
 b.add_theme_font_size_override("font_size", 28)
 b.custom_minimum_size.y = 64
 b.focus_mode = Control.FOCUS_ALL

static func button_skin(state: String = "normal") -> StyleBoxTexture:
 var s := StyleBoxTexture.new()
 s.texture = load("res://assets/ui/modern/jade_"+state+".svg")
 s.texture_margin_left = 72;s.texture_margin_right = 72
 s.texture_margin_top = 25;s.texture_margin_bottom = 25
 s.content_margin_left = 36;s.content_margin_right = 36
 s.content_margin_top = 16 if state == "pressed" else 14;s.content_margin_bottom = 12 if state == "pressed" else 14
 return s
static func primary(b: Button) -> void:
 b.add_theme_stylebox_override("normal",button_skin("primary"))
 b.add_theme_stylebox_override("hover",button_skin("primary_hover"))
 b.add_theme_color_override("font_color",Color("163f43"))
 b.add_theme_color_override("font_hover_color",Color("163f43"))
 b.add_theme_color_override("font_focus_color",Color("163f43"))
 var focus := button_skin("primary_hover")
 focus.modulate_color = Color(1,1,1,.20)
 b.add_theme_stylebox_override("focus",focus)
 b.add_theme_font_size_override("font_size",32)
static func small(b: Button) -> void:
 b.custom_minimum_size.y = 48
 b.add_theme_font_size_override("font_size",24)
 for state in ["normal","hover","pressed","disabled"]:
  var s := button_skin(state)
  s.content_margin_left = 18;s.content_margin_right = 18
  s.content_margin_top = 7;s.content_margin_bottom = 7
  b.add_theme_stylebox_override(state,s)

static func leaf(kind: String = "dialogue") -> StyleBoxTexture:
 var s := StyleBoxTexture.new()
 s.texture = load("res://assets/ui/modern/"+kind+"_leaf.svg")
 s.texture_margin_left = 48;s.texture_margin_right = 48
 s.texture_margin_top = 48;s.texture_margin_bottom = 48
 s.content_margin_left = 36;s.content_margin_right = 36
 s.content_margin_top = 36;s.content_margin_bottom = 36
 return s
