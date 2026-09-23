extends RefCounted
## Logical pixels at 1920x1080; shared by every game theme.
const BODY = preload("res://assets/fonts/SourceHanSansSC-Regular.otf")
const EMPHASIS = preload("res://assets/fonts/SourceHanSansSC-Medium.otf")
const TITLE = preload("res://assets/fonts/SourceHanSerifSC-SemiBold.otf")
const SIZES = {"logo":40,"title":28,"button":26,"body":26,"small":22}
static func apply(t: Theme) -> void:
 t.default_font = BODY
 t.default_font_size = SIZES.body
 for type in ["Button","OptionButton","CheckButton","SpinBox"]:
  t.set_font("font",type,EMPHASIS)
 t.set_font("normal_font","RichTextLabel",BODY)
 t.set_font("bold_font","RichTextLabel",EMPHASIS)
 t.set_constant("line_spacing","Label",6)
 t.set_constant("line_separation","RichTextLabel",6)
static func title(label: Label) -> void:
 label.add_theme_font_override("font",TITLE)
 label.add_theme_font_size_override("font_size",SIZES.title)
