extends Control
const ART=preload("res://scripts/migration_art.gd")
const HIT=preload("res://scripts/supplied_hit.gd")
const A=preload("res://scripts/ink_assets.gd")
var host: Control
var model: RefCounted
var kind:=""
var identity=0
var choice:=-1
var stage: Control
var wallet: Label
var invested: Label
var reward: Label
var multiplier: Label
var start: Button
var collect: Button
var back: Button
var ticket: Button
var amount_buttons: Array[Button]=[]
var selectors: Array[Button]=[]
var track_selectors: Array[Button]=[]
var cells: Array[Button]=[]
var sprites: Array[TextureRect]=[]
var picker: PanelContainer
var picker_confirm: Button
var slider: HSlider
var picker_value: Label
var status: Label
var trail: Line2D
var settings: PanelContainer
func _ready():
 name="SuppliedOpportunityPage";size=Vector2(1920,1080);mouse_filter=MOUSE_FILTER_STOP
 stage=Control.new();stage.size=Vector2(1672,941);stage.scale=Vector2(1920.0/1672,1080.0/941);add_child(stage)
func label_at(value: String, rect: Rect2, pixels: int=25) -> Label:
 var l:=ART.label(value,pixels);l.position=rect.position;l.size=rect.size;l.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;l.autowrap_mode=TextServer.AUTOWRAP_OFF;l.clip_text=true;l.mouse_filter=MOUSE_FILTER_IGNORE;stage.add_child(l);return l
func hit(rect: Rect2, title: String, callback: Callable) -> Button:
 var b: Button=preload("res://scripts/art_hit_button.gd").new();b.position=rect.position;b.size=rect.size;HIT.style(b);b.tooltip_text="";stage.add_child(b);b.pressed.connect(func():
  if not model.modal.is_empty() or model.result_delay>0 or (is_instance_valid(picker) and picker.visible) or (is_instance_valid(settings) and settings.visible): return
  callback.call();model.save_session();refresh())
 # Alpha-trim the plate corners; never brighten the rectangular scene around it.
 var source: Image=stage.get_node("Background").texture.get_image().get_region(Rect2i(rect))
 source.convert(Image.FORMAT_RGBA8)
 for y in source.get_height():
  for x in source.get_width():
   var nx: float=float(x)/source.get_width();var ny: float=float(y)/source.get_height()
   var cut: bool=false
   if title in ["帮助","设置"]:
    cut=Vector2(nx-.5,ny-.5).length()>.49
   elif title!="探查石块":
    cut=nx<.07*absf(ny-.5)*2 or nx>1-.07*absf(ny-.5)*2
   if cut: source.set_pixel(x,y,Color.TRANSPARENT)
 var texture:=ImageTexture.create_from_image(source)
 b.set_hit_texture(texture);b.set_meta("accessible_name",title)
 for state in ["normal","hover","pressed","disabled","focus"]:
  var box:=StyleBoxTexture.new();box.texture=texture
  box.modulate_color=Color(1,1,1,0) if state in ["normal","disabled"] else Color(.86,.9,.86) if state=="pressed" else Color(1.12,1.12,1.08)
  b.add_theme_stylebox_override(state,box)
 var feedback=preload("res://scripts/opportunity_feedback.gd").new();feedback.name="Feedback";feedback.button=b;b.add_child(feedback)
 return b
func _process(_delta): refresh()
func refresh():
 visible=model.activity_id in ["flying_boat","sword_race","mines"]
 if not visible: return
 if model.activity_id!=kind:
  kind=model.activity_id;choice=-1;build()
 var sub= model.boat if kind=="flying_boat" else model.race if kind=="sword_race" else model.mines
 if identity!=sub.get_instance_id(): identity=sub.get_instance_id();choice=-1;picker.hide()
 var ready: bool=sub.state=="ready"
 wallet.text=host.format_number(model.spirit_stones)
 fit_value(wallet,21)
 var free: int=model.entry_free if model.entry_paid else model.stake_free
 var paid: int=model.entry_cash if model.entry_paid else model.stake_paid
 invested.text=host.format_number((free+paid)*model.entry_cost(kind))
 fit_value(invested,22)
 status.text=("已用%d张券" if model.entry_paid else "已选%d张券 · 开始时扣除")%free if free>0 else "每份 %d 灵石"%model.entry_cost(kind)
 start.disabled=not ready or not model.valid_stake() or (kind=="sword_race" and choice<0)
 ticket.disabled=not ready
 back.disabled=sub.state in ["flying","racing","mining"]
 for b in amount_buttons: b.disabled=not ready
 for i in selectors.size():
  for b in [selectors[i],track_selectors[i]]:
   b.disabled=not ready;b.get_node("Feedback").selected=i==choice;b.get_node("Feedback").queue_redraw()
 if kind=="flying_boat":
  host.boat_panel.hide()
  multiplier.text="%.2f×"%model.boat.multiplier
  var amount: int=model.boat.reward if sub.state in ["crashed","collected"] else int(floor(sub.reward_base*sub.multiplier)) if not ready else 0
  reward.text=host.format_number(amount)
  collect.disabled=sub.state!="flying"
  var t: float=clampf(sub.elapsed/12.0,0,1)
  sprites[0].position=Vector2(295+465*t,510-250*pow(t,1.65))
  trail.clear_points()
  for i in range(41):
   var f: float=t*i/40.0;trail.add_point(Vector2(310+465*f,550-250*pow(f,1.65)))
 elif kind=="sword_race":
  collect.disabled=sub.state!="result";reward.text=host.format_number(sub.reward)
  for i in range(5):
   var travel: float=clampf(sub.progress(i),0,1)
   var center:=Vector2(424+390*travel,296+i*56.5+travel*9)
   sprites[i].position=center-sprites[i].size*.5
 else:
  collect.disabled=sub.state!="mining" or sub.revealed.is_empty()
  reward.text=host.format_number(sub.reward*(model.entry_shares if not sub.paid_out else 1))
  for i in range(25):
   cells[i].disabled=sub.state!="mining" or i in sub.revealed
   var art: TextureRect=cells[i].get_node("Result")
   art.visible=i in sub.revealed
   if art.visible: art.texture=load("res://assets/ui_v5/mine_result_%d.png"%(2 if i in sub.dangers else 1 if sub.crystals.get(i,"")=="rare" else 0))
 fit_value(reward,25)
 for child in stage.get_children():
  if child is Button and child.has_node("Feedback"): child.get_node("Feedback").sync_disabled()
func fit_value(node: Label, preferred: int):
 var font:=node.get_theme_font("font")
 var pixels:=preferred
 node.tooltip_text=""
 while pixels>18 and font.get_string_size(node.text,HORIZONTAL_ALIGNMENT_LEFT,-1,pixels).x>node.size.x-8: pixels-=1
 if font.get_string_size(node.text,HORIZONTAL_ALIGNMENT_LEFT,-1,pixels).x>node.size.x-8:
  var amount: int=node.text.replace(",","").to_int()
  node.text="%.2f亿"%(amount/100000000.0) if amount>=100000000 else "%.2f万"%(amount/10000.0)
 node.add_theme_font_size_override("font_size",pixels)
func build():
 for child in stage.get_children(): stage.remove_child(child);child.queue_free()
 amount_buttons.clear();selectors.clear();track_selectors.clear();cells.clear();sprites.clear()
 var bg:=TextureRect.new();bg.name="Background";bg.texture=load("res://assets/ui_v5/"+{"flying_boat":"lingzhou2","sword_race":"feijian2","mines":"lingkuang"}[kind]+".png");bg.size=Vector2(1672,941);bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;bg.mouse_filter=MOUSE_FILTER_IGNORE;stage.add_child(bg)
 wallet=label_at("",Rect2(1345,23,120,40),21)
 wallet.hide()
 var badge=preload("res://scripts/wallet_badge.gd").new();badge.model=model;badge.compact=true;badge.position=Vector2(1242,18);badge.size=Vector2(230,49);stage.add_child(badge)
 hit(Rect2(1510,18,55,53),"帮助",func(): model.show_help(kind))
 hit(Rect2(1580,18,55,53),"设置",func(): open_settings())
 back=hit(Rect2(38,848 if kind=="flying_boat" else 840,224,53),"返回机缘",func(): model.exit_side_activity();model.enter_side_activity("opportunities"))
 var stake_rect: Rect2
 var start_rect: Rect2
 var collect_rect: Rect2
 var values: Array=[100,300,500,1000,-1]
 if kind=="flying_boat":
  stake_rect=Rect2(813,659,165,40);start_rect=Rect2(600,775,390,83);collect_rect=Rect2(1100,782,190,65)
  reward=label_at("",Rect2(1100,726,165,48));multiplier=label_at("1.00×",Rect2(375,242,420,100),78)
  multiplier.rotation=.035;multiplier.add_theme_font_override("font",ART.T.FONT.TITLE);multiplier.add_theme_color_override("font_color",Color("fff0bc"));multiplier.add_theme_color_override("font_shadow_color",Color("163a3b"));multiplier.add_theme_constant_override("shadow_offset_y",3)
  values=[100,300,500,-1]
  for i in values.size(): var v: int=values[i];amount_buttons.append(hit(Rect2(575+i*110,710,106,50),str(v),func(): set_cash(v)))
  trail=Line2D.new();trail.default_color=Color("f8de90");trail.width=2;stage.add_child(trail)
  var ship:=A.sprite(load("res://assets/ui_v5/moving_5.png"));ship.size=Vector2(115,65);stage.add_child(ship);sprites.append(ship)
 elif kind=="sword_race":
  stake_rect=Rect2(754,640,158,36);start_rect=Rect2(620,800,358,75);collect_rect=Rect2(1160,774,184,58)
  reward=label_at("",Rect2(1220,722,115,44))
  for i in range(5):
   var n:=i;selectors.append(hit(Rect2(490+i*123,685,119,65),"选择"+model.E.RACE_NAMES[i],func(): choice=n))
   track_selectors.append(hit(Rect2(259,275+i*56.5,122,43),"选择"+model.E.RACE_NAMES[i],func(): choice=n))
   var v: int=values[i];amount_buttons.append(hit(Rect2(485+i*126,752,116,47),str(v),func(): set_cash(v)))
   var sword:=A.sprite(load("res://assets/ui_v5/moving_%d.png"%i));sword.size=Vector2(100,35);stage.add_child(sword);sprites.append(sword)
 else:
  stake_rect=Rect2(590,786,160,40);start_rect=Rect2(887,800,315,89);collect_rect=Rect2(1270,840,220,56)
  reward=label_at("",Rect2(1340,791,130,44))
  for i in values.size():
   var v: int=values[i];amount_buttons.append(hit(Rect2(393+i*98,838,93,53),str(v),func(): set_cash(v)))
  for i in range(25):
   var n:=i;var b=hit(Rect2(530+(i%5)*122,136+(i/5)*119,116,115),"探查石块",func(): model.reveal_mine(n));cells.append(b)
   var art:=A.sprite(load("res://assets/ui_v5/mine_result_0.png"));art.name="Result";art.position=Vector2.ZERO;art.size=b.size;art.stretch_mode=TextureRect.STRETCH_SCALE;b.add_child(art)
 invested=label_at("",stake_rect,22)
 start=hit(start_rect,"开始",func():
  if kind=="flying_boat": model.start_boat()
  elif kind=="sword_race": model.start_race(choice)
  else: model.start_mines())
 collect=hit(collect_rect,"收取",func():
  if kind=="flying_boat": model.focus_paused=false;model.collect_boat()
  elif kind=="mines": model.collect_mines()
  else: model.finish_race())
 ticket=Button.new();ticket.text="用票玩";ticket.position=Vector2(290,750) if kind!="mines" else Vector2(170,750);ticket.size=Vector2(165,58);ART.T.small(ticket);stage.add_child(ticket);ticket.pressed.connect(open_tickets)
 status=label_at("",Rect2(160 if kind=="mines" else 280,813,190,54),17);status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 build_picker()
func set_cash(value: int):
 var count: int=model.spirit_stones/model.entry_cost(kind) if value<0 else value/model.entry_cost(kind)
 model.set_stake(0,count)
func build_picker():
 picker=PanelContainer.new();picker.position=Vector2(400,220);picker.custom_minimum_size=Vector2(870,500);picker.add_theme_stylebox_override("panel",ART.skin("frame",85));stage.add_child(picker);picker.hide()
 var column:=VBoxContainer.new();column.add_theme_constant_override("separation",24);picker.add_child(column)
 var title:=ART.label("选择入场券",32);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;column.add_child(title)
 picker_value=ART.label("",26);picker_value.custom_minimum_size=Vector2(700,88);picker_value.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;column.add_child(picker_value)
 var track:=Control.new();track.custom_minimum_size=Vector2(700,48);column.add_child(track)
 var art:=TextureRect.new();art.texture=load("res://assets/ui_v2/meow_test/ui_slider_track.png");art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);art.mouse_filter=MOUSE_FILTER_IGNORE;track.add_child(art)
 slider=HSlider.new();slider.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);slider.step=1;track.add_child(slider)
 for state in ["slider","grabber_area","grabber_area_highlight"]: slider.add_theme_stylebox_override(state,StyleBoxEmpty.new())
 var handle: Image=load("res://assets/ui_v2/meow_test/ui_slider_handle.png").get_image();handle.resize(48,48,Image.INTERPOLATE_LANCZOS)
 var texture:=ImageTexture.create_from_image(handle)
 slider.add_theme_icon_override("grabber",texture);slider.add_theme_icon_override("grabber_highlight",texture);slider.add_theme_icon_override("grabber_disabled",texture)
 slider.value_changed.connect(func(_v): picker_value.text="使用 %d / %d 张券\n投入价值 %s 灵石"%[slider.value,model.tickets[kind],host.format_number(int(slider.value)*model.entry_cost(kind))])
 var note:=ART.label("确认后保留选择，开始游戏时才扣除入场券。",22);note.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;column.add_child(note)
 var actions:=HBoxContainer.new();actions.alignment=BoxContainer.ALIGNMENT_CENTER;actions.add_theme_constant_override("separation",48);column.add_child(actions)
 for i in range(2):
  var accept:=i==1;var b:=Button.new();b.text="确认" if accept else "返回";b.custom_minimum_size=Vector2(250,64);ART.T.small(b);actions.add_child(b)
  if accept: picker_confirm=b
  b.pressed.connect(func():
   if accept: model.set_stake(int(slider.value),0)
   picker.hide())
func open_tickets():
 if ticket.disabled or not model.modal.is_empty() or (is_instance_valid(settings) and settings.visible): return
 picker.show();slider.max_value=model.tickets[kind];slider.value=clampi(model.stake_free,0,model.tickets[kind]);slider.value_changed.emit(slider.value)
func open_settings():
 if is_instance_valid(settings): settings.show();return
 settings=PanelContainer.new();settings.position=Vector2(530,250);settings.size=Vector2(600,520);settings.add_theme_stylebox_override("panel",ART.skin("frame",65));stage.add_child(settings)
 var column:=VBoxContainer.new();column.add_theme_constant_override("separation",20);settings.add_child(column)
 var title:=ART.label("设置",30);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;column.add_child(title)
 var sound:=Button.new();sound.text="音效：开" if host.sound_enabled else "音效：关";ART.T.small(sound);sound.custom_minimum_size.y=60;column.add_child(sound)
 sound.pressed.connect(func(): host.sound_button.pressed.emit();sound.text="音效：开" if host.sound_enabled else "音效：关")
 var language:=Button.new();language.text="简体 / 繁体";ART.T.small(language);language.custom_minimum_size.y=60;column.add_child(language)
 language.pressed.connect(func():
  var locale=get_node("/root/UiLocale");locale.set_language("zh-Hant" if locale.tag=="zh-Hans" else "zh-Hans"))
 var saves:=Button.new();saves.text="存档 / 读取 / 新游戏";ART.T.small(saves);saves.custom_minimum_size.y=60;column.add_child(saves);saves.pressed.connect(func(): settings.hide();host.save_menu.open())
 var close:=Button.new();close.text="返回";ART.T.small(close);close.custom_minimum_size.y=60;column.add_child(close);close.pressed.connect(func(): settings.hide();model.save_session())
