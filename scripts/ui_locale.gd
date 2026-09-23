extends Node
signal language_changed
var tag := "zh-Hans"
var resources: Array[Translation]=[]
func _ready() -> void:
 for code in ["zh-Hans","zh-Hant"]:
  var resource = preload("res://scripts/ui_translation.gd").new()
  resource.configure(code)
  TranslationServer.add_translation(resource)
  resources.append(resource)
 set_language("zh-Hans")
 get_tree().node_added.connect(_node_added)
func _exit_tree() -> void:
 # Release script-backed translations while the scripting runtime is still alive.
 for resource in resources: TranslationServer.remove_translation(resource)
 resources.clear()
func set_language(value: String) -> void:
 tag = "zh-Hant" if value.replace("_","-") in ["zh-Hant","zh-TW"] else "zh-Hans"
 TranslationServer.set_locale("zh_CN" if tag == "zh-Hans" else "zh_TW")
 _apply_tree(get_tree().root)
 language_changed.emit()
func _node_added(node: Node) -> void:
 if node is Control: _apply_font.call_deferred(node)
func _apply_tree(node: Node) -> void:
 if node is Control: _apply_font(node)
 for child in node.get_children(): _apply_tree(child)
func _apply_font(node: Node) -> void:
 if not is_instance_valid(node) or not node is Control: return
 var region := "TC" if tag == "zh-Hant" else "SC"
 var properties := ["normal_font","bold_font"] if node is RichTextLabel else ["font"]
 for property in properties:
  var font: Font = node.get_theme_font(property)
  if font and "SourceHan" in font.resource_path:
   var path := font.resource_path.replace("SC-",region+"-").replace("TC-",region+"-")
   if ResourceLoader.exists(path): node.add_theme_font_override(property,load(path))
