extends Control
const ACCESS=preload("res://scripts/inventory_access.gd")
const ART=preload("res://scripts/migration_art.gd")
var model: RefCounted
var opened:=false
var entry: Button
var panel: PanelContainer
var rows: GridContainer
var detail: VBoxContainer
var stamp:=""
var slide: Tween
var category:="全部"
var selected:=""
var category_buttons: Array[Button]=[]
func _ready():
 name="InventoryDrawer";set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);mouse_filter=MOUSE_FILTER_IGNORE
 entry=Button.new();entry.text="背包";entry.position=Vector2(1650,20);entry.size=Vector2(220,55);ART.T.small(entry);add_child(entry);entry.pressed.connect(func(): set_open(not opened))
 panel=PanelContainer.new();panel.position=Vector2(220,130);panel.size=Vector2(1480,850);panel.add_theme_stylebox_override("panel",ART.skin("frame",115));add_child(panel)
 var v:=VBoxContainer.new();v.add_theme_constant_override("separation",20);panel.add_child(v)
 var top:=HBoxContainer.new();v.add_child(top)
 var balance:=Control.new();balance.custom_minimum_size.x=200;top.add_child(balance)
 var title:=ART.label("行囊",36);title.size_flags_horizontal=SIZE_EXPAND_FILL;title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;top.add_child(title)
 var close:=Button.new();close.text="收起行囊";close.custom_minimum_size=Vector2(200,60);ART.T.small(close);top.add_child(close);close.pressed.connect(func(): set_open(false))
 var categories:=HBoxContainer.new();categories.alignment=BoxContainer.ALIGNMENT_CENTER;categories.add_theme_constant_override("separation",14);v.add_child(categories)
 for key in ["全部","消耗品","问剑","材料","丹药","其他"]:
  var id: String=key;var b:=Button.new();b.text=key;b.custom_minimum_size=Vector2(148,56);b.toggle_mode=true;ART.T.small(b);categories.add_child(b);category_buttons.append(b);b.pressed.connect(func(): category=id;stamp="";refresh())
 var split:=HBoxContainer.new();split.size_flags_vertical=SIZE_EXPAND_FILL;split.add_theme_constant_override("separation",40);v.add_child(split)
 var scroll:=ScrollContainer.new();scroll.custom_minimum_size.x=870;scroll.size_flags_vertical=SIZE_EXPAND_FILL;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;split.add_child(scroll)
 var grid_center:=HBoxContainer.new();grid_center.size_flags_horizontal=SIZE_EXPAND_FILL;grid_center.size_flags_vertical=SIZE_EXPAND_FILL;grid_center.alignment=BoxContainer.ALIGNMENT_CENTER;scroll.add_child(grid_center)
 rows=GridContainer.new();rows.columns=4;rows.size_flags_vertical=SIZE_SHRINK_CENTER;rows.add_theme_constant_override("h_separation",16);rows.add_theme_constant_override("v_separation",24);grid_center.add_child(rows)
 detail=VBoxContainer.new();detail.custom_minimum_size.x=340;detail.size_flags_horizontal=SIZE_EXPAND_FILL;detail.add_theme_constant_override("separation",18);split.add_child(detail);panel.hide()
func set_open(value: bool):
 if value and (not ACCESS.allowed(model) or not model.modal.is_empty()): return
 opened=value;mouse_filter=MOUSE_FILTER_STOP if value else MOUSE_FILTER_IGNORE;panel.visible=value
 if value: stamp="";refresh()
func refresh():
 entry.visible=ACCESS.allowed(model) and model.state not in ["dead","complete","foundation_ready","foundation"] and model.activity_id not in ["flying_boat","sword_race","mines","duel"]
 entry.disabled=not model.modal.is_empty() or model.bone_target_pending or model.state=="holding"
 if not entry.visible or not model.modal.is_empty():
  if opened: set_open(false)
 if not opened: return
 var items: Array=ACCESS.entries(model)
 var key: String=str(items)+model.state+str(model.realm)+category+str(model.blood.relic_used if model.blood!=null else {})+str(model.duel.skill_used if model.duel!=null else {})
 if key==stamp: return
 stamp=key
 for i in range(category_buttons.size()): category_buttons[i].set_pressed_no_signal(category_buttons[i].text==category)
 for c in rows.get_children(): rows.remove_child(c);c.queue_free()
 var shown: Array=[]
 for item in items:
  if category!="全部" and ART.category(model,item.key)!=category: continue
  shown.append(item)
  var id: String=item.key;var b:=Button.new();b.custom_minimum_size=Vector2(200,205);b.tooltip_text=""
  for state in ["normal","hover","pressed","disabled","focus"]:
   var skin=ART.skin("slot",16);skin.modulate_color=Color(1.08,1.08,1) if state in ["hover","focus"] else Color.WHITE;b.add_theme_stylebox_override(state,skin)
  rows.add_child(b)
  var art:=ART.picture(ART.item_icon(model,id),Vector2.ZERO);art.position=Vector2(45,18);art.size=Vector2(110,110);b.add_child(art)
  var name_label:=ART.label(id,22,false);name_label.position=Vector2(15,130);name_label.size=Vector2(170,35);name_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;name_label.mouse_filter=MOUSE_FILTER_IGNORE;b.add_child(name_label)
  var count:=ART.label("× "+str(item.count),21,false);count.position=Vector2(12,164);count.size=Vector2(176,28);count.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;count.mouse_filter=MOUSE_FILTER_IGNORE;b.add_child(count)
  b.pressed.connect(func(): selected=id;show_detail(item))
 if shown.is_empty(): rows.add_child(ART.label("这里暂时没有物品。",25));show_detail({})
 else:
  var chosen: Dictionary=shown[0]
  for item in shown:
   if item.key==selected: chosen=item
  selected=chosen.key;show_detail(chosen)
func show_detail(item: Dictionary):
 for c in detail.get_children(): detail.remove_child(c);c.queue_free()
 if item.is_empty():
  var empty:=ART.label("历练所得，皆收于此。",26);empty.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;empty.size_flags_vertical=SIZE_EXPAND_FILL;empty.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;detail.add_child(empty);return
 var id: String=item.key
 detail.add_child(ART.picture(ART.item_icon(model,id),Vector2(220,180)))
 detail.add_child(ART.label(id,30));detail.add_child(ART.label(ART.category(model,id)+" · 数量 "+str(item.count),22));detail.add_child(ART.label(item.detail,25))
 for child in detail.get_children():
  if child is Label: child.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 var choices: OptionButton=null
 if id=="定命符" and model.activity_id=="blood":
  choices=OptionButton.new()
  for point in model.B.POINTS: choices.add_item("生门 %d"%point,point)
  ART.T.small(choices);detail.add_child(choices)
 var use:=Button.new();use.text="使用" if ACCESS.usable(model,id) else "当前不可使用";use.disabled=not ACCESS.usable(model,id);use.custom_minimum_size=Vector2(240,60);use.size_flags_horizontal=SIZE_SHRINK_CENTER;ART.T.small(use);detail.add_child(use)
 use.pressed.connect(func():
  if not ACCESS.usable(model,id): return
  if id=="換命符": model.bone_target_pending=true;set_open(false)
  elif id==model.BREAKTHROUGH_PILL: model.use_breakthrough_pill();set_open(false)
  elif id in model.sect.C.CARDS: model.duel_skill(model.sect.C.CARDS.find(id),true);set_open(false)
  else: model.use_relic(id,choices.get_selected_id() if choices!=null else 0);stamp="";refresh())
func _gui_input(event):
 if event is InputEventMouseButton and event.pressed and opened and not panel.get_rect().has_point(event.position): set_open(false);accept_event()
func _input(event):
 if opened and event.is_action_pressed("ui_cancel"): set_open(false);get_viewport().set_input_as_handled()
