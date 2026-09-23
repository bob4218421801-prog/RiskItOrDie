extends VBoxContainer
## One shared stake selector. Draft values are committed only by Confirm.
const T = preload("res://scripts/modern_theme.gd")
var model: RefCounted
var free: SpinBox
var paid: HSlider
var info: Label
var sheet: Control
var confirm: Button
var amount: Label
var limits: Label
var origin := ""
var cached := ""
func _ready():
 theme = T.theme()
 add_theme_constant_override("separation",8)
 info = Label.new();info.add_theme_font_size_override("font_size",25);info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;add_child(info)
 var open := Button.new();open.text = "選擇下注靈石";T.small(open);add_child(open);open.pressed.connect(open_selector)
 var layer := CanvasLayer.new();layer.layer = 80;add_child(layer)
 sheet = Control.new();sheet.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);sheet.mouse_filter = Control.MOUSE_FILTER_STOP;layer.add_child(sheet)
 var shade := ColorRect.new();shade.color = Color(0.06,0.12,0.12,.48);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);shade.mouse_filter = Control.MOUSE_FILTER_STOP;sheet.add_child(shade)
 var panel := PanelContainer.new();panel.position = Vector2(450,270);panel.size = Vector2(1020,550);panel.theme = T.theme();panel.add_theme_stylebox_override("panel",T.leaf("dialogue"));sheet.add_child(panel)
 var rows := VBoxContainer.new();rows.add_theme_constant_override("separation",22);panel.add_child(rows)
 var title := Label.new();title.text = "機緣 · 靈石下注";title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;title.add_theme_font_size_override("font_size",36);title.add_theme_color_override("font_color",Color("395e51"));rows.add_child(title)
 amount = Label.new();amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;amount.add_theme_font_size_override("font_size",40);amount.add_theme_color_override("font_color",Color("816430"));rows.add_child(amount)
 var slider_row := HBoxContainer.new();slider_row.add_theme_constant_override("separation",18);rows.add_child(slider_row)
 var less := Button.new();less.text = "−";less.custom_minimum_size = Vector2(72,64);slider_row.add_child(less)
 paid = HSlider.new();paid.step = 1;paid.custom_minimum_size.y = 64;paid.size_flags_horizontal = Control.SIZE_EXPAND_FILL;slider_row.add_child(paid)
 var more := Button.new();more.text = "+";more.custom_minimum_size = Vector2(72,64);slider_row.add_child(more)
 less.pressed.connect(func(): paid.value -= 1)
 more.pressed.connect(func(): paid.value += 1)
 for icon in ["grabber","grabber_highlight","grabber_disabled"]: paid.add_theme_icon_override(icon,load("res://assets/ui/modern/slider_jade.svg"))
 var rail := T.panel(Color("91ad9a"),Color("708775"));rail.content_margin_top = 5;rail.content_margin_bottom = 5
 paid.add_theme_stylebox_override("slider",rail)
 paid.add_theme_stylebox_override("grabber_area",T.panel(Color("557e6a"),Color("869e7c")))
 paid.add_theme_stylebox_override("grabber_area_highlight",T.panel(T.JADE,T.GOLD))
 limits = Label.new();limits.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;limits.add_theme_font_size_override("font_size",24);limits.add_theme_color_override("font_color",Color("526b5d"));rows.add_child(limits)
 var tickets := HBoxContainer.new();tickets.alignment = BoxContainer.ALIGNMENT_CENTER;tickets.add_theme_constant_override("separation",20);rows.add_child(tickets)
 var ticket_label := Label.new();ticket_label.text = "使用免費券";ticket_label.add_theme_color_override("font_color",Color("526b5d"));tickets.add_child(ticket_label)
 free = SpinBox.new();free.custom_minimum_size = Vector2(200,55);free.step = 1;tickets.add_child(free)
 free.get_line_edit().add_theme_color_override("font_color",Color("30463f"))
 free.get_line_edit().add_theme_stylebox_override("normal",T.panel(Color("d3ddc7"),Color("9cae91")))
 var note := Label.new();note.text = "確認後設定下注量，開始玩法時才扣除。";note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;note.add_theme_font_size_override("font_size",22);note.add_theme_color_override("font_color",Color("667568"));rows.add_child(note)
 var actions := HBoxContainer.new();actions.alignment = BoxContainer.ALIGNMENT_CENTER;actions.add_theme_constant_override("separation",50);rows.add_child(actions)
 var back := Button.new();back.text = "返回";back.custom_minimum_size = Vector2(310,66);actions.add_child(back);back.pressed.connect(func(): sheet.hide())
 confirm = Button.new();confirm.text = "確認下注";confirm.custom_minimum_size = Vector2(310,66);T.primary(confirm);actions.add_child(confirm)
 paid.value_changed.connect(func(_v): refresh_draft())
 free.value_changed.connect(func(_v): refresh_draft())
 confirm.pressed.connect(func():
  refresh_draft()
  if confirm.disabled: return
  model.set_stake(int(free.value),int(paid.value));sheet.hide();cached = "")
 sheet.hide()
func open_selector():
 if model.entry_paid or not model.modal.is_empty(): return
 origin = model.activity_id
 free.max_value = model.tickets.get(origin,0);free.set_value_no_signal(model.stake_free)
 paid.min_value = 0;paid.max_value = model.spirit_stones/model.entry_cost(origin) if model.realm >= 10 else 0
 paid.editable = paid.max_value > 0;paid.set_value_no_signal(model.stake_paid)
 refresh_draft();sheet.show();paid.grab_focus()
func refresh_draft():
 var cost: int = model.entry_cost(origin)
 var total: int = int(paid.value)*cost
 amount.text = "%d 靈石" % total
 limits.text = "可選 0–%d 靈石 · 每份 %d 靈石\n持有 %d 靈石 · 免費券 %d 張" % [int(paid.max_value)*cost,cost,model.spirit_stones,model.tickets.get(origin,0)]
 confirm.tooltip_text=""
 confirm.disabled = origin != model.activity_id or model.entry_paid or total > model.spirit_stones or int(free.value) > model.tickets.get(origin,0) or int(free.value)+int(paid.value) <= 0
func _process(_delta):
 var key := str([model.activity_id,model.stake_free,model.stake_paid,model.spirit_stones])
 if key != cached:
  cached = key
  info.text = "免費券 %d 張 · 靈石 %d · 共 %d 份" % [model.stake_free,model.stake_paid*model.entry_cost(model.activity_id),model.stake_free+model.stake_paid]
 if sheet.visible and (model.activity_id != origin or model.entry_paid): sheet.hide()
func _input(event):
 if sheet.visible and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
  sheet.hide();get_viewport().set_input_as_handled()
