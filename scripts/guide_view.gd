extends Control
const STYLE = preload("res://scripts/narrative_style.gd")
var previous_key := ""
var scroll: ScrollContainer
var model: RefCounted
var title: Label
var text: Label
var go: Button
var close: Button
var panel: PanelContainer
var dim: ColorRect
func _ready():
 name = "SystemExplanationModal"
 theme = STYLE.theme()
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter = Control.MOUSE_FILTER_STOP
 dim = ColorRect.new()
 dim.color = Color(0,0,0,.35)
 dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(dim)
 var opening := preload("res://scripts/opening_backdrop.gd").new();opening.model = model;add_child(opening)
 panel = PanelContainer.new()
 panel.position = Vector2(380,240)
 panel.size = Vector2(1160,600)
 var style := STYLE.panel()
 panel.add_theme_stylebox_override("panel",style)
 add_child(panel)
 var margin := MarginContainer.new()
 for edge in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+edge,35)
 panel.add_child(margin)
 var rows := VBoxContainer.new()
 rows.add_theme_constant_override("separation",25)
 margin.add_child(rows)
 title = Label.new()
 title.add_theme_font_size_override("font_size",38)
 rows.add_child(title)
 text = Label.new()
 text.add_theme_font_size_override("font_size",27)
 text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 text.size_flags_vertical = Control.SIZE_EXPAND_FILL
 scroll = ScrollContainer.new()
 scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
 scroll.custom_minimum_size = Vector2(0,170)
 rows.add_child(scroll)
 text.custom_minimum_size.x = 1060
 text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 scroll.add_child(text)
 go = Button.new()
 go.custom_minimum_size.y = 65
 go.add_theme_font_size_override("font_size",28)
 go.pressed.connect(func(): model.result_secondary())
 rows.add_child(go)
 close = Button.new()
 close.text = "明白了 / 確認結果"
 close.custom_minimum_size.y = 70
 close.add_theme_font_size_override("font_size",28)
 close.pressed.connect(func(): model.acknowledge_modal())
 rows.add_child(close)
 refresh()
func refresh():
 visible = not model.modal.is_empty() and model.modal.get("kind","") != "waiting_help"
 if visible:
  var key := str(model.modal)
  if key != previous_key: STYLE.fade_in(self);previous_key = key
  var style: StyleBox = panel.get_theme_stylebox("panel")
  var opening: bool = model.modal.get("id","") == "opening" and model.modal.get("kind","") == "dialogue"
  panel.self_modulate.a = 0 if opening and model.modal.get("index",0) < 2 else 1
  var kind: String = model.modal.get("kind","")
  dim.color = Color(.16,.01,.035,.85) if kind == "blood_arrival" else Color(0,0,0,.35)
  var route: String = model.modal.get("route","")
  var choice: bool = kind == "dialogue" and model.modal.get("id","") == "junior_close"
  go.visible = choice or kind in ["festival","blood_arrival"] or route in ["repeat_activity","jade_exit"]
  go.disabled = false
  go.text = model.repeat_label() if route == "repeat_activity" else ("踏入血煞命局" if kind == "blood_arrival" else "參加大比")
  close.visible = kind != "blood_arrival"
  close.text = {"duel_active":"返回問劍榜","duel_passive":"返回修煉","tournament_next":"迎戰下一位","repeat_activity":"返回修煉","blood_exit":"返回修煉"}.get(route,"這次先不參加" if kind == "festival" else "明白了")
  if route == "jade_exit": go.text = "再玩一局"
  if choice: go.text = "就是來找你的"
  if kind == "dialogue": close.text = "順便而已" if choice else "繼續"
  if route in ["sect_return","senior_result"]: close.text = "返回宗門"
  if route == "jade_exit": close.text = "回宗門"
  if kind == "dialogue" and model.modal.get("id","") == "opening":
   dim.color = Color(0,0,0,1 if model.modal.index < 2 else .92)
  title.text = model.modal.title
  text.text = model.modal.text
  scroll.custom_minimum_size.y = clampf(70+text.text.length()*.7,120,300)
  panel.position.y = 300
  panel.custom_minimum_size.y = 0
  panel.size.y = 0
