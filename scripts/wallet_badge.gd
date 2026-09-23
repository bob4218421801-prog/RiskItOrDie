extends Control
const FONT=preload("res://scripts/ui_typography.gd")
var value: Label
var model: RefCounted
var compact:=false
func _ready():
 mouse_filter=MOUSE_FILTER_IGNORE
 var art:=TextureRect.new();art.texture=preload("res://assets/ui_v6/wallet.png");art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);art.mouse_filter=MOUSE_FILTER_IGNORE;add_child(art)
 value=Label.new();value.mouse_filter=MOUSE_FILTER_IGNORE;value.add_theme_font_override("font",FONT.TITLE);value.add_theme_color_override("font_color",Color("fff3d9"));value.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;value.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;add_child(value)
 resized.connect(layout);layout()
func layout():
 if value==null:return
 value.position=Vector2(size.x*.2,size.y*.1);value.size=Vector2(size.x*.75,size.y*.78)
 value.add_theme_font_size_override("font_size",20 if compact else 26)
func _process(_delta):
 if model==null:return
 var amount: int=model.spirit_stones
 var number: String=str(amount)
 if not compact:
  var groups:=PackedStringArray()
  while number.length()>3: groups.insert(0,number.right(3));number=number.left(number.length()-3)
  groups.insert(0,number);number=",".join(groups)
 if compact and amount>=100000000: number="%.2f亿"%(amount/100000000.0)
 elif compact and amount>=100000: number="%.2f万"%(amount/10000.0)
 value.text="灵石 "+number
