extends PanelContainer
var speaker_label: Label
var body_label: Label
var next_button: Button
signal continued
func _ready():
 var style := StyleBoxFlat.new();style.bg_color = Color("172e39");style.border_color = Color("81ac9c");style.set_border_width_all(2)
 for edge in [SIDE_LEFT,SIDE_RIGHT,SIDE_TOP,SIDE_BOTTOM]: style.set_content_margin(edge,18)
 add_theme_stylebox_override("panel",style)
 var rows := VBoxContainer.new();rows.add_theme_constant_override("separation",10);add_child(rows)
 speaker_label = Label.new();speaker_label.add_theme_font_size_override("font_size",25);speaker_label.modulate = Color("f1cd8b");rows.add_child(speaker_label)
 body_label = Label.new();body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;body_label.add_theme_font_size_override("font_size",26);body_label.add_theme_constant_override("line_spacing",5);rows.add_child(body_label)
 next_button = Button.new();next_button.text = "繼續";next_button.custom_minimum_size.y = 48;next_button.add_theme_font_size_override("font_size",24);next_button.pressed.connect(func(): continued.emit());rows.add_child(next_button)
func show_text(who: String, words: String, can_continue: bool = false):
 speaker_label.text = who;body_label.text = words;next_button.visible = can_continue
