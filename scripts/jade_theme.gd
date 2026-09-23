extends RefCounted
static func panel() -> StyleBoxTexture: return preload("res://scripts/ink_theme.gd").box()
static func apply_button(b: Button): preload("res://scripts/ink_theme.gd").apply_button(b)
static func apply_tree(node: Node):
 if node is Button: apply_button(node)
 for child in node.get_children(): apply_tree(child)
