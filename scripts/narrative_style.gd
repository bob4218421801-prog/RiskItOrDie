extends RefCounted
const INK = Color("2c302a")
const GOLD = Color("806238")
static func panel() -> StyleBoxTexture: return preload("res://scripts/ink_theme.gd").box(2)
static func theme() -> Theme: return preload("res://scripts/ink_theme.gd").theme()
static func fade_in(node: Control) -> Tween:
 node.modulate.a = 0
 var tween := node.create_tween();tween.tween_property(node,"modulate:a",1.0,.18)
 return tween
