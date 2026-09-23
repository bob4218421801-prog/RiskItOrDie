extends Control
## Presentation-only home layout. Existing controls retain their callbacks.
const COLLAGE := "res://assets/ui_v3/collage/"
const NAV_KEYS := ["nav.cultivation","nav.sect","nav.opportunity","nav.cave","nav.duel","nav.tianji","nav.alchemy_shop","nav.inventory"]
const NAV_RECTS := [Rect2(62,181,253,93),Rect2(94,265,182,67),Rect2(94,334,182,66),Rect2(93,404,183,65),Rect2(92,474,184,61),Rect2(92,539,184,63),Rect2(91,607,185,64),Rect2(92,676,184,60)]
const T = preload("res://scripts/reference_home_theme.gd")
var host: Control
var hold_button: Button
var realm_label: Label
var resource_label: Label
var progress: ProgressBar
var news: Label
var history_panel: PanelContainer
var back: Button
var inventory_button: Button
var base_labels: Array[Label] = []
var forecast_values: Array[Label] = []
var forecast_note: Label
var cultivation_caption: Label
var forecast_stamp := ""
var nav_buttons: Array[Button] = []
var nav_labels: Array[Label] = []
var nav_badges: Array[Label] = []
var modal_blocker: Control
var settings_panel: PanelContainer
var forecast_panel: Control
var forecast_groups: Array[Control] = []
var expanded := false
var expand_button: Button
var gain_serial := -1
var gain_age := 2.0
var collage_skins: Dictionary = {}
var localized_logo: TextureRect
var risk_art: TextureRect
var hud: Control
var cultivation_input_area: Button
var expected_gain: Label
var gain_plate: TextureRect
var array_status: Label
func box(parent: Node, rect: Rect2) -> VBoxContainer:
 var panel := PanelContainer.new()
 panel.position = rect.position;panel.size = rect.size
 parent.add_child(panel)
 var col := VBoxContainer.new();col.add_theme_constant_override("separation",16);panel.add_child(col)
 return col
func text(parent: Node, value: String, pixels: int = 28) -> Label:
 var l := Label.new();l.text = value;l.add_theme_font_size_override("font_size",pixels)
 l.mouse_filter = Control.MOUSE_FILTER_IGNORE
 parent.add_child(l);return l
func move(node: Control, parent: Node, height: float = 0) -> void:
 node.reparent(parent);node.position = Vector2.ZERO;node.size = Vector2.ZERO
 node.custom_minimum_size = Vector2(0,height)
 node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 if node is Button: T.button(node)
 if node is Label:
  node.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
  node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
  node.add_theme_font_size_override("font_size",26)
  base_labels.append(node)
func action(parent: Node, value: String, callback: Callable) -> Button:
 var b := Button.new();b.text = value;T.button(b);parent.add_child(b);b.pressed.connect(callback);return b
func art(parent: Node, file: String, rect: Rect2) -> TextureRect:
 var image := TextureRect.new();image.texture = load(T.ROOT+file+".png")
 image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;image.stretch_mode = TextureRect.STRETCH_SCALE
 image.position = rect.position;image.size = rect.size;image.mouse_filter = Control.MOUSE_FILTER_IGNORE
 parent.add_child(image);return image
func place(node: Control, parent: Node, rect: Rect2) -> void:
 node.reparent(parent);node.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
 node.custom_minimum_size = Vector2.ZERO;node.position = rect.position;node.size = rect.size
func _ready() -> void:
 name = "CultivationHome";set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter = Control.MOUSE_FILTER_IGNORE;theme = T.theme()
 for child in host.get_children():
  if child is Label: child.hide()
 collage_art(self,"pillar",Rect2(37*1.148,0,272*1.148,883*1.148)).name="NavigationArchitecture"
 localized_logo=collage_art(self,"logo_zh_hans",Rect2(94*1.148,54*1.148,170*1.148,124*1.148))
 localized_logo.name="LocalizedLogo"
 get_node("/root/UiLocale").language_changed.connect(update_logo)
 update_logo()
 collage_art(self,"hud",Rect2(303*1.148,8*1.148,1124*1.148,93*1.148))
 hud=preload("res://scripts/cultivation_hud.gd").new();add_child(hud)
 cultivation_input_area=Button.new();cultivation_input_area.name="cultivation_input_area";cultivation_input_area.position=Vector2(365,240);cultivation_input_area.size=Vector2(950,655)
 for state in ["normal","hover","pressed","disabled","focus"]: cultivation_input_area.add_theme_stylebox_override(state,StyleBoxEmpty.new())
 add_child(cultivation_input_area);move_child(cultivation_input_area,0)
 cultivation_input_area.button_down.connect(func():
  if not blocked() and not host.run.auto_enabled: host.run.begin();host.sync_ui())
 cultivation_input_area.button_up.connect(func(): host.run.release();host.sync_ui())
 realm_label=text(self,"",25);realm_label.position=Vector2(510,42);realm_label.size=Vector2(440,52);realm_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 # Center the complete resource group in the usable jade between crest and endcap.
 resource_label=text(self,"",25);resource_label.position=Vector2(1060,42);resource_label.size=Vector2(470,52);resource_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;resource_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 progress=ProgressBar.new();progress.show_percentage=false;add_child(progress);progress.position=Vector2(1045,87);progress.size=Vector2(490,6)
 progress.add_theme_font_size_override("font_size",1)
 for pair in [["background","progress_track"],["fill","progress_fill"]]:
  var strip := StyleBoxTexture.new();strip.texture=load("res://assets/ui_v2/home/"+pair[1]+".png");progress.add_theme_stylebox_override(pair[0],strip)
 var selected := action(self,"",func(): pass);nav_buttons.append(selected)
 for b in [host.sect_button,host.opportunity_button,host.activity_button,host.active_duel_button,host.pavilion_button,host.shop_button]:
  move(b,self);nav_buttons.append(b)
 inventory_button=action(self,"",func(): host.inventory_drawer.set_open(true));nav_buttons.append(inventory_button)
 var names := ["cultivation","sect","opportunity","cave","duel","destiny","shop","inventory"]
 for i in range(8):
  var b := nav_buttons[i];b.name="Navigation_"+names[i];b.icon=null;b.text=""
  var source: Rect2=NAV_RECTS[i]
  b.custom_minimum_size=Vector2.ZERO;b.position=source.position*1.148;b.size=source.size*1.148
  collage_button(b,"nav_"+String(NAV_KEYS[i]).trim_prefix("nav."))
  var caption := text(b,NAV_KEYS[i],26)
  caption.position=Vector2((167-source.position.x)*1.148-10,0);caption.size=Vector2(119,b.size.y)
  caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;caption.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
  caption.add_theme_font_override("font",T.FONT.TITLE);nav_labels.append(caption)
  var badge := text(b,"新",14);badge.position=Vector2(b.size.x-24,0);badge.size=Vector2(22,20);badge.add_theme_color_override("font_color",T.GOLD);badge.hide();nav_badges.append(badge)
 forecast_panel=Control.new();forecast_panel.name="DestinyScroll";forecast_panel.position=Vector2(1330,145);forecast_panel.size=Vector2(550,700);add_child(forecast_panel)
 collage_art(forecast_panel,"fatebook",Rect2(0,0,550,700))
 for caption in ["fate.lifespan","fate.distance","fate.attempts","fate.average","fate.required","fate.verdict"]:
  var group := Control.new();group.size=Vector2(380,68);forecast_panel.add_child(group);forecast_groups.append(group)
  var label := text(group,caption,19);label.name="Caption";label.size=Vector2(250,26);label.add_theme_color_override("font_color",Color("756d58"));label.add_theme_font_override("font",T.FONT.TITLE)
  var value := text(group,"",26);value.position=Vector2(0,25);value.size=Vector2(250,36);value.add_theme_color_override("font_color",T.INK);forecast_values.append(value)
 forecast_note=text(forecast_panel,"",20);forecast_note.position=Vector2(74,474);forecast_note.size=Vector2(364,35);forecast_note.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;forecast_note.add_theme_color_override("font_color",Color("586151"))
 expand_button=action(forecast_panel,"展开推演",func(): expanded=not expanded;update_book());T.small(expand_button);expand_button.position=Vector2(150,509);expand_button.size=Vector2(202,52)
 update_book()
 # Core CTA stays below the character's contact root; it never moves the actor.
 hold_button=action(self,"按住修炼，放开收功",func(): pass);T.primary(hold_button);collage_button(hold_button,"primary");hold_button.position=Vector2(646,941);hold_button.size=Vector2(558,123)
 hold_button.button_down.connect(func():
  if not blocked(): host.run.begin();host.sync_ui())
 hold_button.button_up.connect(func(): host.run.release();host.sync_ui())
 place(host.predicted,self,Rect2(645,900,562,39));host.predicted.show();host.predicted.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;host.predicted.add_theme_font_size_override("font_size",26)
 host.predicted.add_theme_color_override("font_shadow_color",Color("1d3934"));host.predicted.add_theme_constant_override("shadow_offset_y",2)
 gain_plate=TextureRect.new();gain_plate.texture=load("res://assets/ui_v4/plaque.png");gain_plate.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;gain_plate.position=Vector2(410,748);gain_plate.size=Vector2(330,113);gain_plate.mouse_filter=MOUSE_FILTER_IGNORE;add_child(gain_plate)
 cultivation_caption=text(self,"预计获得修为",22);cultivation_caption.position=Vector2(440,772);cultivation_caption.size=Vector2(285,28);cultivation_caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;cultivation_caption.add_theme_color_override("font_color",Color("345647"))
 expected_gain=text(self,"+0",40);expected_gain.position=Vector2(440,795);expected_gain.size=Vector2(285,46);expected_gain.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;expected_gain.add_theme_color_override("font_color",Color("375c4c"));expected_gain.add_theme_color_override("font_shadow_color",Color("152d29"));expected_gain.add_theme_constant_override("shadow_offset_y",2)
 array_status=text(self,"",23);array_status.position=Vector2(460,856);array_status.size=Vector2(285,60);array_status.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;array_status.add_theme_color_override("font_shadow_color",Color("172d26"));array_status.add_theme_constant_override("shadow_offset_y",2)
 place(host.auto_button,self,Rect2(1220,1012,190,48));T.small(host.auto_button);collage_button(host.auto_button,"auto")
 place(host.auto_help,self,Rect2(1422,1012,48,48));T.small(host.auto_help);collage_button(host.auto_help,"help")
 place(host.calendar_button,self,Rect2(1494,1012,110,48));T.small(host.calendar_button);collage_button(host.calendar_button,"calendar");host.calendar_button.icon=null
 var history := action(self,"home.history",func(): history_panel.show();back.grab_focus());history.name="HistoryEntry";T.small(history);collage_button(history,"history");history.position=Vector2(1616,1012);history.size=Vector2(148,48)
 var settings := action(self,"home.settings",func(): settings_panel.show());settings.name="SettingsEntry";T.small(settings);collage_button(settings,"settings");settings.position=Vector2(1776,1012);settings.size=Vector2(112,48)
 settings.add_theme_constant_override("outline_size",0)
 settings.add_theme_font_size_override("font_size",22)
 news=text(self,"",22);news.position=Vector2(402,147);news.size=Vector2(750,64);news.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;news.add_theme_color_override("font_color",T.TEXT);news.add_theme_color_override("font_shadow_color",Color("24362f"));news.add_theme_constant_override("shadow_offset_y",2)
 for l in [host.instruction,host.feedback,host.breakthrough]:
  l.reparent(self);l.add_theme_font_override("font",T.FONT.TITLE);l.add_theme_stylebox_override("normal",StyleBoxEmpty.new());l.add_theme_color_override("font_shadow_color",Color("183b3e"));l.add_theme_constant_override("shadow_offset_y",2)
 host.instruction.position=Vector2(470,430);host.instruction.size=Vector2(830,68)
 host.breakthrough.position=Vector2(440,350);host.breakthrough.size=Vector2(880,84)
 modal_blocker=Control.new();add_child(modal_blocker);modal_blocker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);modal_blocker.mouse_filter=Control.MOUSE_FILTER_STOP;modal_blocker.hide()
 var options := box(self,Rect2(685,180,550,700));settings_panel=options.get_parent()
 var title := text(options,"设置",34);title.add_theme_color_override("font_color",T.INK);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 move(host.sound_button,options,58);T.small(host.sound_button)
 var lang := action(options,"简体 / 繁体",func():
  var locale=get_node("/root/UiLocale");locale.set_language("zh-Hant" if locale.tag=="zh-Hans" else "zh-Hans"));T.small(lang)
 T.small(action(options,"存档 / 读取 / 新游戏",func(): host.save_menu.open()))
 T.small(action(options,"返回",func(): settings_panel.hide()));settings_panel.hide()
 for child in options.get_children():
  if child is Button: child.size_flags_horizontal=Control.SIZE_SHRINK_CENTER;child.custom_minimum_size=Vector2(310,70)
 history_panel=PanelContainer.new();history_panel.position=Vector2(610,70);history_panel.size=Vector2(700,890)
 var history_skin=preload("res://scripts/migration_art.gd").skin("frame",65);history_skin.content_margin_top=110;history_skin.content_margin_bottom=85;history_panel.add_theme_stylebox_override("panel",history_skin);add_child(history_panel)
 var h := VBoxContainer.new();h.add_theme_constant_override("separation",14);history_panel.add_child(h)
 var history_heading=text(h,"修炼历史",36);history_heading.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;history_heading.add_theme_color_override("font_color",Color("f0eadb"))
 move(host.history_scroll,h);host.history_scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
 host.history_scroll.remove_child(host.history_box)
 var history_center:=HBoxContainer.new();history_center.size_flags_horizontal=Control.SIZE_EXPAND_FILL;history_center.alignment=BoxContainer.ALIGNMENT_CENTER;host.history_scroll.add_child(history_center);history_center.add_child(host.history_box)
 host.history_box.custom_minimum_size.x=490;host.history_box.add_theme_color_override("font_color",Color("f0eadb"));host.history_box.size_flags_horizontal=Control.SIZE_SHRINK_CENTER
 back=action(h,"返回修炼",func(): history_panel.hide();hold_button.grab_focus());T.small(back);back.custom_minimum_size=Vector2(280,62);back.size_flags_horizontal=Control.SIZE_SHRINK_CENTER;history_panel.hide()
 risk_art=TextureRect.new();risk_art.position=Vector2(730,443);risk_art.size=Vector2(390,120);risk_art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;risk_art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;risk_art.mouse_filter=MOUSE_FILTER_IGNORE;add_child(risk_art)
 hold_button.grab_focus()
func blocked() -> bool:
 return host.any_debug_open() or host.inventory_drawer.opened or history_panel.visible or settings_panel.visible or host.character_dialogue.visible or not host.run.modal.is_empty()
func refresh() -> void:
 var m = host.run
 var settled_safe: bool=host.feedback_left>0 and m.state!="holding" and m.last_result.get("outcome","")=="success"
 var final_risk: float=m.last_result.get("instability",0.0)
 var word: String="safe" if final_risk<.3 else "risk" if final_risk<.5 else "edge" if final_risk<.7 else "death"
 risk_art.visible=settled_safe and not blocked()
 if risk_art.visible:
  risk_art.position=Vector2(730,443);risk_art.size=Vector2(390,120)
  risk_art.texture=load("res://assets/ui_v4/feedback_"+word+".png")
 hud.refresh(host);realm_label.hide();resource_label.hide()
 cultivation_input_area.disabled=blocked() or m.auto_enabled or m.state not in ["idle","holding"]
 modal_blocker.visible=settings_panel.visible or history_panel.visible
 realm_label.text = "%s     修為 %s / %s" % [host.C.REALMS[m.realm],host.format_number(m.cultivation),host.format_number(m.requirement()) if m.requirement()>0 else "圓滿"]
 resource_label.text = "靈石 %s   ·   %.1f / %.0f 歲" % [host.format_number(m.spirit_stones),m.age,m.lifespan]
 progress.max_value = maxf(1,m.requirement());progress.value = m.cultivation
 for l in base_labels: l.add_theme_color_override("font_color",T.TEXT)
 host.required_average.add_theme_color_override("font_color",T.GOLD)
 host.trajectory_status.add_theme_color_override("font_color",Color("d49b55") if m.projection().level in ["warning","urgent"] else T.INK)
 host.predicted.add_theme_color_override("font_color",T.JADE.lerp(Color("d49b55"),host.C.feedback_intensity(m.risk)))
 host.instruction.add_theme_color_override("font_color",Color("866132") if m.state == "rupture" else T.TEXT)
 host.feedback.add_theme_color_override("font_color",T.TEXT)
 host.breakthrough.add_theme_color_override("font_color",Color("866132"))
 host.preparation_label.hide();host.stats.hide();host.recent_news.hide()
 host.trajectory.hide();host.required_average.hide();host.trajectory_status.hide()
 host.breakthrough.visible = host.breakthrough.visible and not host.breakthrough.text.is_empty()
 var projection: Dictionary = m.projection()
 var values: Array[String] = [
  "%.1f / %.0f 歲" % [m.age,m.lifespan],
  "%s 修為" % host.format_number(projection.needed),
  "約 %d 次" % projection.remaining,
  (host.format_number(int(round(projection.average)))+" / 次") if projection.samples > 0 else "尚無修煉記錄",
  (host.format_number(projection.required_average)+" / 次") if projection.required_average >= 0 else "已無可用修煉次數",
  projection.status]
 if m.requirement() == 0:
  values[1] = "本境圓滿"
  values[4] = "前往九宫灵纹铸基" if m.realm == host.C.QI_COMPLETE else "準備結丹"
 if forecast_stamp != str(values):
  forecast_stamp = str(values)
  for i in range(values.size()): forecast_values[i].text = values[i]
 forecast_values[5].add_theme_color_override("font_color",Color("956132") if projection.level in ["warning","urgent"] else T.INK)
 forecast_note.text = "依最近 %d 次修煉推演" % projection.samples if projection.samples > 0 else "修煉後，天機漸明。"
 cultivation_caption.visible=m.state in ["holding","rupture"] and host.character_dialogue.source().is_empty();host.predicted.hide()
 expected_gain.visible=m.state=="holding";gain_plate.visible=m.state=="holding";cultivation_caption.visible=m.state=="holding"
 expected_gain.text="+"+host.format_number(m.potential)
 array_status.text="聚灵阵生效 · 剩余 %d 次"%m.array_attempts if m.array_attempts>0 else ""

 host.active_duel_button.text = ("新 · " if m.new_features.has("active_duel") else "")+"問劍"
 host.activity_button.text = ("新 · " if m.new_features.has("lobby") else "")+"洞府"
 host.opportunity_button.text = ("新 · " if m.new_features.has("opportunities") else "")+"機緣"

 host.calendar_button.text = "home.calendar"
 host.calendar_button.tooltip_text=""
 var pending: String = "聚氣丹" if m.gain_pill else ""
 if m.protection_pill: pending += "  護脈丹"
 news.text = host.recent_news.text.replace("\n"," ")
 if news.text.is_empty(): news.text = "待用丹藥："+pending if not pending.is_empty() else ""
 news.hide() # World notices use the dedicated two-attempt notification layer.
 hold_button.text = "home.holding" if m.state == "holding" else "home.cultivate"
 hold_button.disabled = blocked() or m.auto_enabled or m.state not in ["idle","holding"] or m.realm >= host.C.FOUNDATION_COMPLETE
 host.instruction.visible = m.state in ["rupture","presenting"] and not risk_art.visible
 host.instruction.position.y=440
 if history_panel.visible or settings_panel.visible:
  host.feedback.hide();host.breakthrough.hide()
 queue_redraw()
 inventory_button.disabled = host.inventory_drawer.entry.disabled or not host.inventory_drawer.entry.visible
 # Keep the existing inventory entry available in other gameplay pages.
 host.inventory_drawer.entry.visible = host.inventory_drawer.entry.visible and m.state not in ["idle","holding","rupture","presenting"]
 if m.state not in ["idle","holding","rupture","presenting"]: history_panel.hide();settings_panel.hide()
 var titles := NAV_KEYS
 var features := ["","sect","opportunities","lobby","active_duel","pavilion","",""]
 var availability := [true,true,true,m.realm>=host.C.FOUNDATION_REALM,m.realm>=m.D.ACTIVE_REALM and m.sect.duel_taught,m.sect.pavilion_unlocked,true,not inventory_button.disabled]
 for i in range(nav_buttons.size()):
  var b := nav_buttons[i];b.text="";b.show();b.disabled=not availability[i] or blocked() or (m.state != "idle" and not m.auto_enabled)
  collage_button(b,"nav_"+String(NAV_KEYS[i]).trim_prefix("nav."))
  b.custom_minimum_size=Vector2.ZERO;b.size=NAV_RECTS[i].size*1.148
  nav_labels[i].text=titles[i];nav_labels[i].modulate=Color.WHITE
  nav_labels[i].add_theme_color_override("font_color",Color("9faeaa") if b.disabled else T.INK if i==0 else T.TEXT)
  b.tooltip_text=""
  nav_badges[i].visible=availability[i] and m.new_features.has(features[i])
 host.auto_button.text="home.auto_on" if m.auto_enabled else "home.auto_off"
 host.auto_help.text="" # The original question-mark artwork is the sole visible glyph.
 collage_button(host.auto_button,"auto");collage_button(host.auto_help,"help");collage_button(host.calendar_button,"calendar")
 host.auto_button.size=Vector2(190,48);host.auto_help.size=Vector2(48,48);host.calendar_button.size=Vector2(110,48)
 host.auto_button.tooltip_text=""
 for child in host.history_box.get_children():
  if child is Label: child.add_theme_color_override("font_color",Color("efe9d6"));child.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 if gain_serial != m.result_serial: gain_serial = m.result_serial;gain_age = 0
 host.feedback.visible = gain_age < 1.6 and m.state in ["idle","presenting"] and not blocked() and not m.last_result.is_empty()
 host.feedback.position = host.seat_anchor.actor_rect().position+Vector2(host.seat_anchor.draw_size.x*.5-400,-100-gain_age*22)
 host.feedback.modulate.a = clampf((1.6-gain_age)/.6,0,1)
 # Dedicated result staging: no judgement during charging, no panel over the VFX.
 if m.state=="holding": risk_art.hide();host.feedback.hide();host.instruction.hide()
 if m.state=="rupture":
  risk_art.hide();host.breakthrough.hide();host.instruction.show()
  host.instruction.position=Vector2(450,285);host.instruction.size=Vector2(850,115)
  host.instruction.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  host.instruction.add_theme_font_size_override("font_size",80)
  host.instruction.add_theme_constant_override("outline_size",5)
  host.instruction.add_theme_color_override("font_outline_color",Color("443018"))
  host.instruction.add_theme_color_override("font_color",Color("fff1b0"))
  host.instruction.text={"loss":"万籁俱寂","silence":"灵息逆乱","burst":"","reversal":"天命逆转","multiply":"破而后立","jackpot":"破而后立"}.get(m.phase,"")
  host.feedback.visible=m.phase in ["silence","multiply","jackpot"]
  host.feedback.position=Vector2(450,407);host.feedback.size=Vector2(850,110);host.feedback.modulate.a=1
  host.feedback.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  host.feedback.add_theme_font_size_override("font_size",40 if m.phase=="silence" else 52)
  host.feedback.add_theme_constant_override("outline_size",4)
  host.feedback.add_theme_color_override("font_outline_color",Color("443018"))
  host.feedback.add_theme_color_override("font_color",Color("ffdca0"))
  host.feedback.text="0 修为\n潜在修为 %s 未收回"%host.format_number(m.potential) if m.phase=="silence" else "+%s 修为"%host.format_number(m.potential*m.C.REBIRTH_MULTIPLIER)
  if m.phase in ["reversal","multiply","jackpot"]:
   var traditional: bool=get_node("/root/UiLocale").tag=="zh-Hant"
   risk_art.texture=load("res://assets/ui_v6/titles/"+("reversal" if m.phase=="reversal" else "rebirth")+("_hant.png" if traditional else "_hans.png"))
   risk_art.position=Vector2(host.seat_anchor.actor_rect().get_center().x-395,265);risk_art.size=Vector2(850,210);risk_art.show();host.instruction.hide()
   host.feedback.position=Vector2(host.seat_anchor.actor_rect().get_center().x-425,485);host.feedback.add_theme_font_size_override("font_size",49)
   host.feedback.add_theme_constant_override("outline_size",0)
   host.feedback.add_theme_color_override("font_shadow_color",Color("302a20"));host.feedback.add_theme_constant_override("shadow_offset_y",3)
   host.feedback.add_theme_color_override("font_color",Color("fff7dc"))
  if m.phase in ["loss","silence"]:
   host.instruction.hide();host.feedback.hide()
 elif host.feedback.visible:
  host.feedback.add_theme_font_size_override("font_size",40)
  host.feedback.add_theme_color_override("font_color",Color("fff3c9"))
  host.feedback.add_theme_color_override("font_outline_color",Color("293c3a"));host.feedback.add_theme_constant_override("outline_size",4)
  if settled_safe: host.feedback.text="+%s 修为"%host.format_number(m.last_result.get("gain",0));host.feedback.position.y=555
func _input(event: InputEvent) -> void:
 if (history_panel.visible or settings_panel.visible) and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
  history_panel.hide();settings_panel.hide();hold_button.grab_focus();get_viewport().set_input_as_handled()

func update_book() -> void:
 var index := 0
 for i in range(forecast_groups.size()):
  forecast_groups[i].visible=expanded or i in [0,2,4,5]
  if forecast_groups[i].visible:
   forecast_groups[i].position=Vector2(86,(181 if expanded else 201)+index*(48 if expanded else 70));index+=1
   forecast_values[i].position=Vector2(0,21 if expanded else 25)
   forecast_values[i].add_theme_font_size_override("font_size",22 if expanded else 26)
   forecast_values[i].size=Vector2(250,32)
 forecast_note.visible=expanded
 expand_button.text="home.collapse" if expanded else "home.expand"
func _process(delta: float) -> void:
 gain_age += delta
 if is_instance_valid(hold_button) and host.run.state == "holding":
  hold_button.modulate = Color.WHITE.lerp(Color(1.12,1.12,.95),host.C.feedback_intensity(host.run.risk))
 elif is_instance_valid(hold_button): hold_button.modulate = Color.WHITE

func collage_art(parent: Node, file: String, rect: Rect2) -> TextureRect:
 var image := TextureRect.new();image.texture=load(COLLAGE+file+".png")
 image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;image.stretch_mode=TextureRect.STRETCH_SCALE
 image.position=rect.position;image.size=rect.size;image.mouse_filter=Control.MOUSE_FILTER_IGNORE
 parent.add_child(image);return image
func update_logo() -> void:
 var suffix := "zh_hant" if get_node("/root/UiLocale").tag=="zh-Hant" else "zh_hans"
 localized_logo.texture=load(COLLAGE+"logo_"+suffix+".png")
func collage_button(button: Button, file: String) -> void:
 for state in ["normal","hover","pressed","disabled"]:
  var key: String = file+"/"+state
  if collage_skins.has(key):
   button.add_theme_stylebox_override(state,collage_skins[key]);continue
  var style := StyleBoxTexture.new();style.texture=load(COLLAGE+file+".png")
  style.modulate_color=Color(1.08,1.08,1.04) if state=="hover" else Color(.83,.88,.86) if state=="pressed" else Color(.58,.62,.6) if state=="disabled" else Color.WHITE
  style.content_margin_left=12;style.content_margin_right=12;style.content_margin_top=0;style.content_margin_bottom=0
  if file=="settings": style.content_margin_left=30;style.content_margin_right=8
  button.add_theme_stylebox_override(state,style)
  collage_skins[key]=style
 button.add_theme_stylebox_override("focus",StyleBoxEmpty.new())

