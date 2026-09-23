extends Control
## Full-screen scene composition; commands still go through the existing activity model.
const A = preload("res://scripts/ink_assets.gd")
const T = preload("res://scripts/ink_theme.gd")
var host: Control
var model: RefCounted
var stamp := ""
var start: Button
var selected: Array[Button] = []
var stake: Control
var caption: Label
var lever: TextureRect
var clock := 0.0
func _ready():
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter = Control.MOUSE_FILTER_STOP
 theme = T.theme()
func label(words: String, rect: Rect2, pixels: int = 30) -> Label:
 var l := Label.new();l.text = words;l.position = rect.position;l.size = rect.size;l.add_theme_font_size_override("font_size",pixels);l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER;l.mouse_filter = Control.MOUSE_FILTER_IGNORE;add_child(l);return l
func plate(rect: Rect2, dark: bool = false) -> Panel:
 var p := Panel.new();p.position = rect.position;p.size = rect.size;p.add_theme_stylebox_override("panel",T.box(1 if dark else 0));p.mouse_filter = Control.MOUSE_FILTER_IGNORE;add_child(p);return p
func button(words: String, rect: Rect2, callback: Callable, primary: bool = false) -> Button:
 var b := Button.new();b.text = words;b.position = rect.position;b.size = rect.size;T.apply_button(b,primary);add_child(b)
 b.pressed.connect(func():
  if not model.modal.is_empty() or model.result_delay > 0: return
  callback.call();model.save_session();model.sfx_event.emit("ui_confirm");host.refresh())
 return b
func refresh():
 var next_stamp: String = model.activity_id+(model.race.state if model.activity_id == "sword_race" else "")
 if stamp != next_stamp:
  stamp = next_stamp
  for child in get_children(): remove_child(child);child.queue_free()
  selected.clear();start = null;caption = null;lever = null
  if model.activity_id == "sect": build_map()
  elif model.race.state == "ready": build_race_selection()
  else: build_race_track()
 if is_instance_valid(start):
  start.disabled = host.race_choice < 0 or not model.valid_stake()
  for i in range(selected.size()): selected[i].modulate = Color("f6df9d") if host.race_choice == i else Color.WHITE
  caption.text = "選一柄飛劍，再拉桿啟程" if host.race_choice < 0 else "%s · 勝出可得 %d 靈石" % [model.E.RACE_NAMES[host.race_choice],int(model.E.ENTRY_COST*model.E.RACE_PAYOUT[host.race_choice])*(model.stake_free+model.stake_paid)]
 queue_redraw()
func _draw():
 var bg: String = "sect" if model.activity_id == "sect" else ("race" if model.race.state == "ready" else "landscape")
 draw_texture_rect(A.texture(bg),Rect2(Vector2.ZERO,Vector2(1920,1080)),false)
func build_map():
 plate(Rect2(650,25,620,100));label("宗 門",Rect2(650,32,620,82),46)
 var places := ["師父","小師妹","大師姐","俸祿堂"]
 var positions := [Vector2(270,385),Vector2(260,835),Vector2(1440,460),Vector2(1430,905)]
 for i in range(4):
  var destination: String = places[i]
  var b := button(destination+"的家" if i in [1,2] else destination,Rect2(positions[i],Vector2(280,78)),func(): host.sect_destination = destination;host.view_key = "")
  b.disabled = (i == 1 and not model.sect.junior_met) or (i == 2 and not model.sect.senior_met)
  b.tooltip_text=""
 button("返回修煉",Rect2(45,960,280,78),func(): model.exit_side_activity())
 if model.sect.card_choices > 0: button("領取大比獎勵",Rect2(810,960,320,78),func(): host.sect_destination = "俸祿堂";host.view_key = "",true)
func build_race_selection():
 plate(Rect2(600,24,720,100));label("御 劍 競 速",Rect2(600,30,720,84),46)
 for i in range(5):
  var index := i
  var art := A.sprite(A.sword(i));art.size = Vector2(520,190);art.pivot_offset = art.size*.5;art.position = Vector2(170+i*278,430)-art.size*.5;art.rotation = -PI*.5;add_child(art)
  var b := button(model.E.RACE_NAMES[i]+"\n賠率 ×%.2f" % model.E.RACE_PAYOUT[i],Rect2(55+i*278,730,242,105),func(): host.race_choice = index;refresh())
  b.tooltip_text="";selected.append(b)
 plate(Rect2(1470,150,400,680))
 lever = A.sprite(A.lever());lever.position = Vector2(1530,190);lever.size = Vector2(270,370);add_child(lever)
 start = button("拉桿 · 開賽",Rect2(1510,580,320,80),func(): model.start_race(host.race_choice),true)
 lever.mouse_filter = Control.MOUSE_FILTER_STOP
 lever.gui_input.connect(func(event):
  if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not start.disabled: start.pressed.emit())
 label("選劍押注\n勝者得獎",Rect2(1520,670,300,110),28)
 plate(Rect2(360,850,1150,205))
 stake = preload("res://scripts/stake_view.gd").new();stake.model = model;stake.position = Vector2(400,870);stake.size = Vector2(1070,170);add_child(stake)
 caption = label("",Rect2(260,125,1200,60),30)
 button("返回修煉",Rect2(30,963,280,78),func(): model.exit_side_activity())
func build_race_track():
 plate(Rect2(90,90,1740,875));label("萬 劍 逐 風",Rect2(500,105,920,75),44)
 for i in range(5):
  label(model.E.RACE_NAMES[i]+(" · 所選" if model.race.selected == i else ""),Rect2(140,220+i*135,200,65),28)
  var lane := preload("res://scripts/sword_lane.gd").new();lane.race = model.race;lane.index = i;lane.position = Vector2(365,220+i*135);lane.size = Vector2(1370,80);add_child(lane)
 button("返回修煉",Rect2(800,970,320,78),func(): model.exit_side_activity()).disabled = model.race.state == "racing"
