extends Control
const C = preload("res://scripts/balance.gd")
const Model = preload("res://scripts/run_state.gd")
@onready var seat_anchor: Marker2D = $CultivationSeatAnchor
const JADE := Color("365b51")
const INK := Color("292c29")
var home: Control
var recent_news: Label
var pavilion_button: Button
var sect_button: Button
var supplied_page: Control
var save_menu: CanvasLayer
var boat_stake: Control
var blood_view: Control
var duel_view: Control
var sfx_review: Control
var calendar_button: Button
var guide_view: Control
var inventory_drawer: Control
var character_dialogue: Control
var milestone_debug: Control
var preparation_label: Label
var activity_button: Button
var activity_view: Control
var auto_help: Button
var active_duel_button: Button
var save_clock := 0.0
var auto_button: Button
var run = Model.new()
var character = preload("res://scripts/character_presentation.gd").new()
var stats: Label
var predicted: Label
var instruction: Label
var feedback: Label
var breakthrough: Label
var trajectory: Label
var trajectory_status: Label
var required_average: Label
var overlays: Control
var opportunity_glow: StyleBoxTexture
var history_box: VBoxContainer
var history_scroll: ScrollContainer
var debug_panel: Panel
var shop_pill_use: Button
var pill_count_label: Label
var pill_use_button: Button
var debug_values: Label
var end_panel: Panel
var end_text: Label
var seen_serial := -1
var seen_history := -1
var feedback_left := 0.0
var animation_time := 0.0
var result_flash := 0.0
var debug_buttons: Array[Button] = []
var opportunity_button: Button
var boat_panel: Panel
var boat_entry: Label
var boat_number: Label
var boat_status: Label
var boat_start: Button
var boat_collect: Button
var boat_close: Button
var foundation_view: Control
var foundation_debug_panel: Panel
var foundation_grade_input: SpinBox
var audio_debug: Panel
var audio_debug_status: Label
var sfx = preload("res://scripts/sfx_manager.gd").new()
var sound_enabled := true
var sound_button: Button
var shop_panel: Panel
var shop_button: Button
var shop_status: Label
var shop_buttons: Dictionary = {}
var debug_actions := ["failure", "rebirth", "gain", "age", "stones", "opportunity", "crash", "high", "give_gain", "give_protection", "reset"]

func _ready() -> void:
	_update_seat_anchor()
	resized.connect(_update_seat_anchor)
	if "--script" not in OS.get_cmdline_args() and "--no-save" not in OS.get_cmdline_user_args(): run.restore_session("user://current_run.save")
	add_child(sfx)
	run.sfx_event.connect(sfx.handle_event)
	theme = preload("res://scripts/narrative_style.gd").theme()
	var font = preload("res://scripts/ui_typography.gd").BODY
	theme.default_font = font
	label_at(self, "RISK IT OR DIE / CULTIVATION & FATE", Rect2(385,35,945,30), 20, JADE)
	label_at(self, "不賭就會死", Rect2(385,65,945,70), 52, INK)
	label_at(self, "天妒｜你的壽元受到天道壓制，唯有突破境界才能延續性命。", Rect2(365,137,985,42), 23, Color("68533c"))
	stats = label_at(self, "", Rect2(365,180,985,48), 29, INK)
	instruction = label_at(self, "", Rect2(470,820,800,55), 29, JADE)
	predicted = label_at(self, "", Rect2(480,905,800,55), 37, INK)
	predicted.pivot_offset = Vector2(500, 32)
	feedback = label_at(self, "", Rect2(465,285,810,90), 26, JADE)
	breakthrough = label_at(self, "", Rect2(420,965,930,58), 23, Color("806238"))
	label_at(self, "天命推演", Rect2(1460,160,390,60), 34, JADE)
	trajectory = label_at(self, "", Rect2(1460,235,390,185), 24, INK)
	trajectory.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	trajectory.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	required_average = label_at(self, "", Rect2(1460,430,390,105), 29, Color("806238"))
	required_average.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	required_average.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	trajectory_status = label_at(self, "", Rect2(1460,550,390,70), 23, JADE)
	trajectory_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	recent_news = label_at(self, "", Rect2(1460,630,390,95), 22, JADE)
	recent_news.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_at(self, "年表 / 修煉歷史", Rect2(1460,790,390,40), 28, INK)
	preparation_label = label_at(self,"",Rect2(1460,735,390,50),19,JADE)
	history_scroll = ScrollContainer.new()
	history_scroll.position = Vector2(1460,840)
	history_scroll.size = Vector2(390,130)
	history_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(history_scroll)
	history_box = VBoxContainer.new()
	history_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	history_box.add_theme_constant_override("separation", 15)
	history_scroll.add_child(history_box)
	opportunity_button = make_button(self, "機緣尚未降臨", Rect2(42,390,260,80), func(): run.enter_side_activity("opportunities"); sync_ui())
	sound_button = make_button(self, "音效：開", Rect2(40,70,255,65), func(): sound_enabled = not sound_enabled; sync_ui())
	shop_button = make_button(self, "丹藥商店", Rect2(42,850,260,80), func(): run.open_shop(); sync_ui())
	auto_button = make_button(self, "自動修煉：關", Rect2(660,1010,340,62), func(): run.set_auto(not run.auto_enabled); sync_ui())
	auto_help = make_button(self,"?",Rect2(1020,1010,90,62),func(): run.show_help("auto"))
	activity_button = make_button(self, "洞府", Rect2(42,505,260,80), func(): run.enter_side_activity("lobby"); sync_ui())
	active_duel_button = make_button(self,"問劍",Rect2(42,620,260,80),func(): run.enter_side_activity("active_duel"))
	calendar_button = make_button(self,"年曆",Rect2(1440,1010,450,62),func(): run.show_help("calendar"))
	history_scroll.size.y = 125
	sect_button = make_button(self,"宗門",Rect2(42,275,260,80),func(): run.enter_side_activity("sect"))
	pavilion_button = make_button(self,"天機閣",Rect2(42,735,260,80),func(): run.enter_side_activity("pavilion"))
	build_shop_panel()
	build_boat_panel()
	build_end_panel()
	build_debug_panel()
	foundation_view = preload("res://scripts/foundation_view.gd").new()
	foundation_view.model = run
	add_child(foundation_view)
	activity_view = preload("res://scripts/activity_view.gd").new()
	activity_view.model = run
	add_child(activity_view)
	duel_view = preload("res://scripts/duel_view.gd").new()
	duel_view.model = run
	add_child(duel_view)
	blood_view = preload("res://scripts/blood_view.gd").new()
	blood_view.model = run
	add_child(blood_view)
	move_child(debug_panel,get_child_count()-1)
	if OS.is_debug_build():
		build_audio_debug()
		build_foundation_debug()
	opportunity_glow = style(Color("153a38"))
	overlays = preload("res://scripts/opportunity_toast.gd").new()
	overlays.model = run
	overlays.ui_confirm.connect(func(): sfx.handle_event("ui_confirm"))
	add_child(overlays)
	var activity_feedback = preload("res://scripts/activity_feedback.gd").new()
	activity_feedback.model = run
	add_child(activity_feedback)
	supplied_page=preload("res://scripts/supplied_game_page.gd").new();supplied_page.host=self;supplied_page.model=run;add_child(supplied_page)
	guide_view = preload("res://scripts/guide_view.gd").new()
	guide_view.model = run
	add_child(guide_view)
	inventory_drawer = preload("res://scripts/inventory_drawer.gd").new()
	inventory_drawer.model = run
	add_child(inventory_drawer)
	character_dialogue = preload("res://scripts/character_dialogue.gd").new()
	character_dialogue.model = run
	add_child(character_dialogue)
	if OS.is_debug_build():
		milestone_debug = preload("res://scripts/milestone_debug.gd").new()
		sfx_review = preload("res://scripts/sfx_review.gd").new()
		sfx_review.manager = sfx
		add_child(sfx_review)
		milestone_debug.model = run
		milestone_debug.review_room = sfx_review
		milestone_debug.audio_manager = sfx
		add_child(milestone_debug)
		move_child(sfx_review,get_child_count()-1)
	home = preload("res://scripts/cultivation_home.gd").new()
	home.host = self
	add_child(home)
	move_child(home,0)
	sync_ui()
	save_menu=preload("res://scripts/save_menu.gd").new();save_menu.host=self;add_child(save_menu)
	if "--script" not in OS.get_cmdline_args() and not run.persistence_path.is_empty(): save_menu.open(true)

func label_at(parent: Node, value: String, box: Rect2, font_size: int, color: Color) -> Label:
	var node := Label.new()
	node.text = value
	node.position = box.position
	node.size = box.size
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	parent.add_child(node)
	return node

func style(_color: Color) -> StyleBoxTexture:
	return preload("res://scripts/ink_theme.gd").box()

func make_button(parent: Node, title: String, box: Rect2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = title
	button.position = box.position
	button.size = box.size
	button.add_theme_font_size_override("font_size", 24)
	button.pressed.connect(func():
		callback.call()
		if title != "收取" and parent != debug_panel and parent != audio_debug and parent != foundation_debug_panel: sfx.handle_event("ui_confirm")
	)
	preload("res://scripts/jade_theme.gd").apply_button(button)
	parent.add_child(button)
	return button

func build_end_panel() -> void:
	end_panel = Panel.new()
	end_panel.position = Vector2(500, 240)
	end_panel.size = Vector2(920, 600)
	end_panel.add_theme_stylebox_override("panel", preload("res://scripts/migration_art.gd").skin("frame",60))
	add_child(end_panel)
	end_text = label_at(end_panel, "", Rect2(90, 95, 740, 330), 29, Color("f0e8d4"))
	end_text.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	end_text.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	make_button(end_panel, "再活一世", Rect2(280, 450, 360, 70), reset_run)

func build_debug_panel() -> void:
	debug_panel = Panel.new()
	debug_panel.position = Vector2(70, 320)
	debug_panel.size = Vector2(1100, 650)
	debug_panel.add_theme_stylebox_override("panel", style(Color("17222c")))
	debug_panel.visible = false
	add_child(debug_panel)
	if not OS.is_debug_build(): return
	label_at(debug_panel, "人物測試 · F3 關閉", Rect2(15, 15, 1070, 45), 25, Color("806238"))
	debug_values = label_at(debug_panel, "", Rect2(25, 80, 1050, 65), 25, INK)
	var names := ["走火入魔", "破而後立", "+1000 修為", "壽元調至瀕死", "+1000 靈石", "獲得機緣", "靈舟墜毀", "靈舟 ×12", "給予聚氣丹", "給予護脈丹", "重新開始"]
	for index in range(names.size()):
		var action: String = debug_actions[index]
		debug_buttons.append(make_button(debug_panel, names[index], Rect2(35 + (index % 3) * 355, 155 + (index / 3) * 68, 340, 55), func(): run.debug_action(action); sync_ui()))

	pill_count_label = label_at(debug_panel,"",Rect2(35,435,1000,45),28,INK)
	for i in range(4):
		var amount: int = [-1,0,1,5][i]
		make_button(debug_panel,["給予破境丹 +1","破境丹設為 0","破境丹設為 1","破境丹設為 5"][i],Rect2(35+i*265,490,250,55),func(): run.debug_set_breakthrough_pills(run.breakthrough_pill_count()+1 if amount == -1 else amount);sync_ui())
	pill_use_button = make_button(debug_panel,"使用破境丹",Rect2(35,565,330,55),func(): run.use_breakthrough_pill();sync_ui())

func reset_run() -> void:
	run.reset()
	seen_serial=-1;seen_history=-1
	feedback_left = 0.0
	result_flash = 0.0
	debug_panel.visible = false
	sync_ui()

func build_boat_panel() -> void:
	boat_panel = Panel.new()
	boat_panel.position = Vector2(70, 310)
	boat_panel.size = Vector2(1100, 690)
	add_child(boat_panel)
	var visual = preload("res://scripts/boat_view.gd").new()
	visual.model = run
	visual.size = boat_panel.size
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boat_panel.add_child(visual)
	label_at(boat_panel, "飛升靈舟", Rect2(50, 15, 1000, 60), 40, JADE)
	boat_entry = label_at(boat_panel, "每張靈舟券起額 %d 靈石" % C.BOAT_BASE_STONES, Rect2(50, 78, 1000, 40), 23, INK)
	boat_number = label_at(boat_panel, "×1.00", Rect2(150, 125, 800, 80), 52, Color("806238"))
	boat_number.pivot_offset = Vector2(400, 40)
	boat_status = label_at(boat_panel, "", Rect2(50, 505, 1000, 55), 29, INK)
	boat_start = make_button(boat_panel, "登舟啟航", Rect2(810, 255, 240, 235), func(): run.start_boat(); sync_ui())
	boat_start.text = "拉桿啟航"
	boat_start.alignment = HORIZONTAL_ALIGNMENT_CENTER
	boat_start.add_theme_constant_override("outline_size",0)
	var lever_art := preload("res://scripts/ink_assets.gd").sprite(preload("res://scripts/ink_assets.gd").lever())
	lever_art.position = Vector2(15,5);lever_art.size = Vector2(210,175);boat_start.add_child(lever_art)
	for mode in ["normal","hover","pressed","disabled","focus"]:
		boat_start.get_theme_stylebox(mode).content_margin_top = 180
	boat_collect = make_button(boat_panel, "收取", Rect2(325, 570, 450, 58), func(): run.focus_paused = false; run.collect_boat(); sync_ui())
	make_button(boat_panel,"?",Rect2(1000,15,65,55),func(): run.show_help("flying_boat"))
	boat_close = make_button(boat_panel, "稍後處理", Rect2(400, 635, 300, 45), func(): run.leave_boat(); sync_ui())

func _input(event: InputEvent) -> void:
	if is_instance_valid(sfx_review) and sfx_review.visible:
		if event is InputEventKey and event.pressed and event.keycode in [KEY_ESCAPE,KEY_F10]:
			sfx_review.close_room()
			get_viewport().set_input_as_handled()
		return
	if OS.is_debug_build() and event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_F7,KEY_F10]:
		milestone_debug.visible = not milestone_debug.visible
		sfx.stop_charge()
		get_viewport().set_input_as_handled()
		return
	if is_instance_valid(milestone_debug) and milestone_debug.visible: return
	if OS.is_debug_build() and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F6:
		foundation_debug_panel.visible = not foundation_debug_panel.visible
		get_viewport().set_input_as_handled()
		return
	if is_instance_valid(foundation_debug_panel) and foundation_debug_panel.visible: return
	if OS.is_debug_build() and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F4:
		audio_debug.visible = not audio_debug.visible
		sfx.stop_charge()
		get_viewport().set_input_as_handled()
		return
	if is_instance_valid(audio_debug) and audio_debug.visible: return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3 and OS.is_debug_build():
		debug_panel.visible = not debug_panel.visible
		run.focus_paused = false
		sync_ui()
		get_viewport().set_input_as_handled()
		return
	if is_instance_valid(inventory_drawer) and inventory_drawer.opened: return
	if is_instance_valid(character_dialogue) and character_dialogue.visible: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if run.auto_enabled or run.auto_owned: return
		if debug_panel.visible or end_panel.visible or boat_panel.visible or shop_panel.visible or run.state in ["foundation_ready","foundation"]:
			return
		if not event.pressed:
			run.focus_paused = false
			run.release()
		sync_ui()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if is_instance_valid(save_menu): save_menu.capture_settings()
		run.save_session()
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and run.foundation != null: run.foundation.release_hold()
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and run.alchemy != null: run.alchemy.release_fire()
	# Focus loss never grants an automatic safe success; resume requires release.
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and run.state in ["holding", "ship"]:
		run.focus_paused = true
		sfx.stop_charge()

func _process(delta: float) -> void:
	save_clock += delta
	if save_clock >= .5:
		save_clock = 0
		if is_instance_valid(save_menu): save_menu.capture_settings()
		run.save_session()
	animation_time += delta
	feedback_left = maxf(0.0, feedback_left - delta)
	result_flash = maxf(0.0, result_flash - delta)
	if not any_debug_open():
		if not inventory_drawer.opened and (not is_instance_valid(home) or not home.history_panel.visible and not home.settings_panel.visible): run.advance(delta)
	sync_ui()
	sfx.update_activity_audio(run,any_debug_open())
	if not any_debug_open(): sfx.generated.stop_preview()
	sfx.update_charge(delta, run.risk, run.state == "holding" and not any_debug_open() and not run.focus_paused)
	var danger: float = C.feedback_intensity(run.risk) if run.state == "holding" else 0.0
	var pulse := 1.0 + 0.055 * danger * sin(animation_time * (5.0 + 22.0 * danger))
	predicted.scale = Vector2.ONE * pulse
	overlays.advance(delta)
	queue_redraw()

func sync_ui() -> void:
	if run.modal.get("id","") == "calendar": run.modal.text=run.calendar_text()
	inventory_drawer.refresh()
	duel_view.refresh()
	blood_view.refresh()
	calendar_button.text = run.calendar_text()
	var message_waiting: bool = run.sect.C.ENABLE_JUNIOR_REMINDERS and run.sect.junior_met and (not run.sect.reaction.is_empty() or (run.sect.affection >= run.sect.C.AFFECTION_STAGES[1] and not run.sect.seen.has("junior_close")) or (run.sect.affection >= run.sect.C.AFFECTION_STAGES[2] and not run.sect.seen.has("junior_gift")))
	sect_button.text = "宗門"+(" · ●" if message_waiting or not run.sect.stipends.is_empty() else "")
	recent_news.text = ("【宗門傳訊】\n小師妹似乎有話想對你說。" if message_waiting else "")+("\n俸祿已到，有空回宗門領取。" if not run.sect.stipends.is_empty() else "")
	pavilion_button.visible = run.sect.pavilion_unlocked

	if run.next_festival_year()-run.world_year() <= run.P.PREVIEW_YEARS: calendar_button.text += " · 大比將近"
	active_duel_button.visible = run.realm >= run.D.ACTIVE_REALM and run.sect.duel_taught
	active_duel_button.text = ("【新】" if run.new_features.has("active_duel") else "")+"問劍\n尋訪各宗劍修"
	guide_view.refresh()
	if is_instance_valid(milestone_debug): milestone_debug.refresh()
	var preparation_parts: Array[String] = []
	for i in range(5): preparation_parts.append(("✓" if run.pills[i] > 0 else "◇")+run.E.PILL_NAMES[i])
	preparation_label.text = "結丹準備 %d / 5\n" % run.preparation().count + " ".join(preparation_parts)
	preparation_label.visible = run.realm >= C.FOUNDATION_REALM
	activity_view.refresh()
	activity_button.text = ("【新】" if run.new_features.has("lobby") else "") + "洞府\n解石 · 煉丹"
	activity_button.visible = run.realm >= C.FOUNDATION_REALM
	activity_button.disabled = (run.state != "idle" and not run.auto_enabled) or debug_panel.visible
	auto_button.visible = run.realm >= C.FOUNDATION_REALM
	auto_help.visible = auto_button.visible
	auto_button.text = ("【新】" if run.new_features.has("auto") else "") + "自動修煉：" + ("開" if run.auto_enabled else "關")
	auto_button.disabled = run.realm >= C.FOUNDATION_COMPLETE or run.state not in ["idle", "holding", "rupture", "presenting"]
	foundation_view.refresh()
	sfx.set_enabled(sound_enabled)
	if not sfx.debug_charge and (run.state != "holding" or run.focus_paused or any_debug_open()): sfx.stop_charge()
	if is_instance_valid(audio_debug_status) and audio_debug.visible: audio_debug_status.text = sfx.last_diagnostic
	overlays.sync(debug_panel.visible)
	shop_panel.visible = run.state == "shop"
	shop_button.disabled = (run.state != "idle" and not run.auto_enabled) or debug_panel.visible
	sound_button.text = "音效：開" if sound_enabled else "音效：關"
	shop_status.text = "待用：%s / %s" % [ "聚氣丹" if run.gain_pill else "無聚氣丹", "護脈丹" if run.protection_pill else "無護脈丹"]
	for item in shop_buttons: shop_buttons[item].disabled = not run.can_purchase(item)
	shop_buttons.breakthrough.tooltip_text=""
	shop_buttons.breakthrough.text = run.pill_unavailable_reason() if not run.pill_realm_allowed() else "购买"
	shop_pill_use.text = "使用破境丹 · %d" % run.breakthrough_pill_count()
	shop_pill_use.disabled = not run.can_use_breakthrough_pill()
	boat_panel.visible = run.state in ["ship_ready", "ship", "ship_result"]
	boat_entry.text = "免費券 %d張｜靈石加注 %d／份｜起額：免費 %d／付費 %d" % [run.tickets.flying_boat, run.entry_cost("flying_boat"), C.BOAT_BASE_STONES, run.E.PAID_BOAT_BASE]
	boat_start.disabled = not run.valid_stake()
	boat_start.text = "拉桿啟航 · %d份" % (run.stake_free+run.stake_paid)
	if run.state == "ship_ready" and not is_instance_valid(boat_stake):
		boat_stake = preload("res://scripts/stake_view.gd").new();boat_stake.model = run;boat_stake.position = Vector2(50,320);boat_stake.size = Vector2(730,220);boat_panel.add_child(boat_stake)
	elif run.state != "ship_ready" and is_instance_valid(boat_stake):
		boat_panel.remove_child(boat_stake);boat_stake.queue_free();boat_stake = null
	boat_entry.visible = run.state != "ship_ready"
	boat_start.visible = run.state == "ship_ready"
	boat_collect.visible = run.state == "ship"
	boat_close.visible = run.state in ["ship_ready", "ship_result"]
	boat_close.text = "稍後處理" if run.state == "ship_ready" else "返回修煉"
	boat_number.text = "×%.2f" % run.boat.multiplier
	boat_number.scale = Vector2.ONE * (1 + 0.035 * sin(animation_time * 8)) if run.state == "ship" else Vector2.ONE
	boat_status.text = "隨時收取，墜毀則本次歸零"
	if run.state == "ship": boat_status.text = "現在收取：%d 靈石" % int(floor(run.boat.reward_base * run.boat.multiplier))
	if run.focus_paused and run.state == "ship": boat_status.text = "視窗失焦已暫停 · 按收取結束本次"
	if run.state == "ship_result": boat_status.text = "%s · 本次 +%d 靈石" % ["靈舟墜毀" if run.boat.state == "crashed" else "收取成功", run.boat.reward]
	opportunity_button.disabled = (run.state != "idle" and not run.auto_enabled) or debug_panel.visible
	opportunity_button.text = ("【新】" if run.new_features.has("opportunities") else "") + "機緣\n外出歷練"
	if run.opportunity:
		opportunity_glow.modulate_color = Color("76dfc2") * (0.78 + 0.12 * sin(animation_time * TAU * C.OPPORTUNITY_PULSE_HZ))
		opportunity_button.add_theme_stylebox_override("normal", opportunity_glow)
		opportunity_button.add_theme_stylebox_override("disabled", opportunity_glow)
	else:
		opportunity_button.remove_theme_stylebox_override("normal")
		opportunity_button.remove_theme_stylebox_override("disabled")
	var target := str(run.requirement()) if run.requirement() > 0 else "圓滿" if run.realm == C.QI_COMPLETE else "圓滿"
	stats.text = "%s ×%.1f    修為 %d / %s    年齡 %.1f / %.0f" % [C.REALMS[run.realm], C.REALM_MULTIPLIERS[run.realm], run.cultivation, target, run.age, run.lifespan]
	stats.text += "\n靈石：%d  ·  待用丹藥：%s %s" % [run.spirit_stones, "聚氣丹" if run.gain_pill else "—", "護脈丹" if run.protection_pill else ""]
	stats.add_theme_font_size_override("font_size", 23)
	predicted.text = "預計獲得修為：%d" % run.potential
	predicted.add_theme_color_override("font_color", JADE.lerp(Color("ff876b"), C.feedback_intensity(run.risk)))
	instruction.text = "修煉中 · 放開收功" if run.state == "holding" else "按住修煉"
	if run.realm >= C.FOUNDATION_COMPLETE:
		instruction.text = "築基圓滿 · 準備結丹"
		predicted.text = run.preparation().status
	if run.focus_paused:
		instruction.text = "已暫停 · 放開滑鼠收功"
	if run.state == "rupture":
		match run.phase:
			"loss":
				instruction.text = "走火入魔！"
				predicted.text = "%d → 0  修為潰散" % run.potential
			"silence":
				instruction.text = "萬籟俱寂……"
				predicted.text = "+0"
			"reversal":
				instruction.text = "天命逆轉！"
				predicted.text = "潰散的靈氣正在回流"
			"return":
				instruction.text = "失去的修為，回來了"
				predicted.text = "%d" % run.potential
			"multiply":
				instruction.text = "逆境重生"
				predicted.text = "%d ×%d → %d" % [run.potential, C.REBIRTH_MULTIPLIER, run.potential * C.REBIRTH_MULTIPLIER]
			"jackpot":
				instruction.text = "破而後立"
				predicted.text = "+%d 修為即將歸入丹田" % (run.potential * C.REBIRTH_MULTIPLIER)
	if run.state == "presenting":
		instruction.text = "修為歸入丹田" if run.phase == "reward" else "境界突破"
		predicted.text = "+%d 修為" % run.last_result.get("gain", 0) if run.phase == "reward" else C.REALMS[run.realm]
	instruction.add_theme_color_override("font_color", Color("806238") if run.phase in ["jackpot", "multiply", "reward", "breakthrough"] else JADE)
	instruction.add_theme_font_size_override("font_size", 68 if run.phase == "jackpot" else 29)
	instruction.position.y = 724
	if seen_serial != run.result_serial:
		seen_serial = run.result_serial
		if run.last_result.is_empty():
			feedback_left = 0.0
		else:
			feedback_left = C.COMMENT_SECONDS
			result_flash = C.COMMENT_SECONDS
			var r: Dictionary = run.last_result
			feedback.text = "%s\n+%d 修為" % [r.comment, r.gain]
			if r.outcome == "failure":
				feedback.text += " · 潛在 %d 未收回" % r.lost_potential
			feedback.add_theme_color_override("font_color", Color("806238") if r.outcome == "rebirth" else JADE if r.outcome == "success" else Color("ff876b"))
	character.update(run, feedback_left > 0.0)
	feedback.visible = feedback_left > 0.0 and run.state != "rupture"
	# Full multi-breakthrough details remain in the scrollable history.
	breakthrough.text = run.breakthrough_text
	breakthrough.visible = run.state != "rupture" and (run.state != "presenting" or run.phase == "breakthrough")
	if breakthrough.get_line_count() > 2:
		breakthrough.text = "%s抵達 %s，壽元延至 %.0f 歲\n詳情已記入年表" % ["連續突破！" if run.breakthrough_text.count("突破！") > 1 else "突破！", C.REALMS[run.realm], run.lifespan]
	var p: Dictionary = run.projection()
	trajectory.text = "目前年齡：%.1f / %.1f\n剩餘壽元：%.1f 年\n距離突破：%s 修為\n剩餘可修煉：約 %d 次\n近期實際平均：%s / 次（%d 次）" % [run.age, run.lifespan, p.years, format_number(p.needed), p.remaining, format_number(int(round(p.average))) if p.samples > 0 else "—", p.samples]
	required_average.text = "維持突破所需\n平均約 %s 修為 / 次" % format_number(p.required_average)
	if p.required_average < 0: required_average.text = "已無可用修煉次數"
	if run.requirement() == 0:
		required_average.text = "練氣已圓滿\n下一步：九宫灵纹铸基" if run.realm == C.QI_COMPLETE else "築基圓滿 · 道基%d品\n結丹準備中，後續境界未開放" % run.foundation_grade + "\n" + run.preparation().status
	trajectory_status.text = "推演：" + p.status
	trajectory_status.add_theme_color_override("font_color", JADE if p.level == "positive" else Color("806238") if p.level == "warning" else Color("ff876b") if p.level == "urgent" else Color("91a5ad"))
	if run.state in ["dead", "complete"]:
		trajectory_status.text = "此世已結束" if run.state == "dead" else "此世修行已到盡頭"
	if seen_history != run.history.size():
		seen_history = run.history.size()
		for child in history_box.get_children():
			history_box.remove_child(child)
			child.queue_free()
		for entry in run.history:
			var row := Label.new()
			row.text = entry
			row.add_theme_font_size_override("font_size", 21)
			row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			history_box.add_child(row)
		scroll_history.call_deferred()
	character_dialogue.refresh()
	if character_dialogue.visible: guide_view.hide()
	end_panel.visible = run.state in ["dead", "complete"] and feedback_left <= 0.0
	instruction.visible = run.state not in ["dead", "complete"]
	if end_panel.visible:
		end_text.text = ("%s\n%s\n享年 %.1f 歲 · 最高境界 %s\n總修煉 %d 次 · 成功 %d 次\n走火入魔 %d 次 · 破而後立 %d 次\n最大單次修為 %d" % ["坐化" if run.state == "dead" else "築基一層 · 圓滿", ("此世壽元已盡，道基已記入年表。" if run.foundation_grade > 0 else "你未能在天妒降臨前突破。") if run.state == "dead" else "你又多活了一點。接下來，該準備結丹了。", run.age, C.REALMS[run.realm], run.attempts, run.successes, run.failures, run.rebirths, run.biggest_gain])
	if debug_panel.visible:
		pill_count_label.text = "破境丹 ×%d" % run.breakthrough_pill_count()
		pill_use_button.disabled = not run.can_use_breakthrough_pill()
		debug_values.text = "修煉 %.1f 秒 · 不穩定 %.2f · 風險 %.2f" % [run.hold, run.risk, C.hazard(run.hold)]
		for index in range(debug_buttons.size()):
			var action: String = debug_actions[index]
			debug_buttons[index].disabled = false if action == "reset" else (run.state not in ["idle", "holding"] if action in ["failure", "rebirth"] else (run.state != "ship" if action in ["crash", "high"] else run.state != "idle"))

	if is_instance_valid(home): home.refresh()

func scroll_history() -> void:
	# Containers need a layout pass before their scroll range reflects new rows.
	await get_tree().process_frame
	await get_tree().process_frame
	history_scroll.scroll_vertical = int(history_scroll.get_v_scroll_bar().max_value)

func cultivation_background_rect() -> Rect2:
	var texture_size := Vector2(2048,1152)
	var fit := minf(size.x/texture_size.x,size.y/texture_size.y)
	var display_size := texture_size*fit
	return Rect2((size-display_size)*0.5,display_size)

func _update_seat_anchor() -> void:
	if is_instance_valid(seat_anchor): seat_anchor.place_in(cultivation_background_rect())
	queue_redraw()

func _draw() -> void:
	var background_frame := cultivation_background_rect()
	draw_texture_rect(preload("res://assets/ui_v3/reference_home/background.png"),background_frame,false)
	# Layered, low-opacity contact ellipse under the robe, never a solid black disk.
	for layer in range(8):
		var contact := PackedVector2Array()
		var spread: Vector2 = Vector2(118-layer*9,19-layer*1.5)*(seat_anchor.draw_size.x/360.0)
		for step in range(48): contact.append(seat_anchor.contact_position()+Vector2(0,13)+Vector2(cos(step*TAU/48),sin(step*TAU/48))*spread)
		draw_colored_polygon(contact,Color(0.12,0.24,0.24,0.018))
	preload("res://scripts/cultivation_vfx.gd").paint(self)

func build_shop_panel() -> void:
	var art=preload("res://scripts/migration_art.gd")
	shop_panel=Panel.new();shop_panel.position=Vector2(190,120);shop_panel.size=Vector2(1540,850);shop_panel.add_theme_stylebox_override("panel",art.skin("frame",50));add_child(shop_panel)
	var title=art.label("丹药商店",34);title.position=Vector2(120,110);title.size=Vector2(1300,50);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;shop_panel.add_child(title)
	shop_status=art.label("",23);shop_status.position=Vector2(550,167);shop_status.size=Vector2(870,58);shop_panel.add_child(shop_status)
	var wallet_badge=preload("res://scripts/wallet_badge.gd").new();wallet_badge.model=run;wallet_badge.position=Vector2(120,167);wallet_badge.size=Vector2(370,68);shop_panel.add_child(wallet_badge)
	var grid:=HBoxContainer.new();grid.position=Vector2(120,240);grid.size=Vector2(1300,440);grid.add_theme_constant_override("separation",24);shop_panel.add_child(grid)
	for key in C.SHOP:
		var item: String=key
		var card:=PanelContainer.new();card.custom_minimum_size=Vector2(306,425);card.add_theme_stylebox_override("panel",art.skin("slot",28));grid.add_child(card)
		var v:=VBoxContainer.new();v.add_theme_constant_override("separation",13);card.add_child(v)
		v.add_child(art.picture(art.item_icon(run,item),Vector2(230,115)))
		var name_label=art.label(C.SHOP[item].name,30,false);name_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;v.add_child(name_label)
		var description=art.label(C.SHOP[item].detail,22,false);description.custom_minimum_size=Vector2(250,108);v.add_child(description)
		var price=art.label("%s 灵石"%format_number(C.SHOP[item].price),25,false);price.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;v.add_child(price)
		var buy:=Button.new();buy.text="购买";buy.custom_minimum_size=Vector2(210,60);buy.size_flags_horizontal=Control.SIZE_SHRINK_CENTER;art.T.small(buy);v.add_child(buy);shop_buttons[item]=buy
		buy.pressed.connect(func(): run.purchase(item);sync_ui();sfx.handle_event("ui_confirm") if item!="breakthrough" else null)
	shop_pill_use=Button.new();shop_pill_use.position=Vector2(70,735);shop_pill_use.size=Vector2(370,60);art.T.small(shop_pill_use);shop_pill_use.pressed.connect(func(): run.use_breakthrough_pill();sync_ui());shop_panel.add_child(shop_pill_use)
	var close:=Button.new();close.text="返回修炼";close.position=Vector2(1230,735);close.size=Vector2(230,60);art.T.small(close);shop_panel.add_child(close);close.pressed.connect(func(): run.close_shop();sync_ui();sfx.handle_event("ui_confirm"))

func format_number(value: int) -> String:
	var digits := str(value)
	var result := ""
	for i in range(digits.length()):
		if i > 0 and (digits.length() - i) % 3 == 0: result += ","
		result += digits[i]
	return result

func build_audio_debug() -> void:
	audio_debug = Panel.new()
	audio_debug.position = Vector2(150, 220)
	audio_debug.size = Vector2(1620, 740)
	audio_debug.add_theme_stylebox_override("panel", style(Color("17222c")))
	add_child(audio_debug)
	audio_debug.visible = false
	label_at(audio_debug, "AUDIO DEBUG · F4 close · respects sound toggle", Rect2(30,20,1550,50),30,INK)
	audio_debug_status = label_at(audio_debug,"",Rect2(30,80,1560,110),19,INK)
	var keys := ["ui_confirm","charge","stop_charge","cultivation_good_release","cultivation_risky_release","cultivation_extreme_release","cultivation_failure","realm_breakthrough","boat_cashout"]
	for i in range(keys.size()):
		var key: String = keys[i]
		make_button(audio_debug,"Test " + key,Rect2(30+(i%2)*790,220+(i/2)*85,760,65),func(): sfx.debug_test(key))

func build_foundation_debug() -> void:
	foundation_debug_panel = Panel.new()
	foundation_debug_panel.position = Vector2(150,180)
	foundation_debug_panel.size = Vector2(1620,800)
	foundation_debug_panel.add_theme_stylebox_override("panel",style(Color("17222c")))
	foundation_debug_panel.visible = false
	add_child(foundation_debug_panel)
	label_at(foundation_debug_panel,"FOUNDATION DEBUG · F6 close · 開啟時暫停演出",Rect2(30,15,1550,50),30,INK)
	var actions := ["qi9","complete","start","success","failure","1","2","3","rebirth"]
	var names := ["Jump 練氣九層","Set 練氣圓滿","Start 九宫灵纹铸基","Force next success","Force next failure","Force 小崩","Force 大崩","Force 道台崩塌","Force 築基破而後立"]
	for i in range(actions.size()):
		var action: String = actions[i]
		make_button(foundation_debug_panel,names[i],Rect2(30+(i%2)*790,100+(i/2)*95,760,65),func(): run.foundation_debug(action); sync_ui())
	foundation_grade_input = SpinBox.new()
	foundation_grade_input.position = Vector2(30,650)
	foundation_grade_input.size = Vector2(220,60)
	foundation_grade_input.min_value = 1
	foundation_grade_input.max_value = 9
	foundation_debug_panel.add_child(foundation_grade_input)
	make_button(foundation_debug_panel,"Set foundation grade",Rect2(300,650,760,65),func(): run.foundation_debug("grade",int(foundation_grade_input.value)); sync_ui())

func any_debug_open() -> bool:
	return (is_instance_valid(sfx_review) and sfx_review.visible) or debug_panel.visible or (is_instance_valid(audio_debug) and audio_debug.visible) or (is_instance_valid(foundation_debug_panel) and foundation_debug_panel.visible) or (is_instance_valid(milestone_debug) and milestone_debug.visible)

func _exit_tree():
	run.save_session()

