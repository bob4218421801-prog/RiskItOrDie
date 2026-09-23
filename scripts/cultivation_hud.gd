extends Control
var realm: Label
var stones: Label
var age: Label
var cultivation: Label
var left: HBoxContainer
func _ready() -> void:
 mouse_filter=MOUSE_FILTER_IGNORE
 position=Vector2(490,42);size=Vector2(1050,52)
 left=HBoxContainer.new();left.size=Vector2(465,52);left.clip_contents=true;left.add_theme_constant_override("separation",12);add_child(left)
 realm=label(left);label(left).text="｜";stones=label(left);label(left).text="｜";age=label(left)
 var right := HBoxContainer.new();right.position=Vector2(555,2);right.size=Vector2(495,52);right.clip_contents=true;add_child(right)
 cultivation=label(right);cultivation.size_flags_horizontal=Control.SIZE_EXPAND_FILL;cultivation.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
func label(parent: Node) -> Label:
 var l:=Label.new();l.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;l.mouse_filter=MOUSE_FILTER_IGNORE;parent.add_child(l);return l
func refresh(host: Control) -> void:
 var m=host.run
 realm.text=host.C.REALMS[m.realm]
 stones.text=tr("hud.stones")+" "+host.format_number(m.spirit_stones)
 age.text="%.1f / %.0f %s"%[m.age,m.lifespan,tr("hud.years")]
 render_cultivation(host,m.cultivation,m.requirement())
 var pixels:=22
 while pixels>15 and left_width(pixels)>465: pixels-=1
 for l in left.get_children(): l.add_theme_font_size_override("font_size",pixels)
func render_cultivation(host: Control, current: int, required: int):
 cultivation.text=tr("hud.cultivation")+" "+host.format_number(current)+" / "+host.format_number(required)
 var pixels:=22
 while pixels>15 and cultivation.get_theme_font("font").get_string_size(cultivation.tr(cultivation.text),HORIZONTAL_ALIGNMENT_LEFT,-1,pixels).x>490: pixels-=1
 cultivation.add_theme_font_size_override("font_size",pixels)
func left_width(pixels: int) -> float:
 var width:=48.0
 for l in left.get_children(): width+=l.get_theme_font("font").get_string_size(l.tr(l.text),HORIZONTAL_ALIGNMENT_LEFT,-1,pixels).x
 return width
