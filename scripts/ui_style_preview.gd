extends Control
## Isolated art review. No game model, save file, production theme or scene changes.
const ROOT := "res://assets/ui_v2/meow_test/"
const TYPE = preload("res://scripts/ui_typography.gd")
var stake_slider: HSlider
var stake_value: Label
var preview_button: TextureButton
var status: Label
var dialogue_preview: Control
func label_at(parent: Node, words: String, rect: Rect2, font_size: int = 26, color: Color = Color("dce8df")) -> Label:
 var l := Label.new();l.text = words;l.position = rect.position;l.size = rect.size
 l.mouse_filter = Control.MOUSE_FILTER_IGNORE;l.add_theme_font_size_override("font_size",font_size);l.add_theme_color_override("font_color",color);parent.add_child(l);return l
func asset(file: String) -> Texture2D: return load(ROOT+file+".png")
func picture(node_name: String, file: String, rect: Rect2) -> TextureRect:
 var image := TextureRect.new();image.name = node_name;image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;image.texture = asset(file)
 image.position = rect.position;image.size = rect.size;image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 image.mouse_filter = Control.MOUSE_FILTER_IGNORE;add_child(image);return image
func nine(node_name: String, file: String, rect: Rect2, margin: int) -> NinePatchRect:
 var n := NinePatchRect.new();n.name = node_name;n.texture = asset(file);n.position = rect.position;n.scale = Vector2(.5,.5);n.size = rect.size*2
 for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]: n.set_patch_margin(side,margin)
 n.mouse_filter = Control.MOUSE_FILTER_IGNORE;add_child(n);return n
func _ready() -> void:
 theme = Theme.new();TYPE.apply(theme)
 var bg := ColorRect.new();bg.name = "PreviewBackdrop";bg.color = Color("26383c");bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);bg.mouse_filter = Control.MOUSE_FILTER_IGNORE;add_child(bg)
 label_at(self,"Meow UI 素材测试 · 仅供确认，不替换正式界面",Rect2(48,25,1760,55),34)
 label_at(self,"真实透明 PNG · 无烘焙功能文字 · 可操作按钮与下注滑杆",Rect2(50,83,1500,34),23,Color("a9c4bb"))
 label_at(self,"A  导航底板：默认 / 悬停 / 选中",Rect2(48,137,1050,36),25)
 for i in range(3):
  picture("NavigationState%d" % i,"ui_nav_plate_"+["default","hover","selected"][i],Rect2(50+i*390,177,350,155))
  label_at(self,["默认","悬停","选中"][i],Rect2(184+i*390,235,160,35),24)
 label_at(self,"B–G  功能小插图（独立 PNG）",Rect2(48,346,1050,36),25)
 var names := ["修炼","宗门","机缘","洞府","问剑","背包"]
 var files := ["cultivation","sect","opportunity","cave","duel","inventory"]
 for i in range(6):
  picture("Icon_"+files[i],"icon_"+files[i],Rect2(48+i*202,391,172,160))
  var caption := label_at(self,names[i],Rect2(48+i*202,556,172,38),24);caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 label_at(self,"I  修炼主按钮（按住测试）",Rect2(48,623,760,36),25)
 preview_button = TextureButton.new();preview_button.name = "PrimaryButton";preview_button.position = Vector2(46,660);preview_button.size = Vector2(565,176)
 preview_button.texture_normal = asset("ui_primary_button");preview_button.texture_hover = asset("ui_primary_button");preview_button.texture_pressed = asset("ui_primary_button");preview_button.ignore_texture_size = true;preview_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED;add_child(preview_button)
 var caption := label_at(preview_button,"按住修炼 · 放开收功",Rect2(40,64,485,45),28,Color("203e38"));caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 preview_button.button_down.connect(func(): preview_button.modulate = Color(.9,1,.95);status.text = "按下反馈 · 只测试 UI，不执行修炼")
 preview_button.button_up.connect(func(): preview_button.modulate = Color.WHITE;status.text = "松开反馈 · 未修改游戏数据")
 status = label_at(self,"按钮可按住；右侧滑杆可拖动",Rect2(60,823,1100,32),21,Color("a9c4bb"))
 label_at(self,"L  灵石下注滑杆（拖动测试）",Rect2(690,623,620,36),25)
 stake_slider = HSlider.new();stake_slider.name = "SpiritStoneStakeSlider";stake_slider.position = Vector2(705,708);stake_slider.size = Vector2(530,76);stake_slider.min_value = 0;stake_slider.max_value = 5000;stake_slider.step = 100;stake_slider.value = 1800;add_child(stake_slider)
 for name in ["slider","grabber_area","grabber_area_highlight"]:
  var style := StyleBoxTexture.new();style.texture = asset("ui_slider_track" if name == "slider" else "ui_slider_fill")
  style.texture_margin_left = 82;style.texture_margin_right = 82;style.content_margin_top = 25;style.content_margin_bottom = 25
  stake_slider.add_theme_stylebox_override(name,style)
 for name in ["grabber","grabber_highlight","grabber_disabled"]: stake_slider.add_theme_icon_override(name,asset("ui_slider_handle"))
 stake_value = label_at(self,"1,800 灵石  /  可选 0–5,000",Rect2(742,798,550,35),24)
 stake_slider.value_changed.connect(func(value: float): stake_value.text = "%d 灵石  /  可选 0–5,000" % int(value))
 label_at(self,"H  天命推演命簿 · 原比例",Rect2(1360,137,530,40),24)
 picture("FateBook","ui_panel_fatebook",Rect2(1370,183,480,664))
 TYPE.title(label_at(self,"天命推演",Rect2(1460,282,290,40),28,Color("e3d3a3")))
 label_at(self,"寿元\n16.0 / 25 岁\n\n尚可修炼\n约 90 次\n\n维持突破\n453,778 / 次\n\n天机未明",Rect2(1460,347,256,400),23)
 var next := Button.new();next.text = "J / K   查看对话底板与名字牌 →";next.position = Vector2(54,925);next.size = Vector2(740,66);add_child(next)
 label_at(self,"组件检查页，不是正式游戏布局。正式接入将在视觉确认后进行。",Rect2(56,1010,1730,38),23,Color("a9c4bb"))
 dialogue_preview = Control.new();dialogue_preview.name = "DialogueAssetReview";dialogue_preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(dialogue_preview)
 var paper := ColorRect.new();paper.color = Color("26383c");paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);paper.mouse_filter = Control.MOUSE_FILTER_IGNORE;dialogue_preview.add_child(paper)
 label_at(dialogue_preview,"J / K  对话底板与独立名字牌 · 按原始比例显示",Rect2(54,32,1800,65),32)
 label_at(dialogue_preview,"文字独立渲染；当前生成的底板偏高，先审核材质与边框，再确定正式横向规格。",Rect2(54,110,1800,48),25)
 var panel := picture("DialoguePanel","ui_dialogue_panel",Rect2(150,300,1610,720));panel.reparent(dialogue_preview)
 var plaque := picture("DialogueNameplate","ui_dialogue_nameplate",Rect2(305,294,390,185));plaque.reparent(dialogue_preview)
 TYPE.title(label_at(dialogue_preview,"小师妹",Rect2(438,359,190,45),28))
 label_at(dialogue_preview,"师兄，先看清手上的剑印，\n再决定要不要继续。",Rect2(385,542,1050,135),32,Color("2d4840"))
 label_at(dialogue_preview,"点击 / Enter / Space 继续",Rect2(1170,813,500,45),23,Color("536e63"))
 var close := Button.new();close.text = "← 返回组件总览";close.position = Vector2(54,207);close.size = Vector2(355,64);dialogue_preview.add_child(close)
 close.pressed.connect(func(): dialogue_preview.hide());next.pressed.connect(func(): dialogue_preview.show());dialogue_preview.hide()
