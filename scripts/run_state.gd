extends RefCounted
var first_rebirth_complete := false
signal sfx_event(key: String)
## Simulation/state only. UI renders this model and never chooses outcomes.
const C = preload("res://scripts/balance.gd")
const T = preload("res://scripts/content_config.gd")
const E = preload("res://scripts/economy_config.gd")
const P = preload("res://scripts/polish_config.gd")
const B = preload("res://scripts/blood_config.gd")
var sect = preload("res://scripts/sect_state.gd").new()
var sicbo: RefCounted
var stake_free := 0
var stake_paid := 0
var entry_shares := 1
var entry_free := 0
var entry_cash := 0
var blood: RefCounted
var blood_counter := 0
var blood_threshold := 0
var blood_due := false
var blood_schedule_rng := RandomNumberGenerator.new()
var blood_items := {"魔道素材":0,"魔器碎片":0,"幽冥玉髓":0}
var tournament: RefCounted
var festival_seen := 740
var festival_pending := 0
var keepsakes: Dictionary = {"天機令":0,"古劍殘片":0}
const D = preload("res://scripts/duel_config.gd")
var unlock_notified: Dictionary = {}
var unlock_queue: Array[String] = []
var board: Array[Dictionary] = []
var board_attempt := -1
var selected_opponent := -1
var persistence_path := ""
var settings_data: Dictionary={"language":"zh-Hans","sound_enabled":true,"master_volume":1.0}
var developer_test_session := false
var duel: RefCounted
var first_passive_seen := false
var duel_schedule_version := 2
var bone_target_pending := false
var duel_counter := 0
var duel_threshold := 75
var challenges_enabled := true
var duel_due := false
var duel_count := 0
var treasures: Array[int] = [0,0,0]
const Boat = preload("res://scripts/spirit_boat.gd")
var practice_completed := false
var result_delay := 0.0
var feedback_duration := 0.0
var feedback_kind := ""
var pending_result: Dictionary = {}
var last_raw_drop := -1
var tutorials_enabled := true
var modal: Dictionary = {}
var help_seen: Dictionary = {}
var new_features: Dictionary = {}
var foundation_unlock_granted := false
var auto_after_help := false
var activity_counters := {"flying_boat":0,"sword_race":0,"mines":0}
var auto_enabled := false
var auto_owned := false
var auto_target := 0.0
var auto_rest := 0.0
var auto_rng := RandomNumberGenerator.new()
var raw_stones: Array[int] = [0,0,0,0]
var materials: Array[int] = [0,0,0,0,0]
var fragments := 0
var pills: Array[int] = [0,0,0,0,0]
var upper_pills: Array[int] = [0,0,0,0,0]
var alchemy: RefCounted
var stone: RefCounted
var economy_rng := RandomNumberGenerator.new()
var race: RefCounted
var mines: RefCounted
var boat = Boat.new()
var foundation: RefCounted
var foundation_grade := 0
var dao_foundation_type := ""
var dao_foundation_flags: Array = []
var foundation_multiplier := 1.0
var foundation_completed := false
var foundation_seen := 0
var overrides = preload("res://scripts/debug_overrides.gd").new()
var array_attempts := 0
var spirit_stones := 0
var tickets := {"flying_boat":0, "sword_race":0, "mines":0}
var opportunity: bool:
	get: return tickets.flying_boat > 0
	set(value): tickets.flying_boat = maxi(tickets.flying_boat,1) if value else 0
var activity_id := ""
var pending_activity := ""
var auto_before_activity := false
var entry_paid := false
var entry_was_free := false
var ticket_notice := ""
var notification_events: Array[Dictionary] = []
var notification_id := 0
var notified_rewards: Dictionary = {}

var opportunity_serial := 0
var run_serial := 0
var gain_pill := false
var protection_pill := false
var attempt_modifier := 1.0
var attempt_protected := false
var rng := RandomNumberGenerator.new()
var state := "idle"
var age := C.STARTING_AGE
var lifespan := C.STARTING_LIFESPAN
var realm := 0
var cultivation := 0
var hold := 0.0
var risk := 0.0
var potential := 0
var hazard_budget := 0.0
var pending_rebirth := false
var pause_left := 0.0
var attempts := 0
var failures := 0
var rebirths := 0
var successes := 0
var biggest_gain := 0
var recent: Array[int] = []
var history: Array[String] = []
var last_result: Dictionary = {}
var result_serial := 0
var breakthrough_text := ""
var focus_paused := false
var rebirth_enabled := true
var presentation_enabled := true
var phase := ""
var sequence: Array = []
var phase_duration := 0.0
var resume_state := "idle"

func _init() -> void:
	rng.randomize()
	auto_rng.randomize()
	economy_rng.randomize()
	reset()

func reset() -> void:
	sect = preload("res://scripts/sect_state.gd").new()
	sicbo = null
	stake_free = 0;stake_paid = 0;entry_shares = 1
	blood = null
	blood_counter = 0
	blood_due = false
	blood_schedule_rng.randomize()
	blood_threshold = blood_schedule_rng.randi_range(B.INTERVAL[0],B.INTERVAL[1])
	blood_items = {"魔道素材":0,"魔器碎片":0,"幽冥玉髓":0}
	developer_test_session = false
	sfx_event.emit("stop_all")
	unlock_notified.clear()
	unlock_queue.clear()
	board.clear()
	board_attempt = -1
	selected_opponent = -1
	tournament = null
	festival_seen = 740
	festival_pending = 0
	keepsakes = {"天機令":0,"古劍殘片":0}
	duel = null
	first_passive_seen = false
	duel_schedule_version = 2
	bone_target_pending = false
	duel_counter = 0
	duel_threshold = economy_rng.randi_range(D.FIRST_INTERVAL[0],D.FIRST_INTERVAL[1])
	duel_due = false
	duel_count = 0
	last_passive_npc = -1
	treasures.assign([0,0,0])
	practice_completed = false
	result_delay = 0
	feedback_kind = ""
	pending_result.clear()
	modal.clear()
	help_seen.clear()
	new_features.clear()
	foundation_unlock_granted = false
	auto_after_help = false
	activity_counters = {"flying_boat":0,"sword_race":0,"mines":0}
	overrides.clear()
	tickets = {"flying_boat":0, "sword_race":0, "mines":0}
	activity_id = ""
	pending_activity = ""
	auto_before_activity = false
	entry_paid = false
	ticket_notice = ""
	notification_events.clear()
	notified_rewards.clear()
	auto_enabled = false
	auto_owned = false
	auto_rest = 0.0
	foundation = null
	foundation_grade = 0
	dao_foundation_type = ""
	dao_foundation_flags.clear()
	foundation_multiplier = 1.0
	foundation_completed = false
	foundation_seen = 0
	run_serial += 1
	state = "idle"
	age = C.STARTING_AGE
	lifespan = C.STARTING_LIFESPAN
	realm = 0
	cultivation = 0
	hold = 0.0
	risk = 0.0
	potential = 0
	attempts = 0
	failures = 0
	first_rebirth_complete = false
	rebirths = 0
	successes = 0
	biggest_gain = 0
	recent.clear()
	history.assign(["16 歲｜天妒纏身，開始修仙"])
	last_result = {}
	result_serial += 1
	breakthrough_text = ""
	pause_left = 0.0
	pending_rebirth = false
	focus_paused = false
	phase = ""
	sequence.clear()
	resume_state = "idle"
	array_attempts = 0
	spirit_stones = 0
	opportunity = false
	boat.reset()
	raw_stones.assign([0,0,0,0])
	materials.assign([0,0,0,0,0])
	fragments = 0
	pills.assign([0,0,0,0,0])
	upper_pills.assign([0,0,0,0,0])
	alchemy = null
	stone = null
	race = null
	mines = null
	gain_pill = false
	protection_pill = false
	attempt_modifier = 1.0
	attempt_protected = false

func begin() -> void:
	if not modal.is_empty() or state != "idle" or not activity_id.is_empty() or not pending_activity.is_empty() or realm >= C.FOUNDATION_COMPLETE:
		return
	attempt_modifier = (C.GAIN_PILL_MULTIPLIER if gain_pill else 1.0) * C.foundation_modifier(foundation_grade)
	if array_attempts > 0:
		attempt_modifier *= E.ARRAY_BONUS
		array_attempts -= 1
	attempt_protected = protection_pill
	if gain_pill: history.append("%.1f 歲｜服用聚氣丹，本次收益 ×1.5" % age)
	if protection_pill: history.append("%.1f 歲｜服用護脈丹，本次失控保留部分收益" % age)
	gain_pill = false
	protection_pill = false
	state = "holding"
	sfx_event.emit("charge")
	hold = 0.0
	risk = 0.0
	potential = 0
	focus_paused = false
	hazard_budget = -log(maxf(rng.randf(), 0.000000001))

func advance(delta: float) -> void:
	if modal.get("id","") == "calendar": modal.text = calendar_text()
	if modal.get("kind","") == "waiting_help":
		modal.wait -= delta
		if modal.wait <= 0: modal.kind = "help"
		return
	sect.tick(self)
	if sect.offer_story(self): return
	check_calendar()
	check_unlocks()
	if show_next_unlock(): return
	if show_festival_offer(): return
	if show_blood_offer(): return
	if not modal.is_empty(): return
	if result_delay > 0:
		if activity_id == "duel" and duel != null: duel.feedback_left = maxf(0,duel.feedback_left-delta)
		result_delay = maxf(0,result_delay-delta)
		if result_delay == 0:
			if pending_result.get("route","") == "tournament_final":
				pending_result.clear()
				activate_activity("tournament")
			else:
				modal = pending_result.duplicate()
				pending_result.clear()
		return
	if focus_paused:
		return
	if challenges_enabled and duel_due and (sect.duel_taught or not tutorials_enabled) and state == "idle" and activity_id.is_empty() and pending_activity.is_empty():
		enter_side_activity("duel")
		return
	if state == "idle" and not pending_activity.is_empty():
		var requested := pending_activity
		pending_activity = ""
		activate_activity(requested)
		return
	if state == "activity":
		if activity_id in ["blood","jade"] and blood != null:
			blood.extra_swap = sect.inventory.get("換命符",0) > 0 and not blood.relic_used.has("換命符")
			blood.advance(delta)
			update_jade()
			finish_blood()
		if activity_id == "sicbo" and sicbo != null:
			var previous_die: int = sicbo.index
			sicbo.advance(delta)
			if sicbo.index != previous_die: sfx_event.emit("blood_bone")
			sect.finish_sicbo(self)
		if activity_id == "tournament" and tournament != null:
			var previous: int = tournament.ceremony
			tournament.advance(delta)
			if tutorials_enabled and tournament.kind == "sect" and tournament.stage == "final" and tournament.wins == tournament.total_matches() and not sect.runner_up_seen:
				tournament.story_delay -= delta
				if tournament.story_delay <= 0: sect.story(self,"runner_up",sect.L.RUNNER_UP)
			if tournament.ceremony != previous and tournament.ceremony == 2: sfx_event.emit("tournament_champion")
		if activity_id == "duel" and duel != null:
			if duel.skill_pause<=0 and not duel.narrative_lines.is_empty():
				var lines: Array=duel.narrative_lines.duplicate(true);duel.narrative_lines.clear()
				sect.story(self,"duel_banter",lines);return
			if duel.story_mode.is_empty() and not duel.fair:
				if sect.senior_lesson_complete: sect.probe_learned = true
				if sect.probe_learned:
					duel.learned_probe = true;duel.peeked = true
			if duel.story_mode.is_empty() and duel.can_double() and not sect.seen.has("double_help"):
				sect.seen["double_help"] = true
				duel.ability_notice("起手十或十一，可孤注一劍。再抽一印就收劍，勝負算兩籌。")
			duel.advance(delta)
			finish_duel()
		if activity_id == "sword_race" and race != null:
			var old_elapsed: float = race.elapsed
			race.advance(delta)
			if old_elapsed < 1.5 and race.elapsed >= 1.5: sfx_event.emit("sword_race_flyby")
			if old_elapsed < 3 and race.elapsed >= 3: sfx_event.emit("sword_race_overtake")
			if race.state == "result" and not race.paid_out: finish_race()
		if activity_id == "alchemy" and alchemy != null:
			alchemy.advance(delta)
			finish_alchemy()
		return
	if state == "foundation":
		foundation.advance(delta)
		update_foundation()
	elif state in ["rupture", "presenting"]:
		advance_presentation(delta)
	elif state == "ship":
		var old_multiplier: float = boat.multiplier
		boat.advance(delta)
		if old_multiplier < 3 and boat.multiplier >= 3: sfx_event.emit("boat_danger")
		if boat.state in ["crashed","collected"]: finish_boat()
	elif state == "holding":
		if resolve_debug_cultivation(): return
		var next_hold := minf(hold + delta * C.AUTO_SPEED, auto_target) if auto_owned else hold + delta
		if C.cumulative_hazard(next_hold) >= hazard_budget:
			hold = C.failure_time(hazard_budget, next_hold)
			risk = C.instability(hold)
			potential = C.cultivation_gain(hold, realm, attempt_modifier)
			fail()
		else:
			hold = next_hold
			risk = C.instability(hold)
			potential = C.cultivation_gain(hold, realm, attempt_modifier)

		if auto_owned and state == "holding" and hold >= auto_target: release()
	elif state == "idle" and auto_enabled and realm < C.FOUNDATION_COMPLETE:
		auto_rest -= delta
		if auto_rest <= 0.0:
			auto_target = C.hold_for_instability(auto_rng.randf_range(C.AUTO_INSTABILITY[0], C.AUTO_INSTABILITY[1]))
			begin()
			auto_owned = state == "holding"

func set_auto(enabled: bool) -> void:
	if enabled and tutorials_enabled and not help_seen.has("auto") and realm >= C.FOUNDATION_REALM:
		auto_after_help = true
		show_help("auto")
		return
	new_features.erase("auto")
	auto_enabled = enabled and realm >= C.FOUNDATION_REALM and realm < C.FOUNDATION_COMPLETE and state != "dead" and activity_id.is_empty() and pending_activity.is_empty()
	if not auto_enabled and auto_owned and state == "holding": release()

func release() -> void:
	if not modal.is_empty(): return
	if state == "holding":
		if resolve_debug_cultivation(): return
		settle("success")

func fail(force_rebirth: int = -1) -> void:
	if state != "holding":
		return
	state = "rupture"
	failures += 1
	pause_left = C.FAILURE_PAUSE
	var rebirth_chance: float = C.REBIRTH_CHANCE
	if not first_rebirth_complete and rebirths == 0 and realm < C.FOUNDATION_REALM:
		rebirth_chance = C.FIRST_REBIRTH_WEIGHTS[mini(failures,C.FIRST_REBIRTH_DEADLINE)]
	pending_rebirth = (rng.randf() < rebirth_chance and rebirth_enabled) if force_rebirth < 0 else force_rebirth == 1
	sfx_event.emit("stop_charge")
	if not pending_rebirth: sfx_event.emit("cultivation_failure")
	if not presentation_enabled:
		settle("rebirth" if pending_rebirth else "failure")
		return
	sequence = C.LOSS_SEQUENCE.duplicate(true)
	if pending_rebirth:
		sequence.append_array(C.REBIRTH_SEQUENCE.duplicate(true))
	next_phase()

func next_phase() -> void:
	var item: Array = sequence.pop_front()
	phase = item[0]
	phase_duration = item[1]
	pause_left = phase_duration
	if phase == "silence": sfx_event.emit("silence")
	if phase == "reversal": sfx_event.emit("cultivation_rebirth")

func advance_presentation(delta: float) -> void:
	var remaining := delta
	while state in ["rupture", "presenting"] and remaining >= 0.0:
		if remaining < pause_left:
			pause_left -= remaining
			break
		remaining -= pause_left
		if not sequence.is_empty():
			next_phase()
		elif state == "rupture":
			settle("rebirth" if pending_rebirth else "failure")
		else:
			state = resume_state
			phase = ""
			break

func requirement() -> int:
	return C.REQUIREMENTS[realm] if realm < C.REQUIREMENTS.size() else 0

func settle(outcome: String) -> void:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if state not in ["holding", "rupture"]:
		return
	auto_owned = false
	auto_rest = C.AUTO_REST
	sfx_event.emit("stop_charge")
	if outcome == "success":
		sfx_event.emit("cultivation_good_release" if risk < C.COMMENT_BOUNDS[2] else ("cultivation_risky_release" if risk < C.COMMENT_BOUNDS[3] else "cultivation_extreme_release"))
	var needed := requirement()
	var reward := potential if outcome == "success" else 0
	if outcome == "rebirth":
		reward = potential * C.REBIRTH_MULTIPLIER
		rebirths += 1
		first_rebirth_complete = true
	elif outcome == "failure" and attempt_protected:
		reward = int(floor(potential * C.PROTECTION_RETAIN))
	elif outcome == "success":
		successes += 1
	recent.append(reward)
	if recent.size() > C.RECENT_COUNT:
		recent.pop_front()
	# Capture pre-reset, pre-breakthrough facts for deterministic commentary.
	last_result = {
		"outcome": outcome, "hold_duration": hold, "instability": risk,
		"hold_fraction": hold / C.INSTABILITY_SECONDS,
		"potential": potential, "gain": reward, "lost_potential": potential - reward if outcome == "failure" else 0,
		"potential_ratio": float(potential) / maxf(needed, 1),
		"remaining_attempts": maxf(lifespan - age, 0.0) / C.time_cost(realm)
	}
	last_result["comment"] = C.commentary(last_result)
	attempts += 1
	sect.completed(self,outcome)
	if realm >= C.FOUNDATION_REALM:
		blood_counter += 1
		if blood_threshold == 0: blood_threshold = blood_schedule_rng.randi_range(B.INTERVAL[0],B.INTERVAL[1])
		if blood_counter >= blood_threshold: blood_due = true
		if sect.duel_taught or not tutorials_enabled:
			duel_counter += 1
			if duel_counter >= mini(duel_threshold,D.HARD_LIMIT): duel_due = true
	var notices: Array[String] = []
	for key in E.TICKETS:
		if not activity_unlocked(key): continue
		activity_counters[key] += 1
		if activity_counters[key] % E.TICKETS[key] == 0:
			tickets[key] += 1
			queue_ticket_notification(key)
			notices.append("%s +1（持有 %d）" % [E.NAMES[key], tickets[key]])
	if not notices.is_empty():
		opportunity_serial += 1
		ticket_notice = "\n".join(notices)
		history.append("%.1f 歲｜機緣累積\n%s" % [age, ticket_notice])
	age = snappedf(age + C.time_cost(realm),0.000001)
	cultivation += reward
	biggest_gain = maxi(biggest_gain, reward)
	var outcome_name := "收功"
	if outcome == "failure":
		outcome_name = "走火入魔"
	elif outcome == "rebirth":
		outcome_name = "走火入魔……破而後立！"
	var entry := "%.1f 歲｜%s｜%s
+%d 修為" % [age, outcome_name, last_result.comment, reward]
	if outcome == "failure":
		entry += "（未收回潛在 %d）" % (potential - reward)
	history.append(entry)
	breakthrough_text = ""
	apply_breakthroughs()
	if age >= lifespan - 0.0000001:
		state = "dead"
		auto_enabled = false
		pending_activity = ""
		activity_id = ""
		auto_before_activity = false
		array_attempts = 0
		gain_pill = false
		protection_pill = false
		history.append("%.1f 歲｜坐化" % age)
	elif realm == C.QI_COMPLETE:
		state = "foundation_ready"
		history.append("%.1f 歲｜練氣已圓滿，下一步：九宫灵纹铸基" % age)
	else:
		state = "idle"
	if realm >= C.FOUNDATION_COMPLETE: auto_enabled = false
	hold = 0.0
	risk = 0.0
	potential = 0
	result_serial += 1
	resume_state = state
	if presentation_enabled and (outcome == "rebirth" or not breakthrough_text.is_empty()):
		state = "presenting"
		sequence = [["reward", C.REWARD_SECONDS]]
		if not breakthrough_text.is_empty():
			sequence.append(["breakthrough", C.BREAKTHROUGH_SECONDS])
		next_phase()
	else:
		phase = ""

func apply_breakthroughs() -> void:
	while requirement() > 0 and cultivation >= requirement():
		var old_realm: String = C.REALMS[realm]
		var old_lifespan := lifespan
		cultivation -= requirement()
		lifespan += C.LIFESPAN_REWARDS[realm]
		realm += 1
		sect.event_until = attempts+sect.C.EVENT_GAP
		sfx_event.emit("realm_breakthrough")
		recent.clear()
		var message := "突破！%s → %s
壽元 %.0f → %.0f（+%.0f 年）" % [old_realm, C.REALMS[realm], old_lifespan, lifespan, lifespan - old_lifespan]
		if not breakthrough_text.is_empty():
			breakthrough_text += "
"
		breakthrough_text += message
		history.append("%.1f 歲｜%s" % [age, message])

func projection() -> Dictionary:
	var years := maxf(lifespan - age, 0.0)
	var remaining := int(floor((years + 0.0000001) / C.time_cost(realm)))
	var needed := maxi(requirement() - cultivation, 0)
	var average := 0.0
	for value in recent:
		average += value
	if not recent.is_empty():
		average /= recent.size()
	var required_exact := float(needed) / remaining if remaining > 0 else -1.0
	if needed == 0: required_exact = 0.0
	var required_average := int(ceil(required_exact))
	var status := "天機未明"
	var level := "unknown"
	if needed == 0:
		status = ("練氣已圓滿 · 下一步：九宫灵纹铸基" if realm == C.QI_COMPLETE else "築基圓滿 · 準備結丹") if requirement() == 0 else "已達突破需求"
		level = "positive"
	elif remaining == 0:
		status = "已無可用修煉次數"
		level = "urgent"
	elif recent.size() >= C.MIN_RECENT_COUNT:
		if average < required_exact:
			status = "進度不足"
			level = "urgent"
		elif average < required_exact * C.PROJECTION_COMFORT_MULTIPLIER:
			status = "時間緊迫"
			level = "warning"
		else:
			status = "進度充裕"
			level = "positive"
	return {"required_average": required_average, "required_average_exact": required_exact, "samples": recent.size(), "years": years, "remaining": remaining, "needed": needed, "average": average, "status": status, "level": level}

func debug_action(action: String) -> void:
	if not OS.is_debug_build():
		return
	if action == "reset":
		reset()
	elif action == "stones" and state == "idle":
		spirit_stones += 1000
		history.append("開發工具｜+1000 靈石")
	elif action == "opportunity" and state == "idle":
		grant_opportunity()
	elif action == "crash" and state == "ship":
		boat.state = "crashed"
		boat.reward = 0
		finish_boat()
	elif action == "high" and state == "ship":
		boat.elapsed = log(12.0) / C.BOAT_MULTIPLIER_RATE
		boat.multiplier = C.boat_multiplier(boat.elapsed)
		boat.hazard_budget = C.boat_hazard_integral(boat.elapsed) + 1.0
	elif action == "give_gain" and state == "idle":
		gain_pill = true
	elif action == "give_protection" and state == "idle":
		protection_pill = true
	elif action == "age" and state == "idle":
		age = lifespan - C.time_cost(realm)
		history.append("開發工具｜年齡調至瀕死")
	elif action == "gain" and state == "idle":
		cultivation += 1000
		history.append("開發工具｜+1000 修為")
		apply_breakthroughs()
		resume_state = "foundation_ready" if realm == C.QI_COMPLETE else "idle"
		state = resume_state
	elif action in ["failure", "rebirth"] and state in ["idle", "holding"]:
		if state == "idle":
			begin()
			hold = C.INSTABILITY_SECONDS * 0.70
			risk = C.instability(hold)
			potential = C.cultivation_gain(hold, realm, attempt_modifier)
		fail(1 if action == "rebirth" else 0)

func enter_side_activity(id: String) -> bool:
	if not modal.is_empty() or result_delay > 0 or not activity_id.is_empty() or not pending_activity.is_empty(): return false
	if id not in ["flying_boat","sword_race","mines","stone_gambling","alchemy","shop","lobby","opportunities","preparation","duel","active_duel","tournament","blood","sect","jade","sicbo","pavilion","materials"]: return false
	if id not in ["flying_boat","shop","opportunities","sect","sicbo"] and realm < C.FOUNDATION_REALM: return false
	if id == "active_duel" and (realm < D.ACTIVE_REALM or (tutorials_enabled and not sect.duel_taught)): return false
	if id == "pavilion" and not sect.pavilion_unlocked: return false
	if E.TICKETS.has(id) and not can_pay_entry(id): return false
	if state != "idle" and not (auto_enabled and state in ["holding","rupture","presenting"]): return false
	auto_before_activity = auto_enabled
	auto_enabled = false
	if state != "idle":
		pending_activity = id
	else: activate_activity(id)
	return true

func activate_activity(id: String) -> void:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	activity_id = id
	new_features.erase(id)
	unlock_notified[id] = true
	unlock_queue.erase(id)
	if tutorials_enabled and id != "jade" and not help_seen.has(id): show_help(id,true)
	entry_paid = false
	entry_was_free = false
	if id in E.TICKETS: reset_stake(id)
	sfx_event.emit("stop_charge")
	state = "shop" if id == "shop" else ("ship_ready" if id == "flying_boat" else "activity")
	if id == "flying_boat": boat.reset()
	if id == "sword_race": race = preload("res://scripts/sword_race.gd").new()
	if id == "mines": mines = preload("res://scripts/mines_state.gd").new()
	if id == "stone_gambling": stone = preload("res://scripts/stone_state.gd").new()
	if id == "alchemy":
		new_features.erase("real_alchemy")
		alchemy = preload("res://scripts/alchemy_state.gd").new()
		alchemy.cue.connect(_foundation_cue)
	if id in ["blood","jade"]:
		blood = preload("res://scripts/blood_state.gd").new()
		blood.cue.connect(_foundation_cue)
		if id == "blood":
			blood_counter = 0
			blood_due = false
			blood_threshold = blood_schedule_rng.randi_range(B.INTERVAL[0],B.INTERVAL[1])
		else: blood.practice = true
	if id == "active_duel": refresh_board()
	if id == "tournament" and tournament == null:
		tournament = preload("res://scripts/tournament_state.gd").new()
		tournament.year = festival_seen
	if id == "duel":

		duel = preload("res://scripts/duel_state.gd").new()
		duel.overrides = overrides
		duel.player_level = realm
		if sect.senior_lesson_complete: sect.probe_learned = true
		duel.learned_probe = sect.probe_learned
		duel.npc_id = 0 if duel_count == 0 else NPC.choose(economy_rng,last_passive_npc,realm)
		duel.archetype = overrides.take("duel.archetype",NPC.NPCS[duel.npc_id].economy)
		if selected_opponent >= 0:
			duel.archetype = board[selected_opponent].archetype
			duel.npc_id = board[selected_opponent].get("npc_id",-1)
			duel.active_challenge = true
			duel.source = "active"
			selected_opponent = -1
		duel.cue.connect(_foundation_cue)
		duel_count += 1
		if not duel.active_challenge:
			last_passive_npc = duel.npc_id
			first_passive_seen = true
			duel_counter = 0
			duel_threshold = economy_rng.randi_range(D.INTERVAL[0],D.INTERVAL[1])
			duel_due = false
		sfx_event.emit("duel_arrival")

func exit_side_activity() -> void:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if activity_id in ["blood","jade"] and blood.state != "result": return
	if activity_id == "sicbo" and sicbo != null and sicbo.state == "rolling": return
	if activity_id == "tournament" and tournament.stage != "final": return
	if activity_id == "duel" and duel.state != "result": return
	if not modal.is_empty() or result_delay > 0 or activity_id.is_empty() or state == "ship": return
	if activity_id == "sword_race" and race.state == "racing": return
	if activity_id == "mines" and mines.state == "mining": return
	if activity_id == "stone_gambling" and stone.state not in ["ready","result"]: return
	if activity_id == "alchemy" and alchemy.state not in ["ready","result"]: return
	sfx_event.emit("stop_all")
	sfx_event.emit("ui_cancel")
	if activity_id == "duel" and tournament != null and tournament.stage != "done":
		activate_activity("tournament")
		return
	if activity_id == "tournament":
		tournament.stage = "done"
		sect.event_until = attempts+sect.C.EVENT_GAP
	if activity_id == "materials": activate_activity("lobby");return
	if activity_id in ["jade","sicbo"] or (activity_id == "duel" and duel.source in ["senior","junior"]):
		activate_activity("sect")
		return
	if activity_id == "duel" and duel.active_challenge:
		activate_activity("active_duel")
		return
	sect.reset_master_clicks()
	activity_id = ""
	entry_paid = false
	state = "idle"
	set_auto(auto_before_activity)
	auto_before_activity = false
	auto_rest = C.AUTO_REST

func can_pay_entry(id: String) -> bool:
	return tickets.get(id,0) > 0 or (realm >= C.FOUNDATION_REALM and spirit_stones >= E.ENTRY_COST)

func reset_stake(id: String):
	stake_free = 1 if tickets.get(id,0) > 0 else 0
	stake_paid = 1 if stake_free == 0 and realm >= C.FOUNDATION_REALM else 0
	entry_shares = 1
func set_stake(free: int, cash: int):
	if entry_paid or activity_id not in E.TICKETS: return
	stake_free = clampi(free,0,tickets.get(activity_id,0))
	stake_paid = clampi(cash,0,spirit_stones/entry_cost(activity_id)) if realm >= C.FOUNDATION_REALM else 0
func entry_cost(id: String) -> int: return E.ENTRY_COSTS.get(id,E.ENTRY_COST)
func valid_stake() -> bool:
	return activity_id in E.TICKETS and not entry_paid and stake_free >= 0 and stake_paid >= 0 and stake_free+stake_paid > 0 and stake_free <= tickets.get(activity_id,0) and (stake_paid == 0 or realm >= C.FOUNDATION_REALM) and stake_paid*entry_cost(activity_id) <= spirit_stones
func pay_entry(id: String) -> bool:
	if not modal.is_empty() or result_delay > 0 or activity_id != id or not valid_stake(): return false
	entry_free = stake_free;entry_cash = stake_paid;entry_shares = stake_free+stake_paid
	tickets[id] -= stake_free;spirit_stones -= stake_paid*entry_cost(id)
	entry_was_free = stake_paid == 0
	entry_paid = true;last_raw_drop = -1
	history.append("%s｜免費券 %d 張 · 靈石 %d · 共 %d 份" % [E.NAMES[id],stake_free,stake_paid*entry_cost(id),entry_shares])
	return true

func enter_opportunity() -> void:
	if can_pay_entry("flying_boat"): enter_side_activity("flying_boat")

func start_boat() -> void:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if state != "ship_ready" or not pay_entry("flying_boat"): return
	boat.reward_base = C.BOAT_BASE_STONES*entry_free + E.PAID_BOAT_BASE*entry_cash
	state = "ship"
	boat.overrides = overrides
	boat.start()
	sfx_event.emit("boat_launch")

func collect_boat() -> void:
	if state != "ship": return
	boat.collect()
	finish_boat()

func finish_boat() -> void:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if state != "ship" or boat.state not in ["crashed", "collected"]: return
	state = "ship_result"
	sfx_event.emit("boat_crash" if boat.state == "crashed" else "boat_cashout")
	spirit_stones += boat.reward
	if boat.reward > 0: award_raw_stone()
	queue_result("靈舟墜毀" if boat.state == "crashed" else "靈舟歸來", reward_description(boat.reward),"boat_crash" if boat.state == "crashed" else "collect")
	history.append("%.1f 歲｜飛升靈舟 ×%.2f %s\n+%d 靈石" % [age, boat.multiplier, "收取成功" if boat.state == "collected" else "靈舟墜毀", boat.reward])

func leave_boat() -> void:
	if state in ["ship_ready", "ship_result"]: exit_side_activity()

func open_shop() -> void:
	enter_side_activity("shop")

func close_shop() -> void:
	if state == "shop": exit_side_activity()

func can_purchase(item: String) -> bool:
	if state != "shop" or not C.SHOP.has(item): return false
	if spirit_stones < C.SHOP[item].price: return false
	if item == "gain" and gain_pill: return false
	if item == "protection" and protection_pill: return false
	if item == "breakthrough" and not pill_realm_allowed(): return false
	return true

func purchase(item: String) -> void:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if not can_purchase(item): return
	spirit_stones -= C.SHOP[item].price
	sfx_event.emit("shop_purchase")
	history.append("%.1f 歲｜購買%s，-%d 靈石" % [age, C.SHOP[item].name, C.SHOP[item].price])
	match item:
		"gain": gain_pill = true
		"protection": protection_pill = true
		"longevity":
			lifespan += C.LONGEVITY_YEARS
			history.append("%.1f 歲｜延壽丹，壽元增至 %.0f" % [age, lifespan])
		"breakthrough":
			apply_breakthrough_pill()

const BREAKTHROUGH_PILL = "破境丹"
func pill_realm_allowed() -> bool:
	return realm >= 0 and realm < C.FOUNDATION_COMPLETE and realm != C.QI_COMPLETE
func pill_unavailable_reason() -> String:
	if not pill_realm_allowed(): return "已到大境界盡頭，破境丹不能跨境"
	if spirit_stones < C.SHOP.breakthrough.price: return "靈石不足"
	return ""
func breakthrough_pill_count() -> int:
	return int(sect.inventory.get(BREAKTHROUGH_PILL,0))
func debug_set_breakthrough_pills(amount: int) -> void:
	if not OS.is_debug_build(): return
	sect.inventory[BREAKTHROUGH_PILL] = maxi(0,amount)
	save_session()
func can_use_breakthrough_pill() -> bool:
	return breakthrough_pill_count() > 0 and pill_realm_allowed() and state in ["idle","shop"] and modal.is_empty()
func use_breakthrough_pill() -> void:
	if not can_use_breakthrough_pill(): return
	sect.inventory[BREAKTHROUGH_PILL] = breakthrough_pill_count()-1
	apply_breakthrough_pill()
	save_session()
func apply_breakthrough_pill() -> void:
	exit_side_activity()
	var old: String = C.REALMS[realm]
	lifespan += C.LIFESPAN_REWARDS[realm]
	realm += 1
	sfx_event.emit("realm_breakthrough")
	recent.clear()
	breakthrough_text = "破境丹：%s → %s\n壽元延至 %.0f 歲，已有修為保留" % [old, C.REALMS[realm], lifespan]
	history.append("%.1f 歲｜%s" % [age, breakthrough_text])
	resume_state = "foundation_ready" if realm == C.QI_COMPLETE else "idle"
	state = resume_state
	if presentation_enabled:
		state = "presenting"
		sequence = [["breakthrough", C.BREAKTHROUGH_SECONDS]]
		next_phase()

func grant_opportunity() -> void:
	tickets.flying_boat += 1
	queue_ticket_notification("flying_boat")
	ticket_notice = "飛升靈舟 +1（持有 %d）" % tickets.flying_boat
	opportunity_serial += 1

func start_foundation() -> void:
	if state != "foundation_ready" or foundation_grade > 0: return
	foundation = preload("res://scripts/foundation_state.gd").new()
	foundation.overrides = overrides
	foundation.cue.connect(_foundation_cue)
	foundation_seen = 0
	state = "foundation"
	history.append("%.1f 歲｜登上九宫灵纹铸基，一品道基已成" % age)
	new_features.erase("foundation")
	if tutorials_enabled and not sect.seen.has("foundation_rules_v2"): show_help("foundation",true)
func update_foundation() -> void:
	if foundation == null or foundation.state != "locked" or foundation_grade > 0: return
	foundation_seen = foundation.serial
	foundation_grade = foundation.grade
	dao_foundation_type = foundation.result.type
	dao_foundation_flags = foundation.result.flags.duplicate()
	foundation_multiplier = C.foundation_modifier(foundation_grade)
	foundation_completed = true
	sect.event_until = attempts+sect.C.EVENT_GAP
	realm = C.FOUNDATION_REALM
	lifespan += C.FOUNDATION_LIFE_REWARD
	recent.clear()
	state = "idle"
	grant_foundation_unlock()
	breakthrough_text = "%d品 · %s\n修炼修为获取：+%d%% · 寿元 +20年" % [foundation_grade,foundation.result.name,int(round((foundation_multiplier-1.0)*100))]
	if foundation.result.flaw: breakthrough_text += "\n道基有瑕，品数加成仍按最终品数计算。"
	history.append("%.1f 岁｜%s" % [age,breakthrough_text])
	queue_result("筑基定型",breakthrough_text,"foundation_result")
	save_session()
func foundation_debug(action: String, grade_value: int = 1) -> void:
	if not OS.is_debug_build(): return
	if action in ["qi9","complete","start"]:
		if state not in ["idle","foundation_ready"]: return
		realm = 8 if action == "qi9" else C.QI_COMPLETE
		cultivation = 0
		lifespan = maxf(lifespan,age+10)
		recent.clear()
		state = "idle" if action == "qi9" else "foundation_ready"
		if action == "start": start_foundation()
	elif state == "foundation" and foundation.state == "choice":
		if action == "grade":
			foundation.grade = clampi(grade_value,1,9)
			if foundation.grade == 9: foundation.stop()
		else: foundation.attempt(action if action in ["success","rebirth"] else "failure",int(action) if action.is_valid_int() else 0)

func _foundation_cue(key: String) -> void:
	sfx_event.emit(key)

func start_race(choice: int, forced: int = -1) -> void:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if activity_id != "sword_race" or race.state != "ready" or choice < 0 or choice > 4: return
	if not pay_entry("sword_race"): return
	var winner: int = overrides.take("race.winner",forced if OS.is_debug_build() else -1)
	if winner == 5: winner = (choice+1)%5
	race.start(choice,winner)
	sfx_event.emit("sword_race_start")
func finish_race() -> void:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if race.state != "result" or race.paid_out: return
	race.paid_out = true
	race.reward *= entry_shares
	spirit_stones += race.reward
	if race.reward > 0: award_raw_stone()
	sfx_event.emit("sword_race_finish")
	sfx_event.emit("sword_race_win" if race.reward > 0 else "sword_race_lose")
	queue_result("%s奪魁" % E.RACE_NAMES[race.winner] if race.reward > 0 else "惜敗","%s奪魁\n你的選擇：%s" % [E.RACE_NAMES[race.winner],E.RACE_NAMES[race.selected]]+("\n"+reward_description(race.reward) if race.reward > 0 else ""),"collect" if race.reward > 0 else "race_loss")
	if presentation_enabled:
		modal=pending_result.duplicate();pending_result.clear();result_delay=0
	history.append("飛劍競速｜%s 勝出 · +%d 靈石" % [E.RACE_NAMES[race.winner],race.reward])
func start_mines() -> void:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if activity_id != "mines" or mines.state != "ready" or not pay_entry("mines"): return
	mines.start()
	sfx_event.emit("mines_reveal")
func reveal_mine(cell: int) -> void:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if activity_id != "mines" or mines.state != "mining" or cell in mines.revealed: return
	if cell < 0 or cell >= 25: return
	var forced: String = overrides.take("mines.tile")
	if forced in ["danger","high_failure"]:
		if forced == "high_failure": mines.reward = 5000
		if cell not in mines.dangers: mines.dangers.append(cell)
	elif forced in ["safe","ordinary","rare"]:
		mines.dangers.erase(cell)
		mines.crystals[cell] = "rare" if forced == "rare" else "ordinary"
	mines.reveal(cell)
	sfx_event.emit("mines_failure" if mines.state == "failed" else ("mines_rare" if mines.crystals.get(cell,"") == "rare" else "mines_ordinary"))
	if mines.state == "mining" and mines.reward >= 500: sfx_event.emit("mines_danger")
	finish_mines()
func collect_mines() -> void:
	if activity_id != "mines": return
	mines.collect()
	if mines.state == "collected": sfx_event.emit("mines_cashout")
	finish_mines()
func finish_mines() -> void:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if mines.state not in ["failed","collected"] or mines.paid_out: return
	mines.paid_out = true
	mines.reward *= entry_shares
	mines.lost_reward *= entry_shares
	spirit_stones += mines.reward
	if mines.reward > 0: award_raw_stone()
	queue_result("礦脈崩塌" if mines.state == "failed" else "滿載而歸","探索 %d 處\n" % mines.revealed.size()+("未收取的 %d 靈石全部失去。" % mines.lost_reward if mines.state == "failed" else reward_description(mines.reward)),"mines_failure" if mines.state == "failed" else "collect")
	history.append("靈礦探寶｜%s · +%d 靈石" % ["安全歸來" if mines.state == "collected" else "煞氣爆發",mines.reward])

func award_raw_stone() -> void:
	last_raw_drop = -1
	if economy_rng.randf() >= E.RAW_DROP_CHANCE: return
	var roll := economy_rng.randf()
	var tier := 3
	for i in range(4):
		roll -= E.RAW_WEIGHTS[i]
		if roll <= 0:
			tier = i
			break
	raw_stones[tier] += entry_shares
	last_raw_drop = tier
	history.append("機緣所得｜%s +%d" % [E.RAW_NAMES[tier],entry_shares])
func open_stone(tier: int, service: int, force: String = "") -> bool:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if activity_id != "stone_gambling" or stone.state != "ready": return false
	if tier < 0 or tier > 3 or service < 0 or service > 3: return false
	if raw_stones[tier] <= 0 or spirit_stones < E.ASSISTANCE_COST[service]: return false
	raw_stones[tier] -= 1
	spirit_stones -= E.ASSISTANCE_COST[service]
	stone.overrides = overrides
	if not force.is_empty(): overrides.arm("stone.result",force)
	stone.start(tier,service)
	return true
func scratch_stone(point: Vector2) -> void:
	if activity_id != "stone_gambling" or stone.state != "scratching": return
	stone.scratch(point)
	if stone.state == "choice": sfx_event.emit("stone_rare_reveal" if stone.rewards[stone.depth].material >= 3 else "stone_reveal")
	finish_stone()
func collect_stone() -> void:
	if activity_id != "stone_gambling": return
	stone.collect()
	finish_stone()
func finish_stone() -> void:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if stone.state != "result" or stone.paid_out: return
	stone.paid_out = true
	var r: Dictionary = stone.result
	if r.failed: sfx_event.emit("stone_crack")
	if r.material >= 0: materials[r.material] += r.quantity
	fragments += r.fragments
	sfx_event.emit("stone_protection" if r.protected else ("stone_shatter" if r.failed else "stone_collect"))
	queue_result("護石符護住前層" if r.protected else ("原石碎裂" if r.failed else "解石入庫"),("%s ×%d\n" % [E.MATERIAL_NAMES[r.material],r.quantity] if r.material >= 0 else "未能收回材料\n")+"石髓碎片 +%d" % r.fragments,"stone_protection" if r.protected else ("stone_shatter" if r.failed else "collect"))
	history.append("解石｜%s%s · %s · 碎片 +%d" % ["石裂" if r.failed else "收石","，護符保住前層" if r.protected else "", "%s ×%d" % [E.MATERIAL_NAMES[r.material],r.quantity] if r.material >= 0 else "無材料",r.fragments])
func exchange_fragments(material: int) -> void:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if activity_id != "stone_gambling" or stone.state not in ["ready","result"] or material < 0 or material > 4: return
	if fragments < E.PITY_COST[material]: return
	fragments -= E.PITY_COST[material]
	materials[material] += 1
	history.append("碎片兌換｜%s +1" % E.MATERIAL_NAMES[material])

func can_start_recipe(index: int) -> bool:
	if (tutorials_enabled and not practice_completed) or activity_id != "alchemy" or alchemy.state != "ready" or index < 0 or index > 4: return false
	if spirit_stones < E.RECIPE_COST[index]: return false
	for i in range(5):
		if materials[i] < E.RECIPES[index][i]: return false
	return true
func start_recipe(index: int, forced: String = "") -> void:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if not can_start_recipe(index): return
	spirit_stones -= E.RECIPE_COST[index]
	for i in range(5): materials[i] -= E.RECIPES[index][i]
	alchemy.overrides = overrides
	if not forced.is_empty(): overrides.arm("alchemy.result",forced)
	new_features.erase("real_alchemy")
	alchemy.start(index)
func begin_fire() -> void:
	if activity_id != "alchemy" or alchemy.state not in ["idle","heating"]: return
	alchemy.begin_fire()
	sfx_event.emit("alchemy_fire")
func release_fire() -> void:
	if activity_id == "alchemy":
		alchemy.release_fire()
		if alchemy.heat >= .8: sfx_event.emit("alchemy_unstable")
func collect_pill() -> void:
	if activity_id != "alchemy": return
	alchemy.collect()
	finish_alchemy()
func finish_alchemy() -> void:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if alchemy.state != "result" or alchemy.paid_out: return
	alchemy.paid_out = true
	if alchemy.practice:
		practice_completed = true
		sfx_event.emit("alchemy_open" if alchemy.result == "success" else "furnace_explosion")
		queue_result("試爐告一段落","火候已親手試過，往後可挑配方正式開爐。","collect" if alchemy.result == "success" else "furnace_explosion")
		return
	if alchemy.result == "success":
		pills[alchemy.recipe] += 1
		if alchemy.quality == 1: upper_pills[alchemy.recipe] += 1
	sfx_event.emit("alchemy_upper" if alchemy.result == "success" and alchemy.quality == 1 else ("alchemy_open" if alchemy.result == "success" else "furnace_explosion"))
	queue_result("丹成" if alchemy.result == "success" else "炸爐",("上品 " if alchemy.quality == 1 else "普通 ")+E.PILL_NAMES[alchemy.recipe] if alchemy.result == "success" else "本爐材料與靈石已消耗，未獲得丹藥。","collect" if alchemy.result == "success" else "furnace_explosion")
	history.append("煉丹｜%s · %s" % [E.PILL_NAMES[alchemy.recipe],("上品" if alchemy.quality == 1 else "普通") if alchemy.result == "success" else "爐毀丹失"])
func preparation() -> Dictionary:
	var count := 0
	for amount in pills:
		if amount > 0: count += 1
	return {"count":count,"status":E.PREPARATION_STATUS[count],"future_floor":E.FUTURE_FULL_PREPARATION_FLOOR if count == 5 else [],"pills":pills.duplicate(),"upper":upper_pills.duplicate()}

func buy_array() -> void:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if realm < C.FOUNDATION_REALM or activity_id != "lobby" or array_attempts > 0 or spirit_stones < E.ARRAY_COST: return
	spirit_stones -= E.ARRAY_COST
	array_attempts = E.ARRAY_ATTEMPTS
	history.append("聚靈陣｜-%d 靈石，未來 %d 次修煉收益 +%d%%" % [E.ARRAY_COST,E.ARRAY_ATTEMPTS,int((E.ARRAY_BONUS-1)*100)])

func debug_milestone(action: String, value: int = 0) -> void:
	if not OS.is_debug_build(): return
	match action:
		"realm":
			sfx_event.emit("stop_all")
			auto_enabled = false
			auto_owned = false
			activity_id = ""
			pending_activity = ""
			auto_before_activity = false
			focus_paused = false
			sequence.clear()
			phase = ""
			state = "idle"
			realm = clampi(value,10,19)
			foundation_grade = maxi(1,foundation_grade)
			cultivation = 0
			hold = 0
			risk = 0
			potential = 0
			lifespan = maxf(lifespan,age+35)
			recent.clear()
		"grade": foundation_grade = clampi(value,1,9)
		"auto": set_auto(not auto_enabled)
		"auto_sequence":
			if state != "idle" or realm < 10 or realm >= 19: return
			var goal := attempts+10
			set_auto(true)
			for step in range(20000):
				advance(.05)
				if attempts >= goal or state == "dead" or realm == 19: break
			set_auto(false)
		"ticket": tickets[E.TICKETS.keys()[clampi(value,0,2)]] += 1
		"stones": spirit_stones = maxi(0,spirit_stones+value)
		"raw": raw_stones[clampi(value,0,3)] += 1
		"open_stone":
			if activity_id.is_empty(): enter_side_activity("stone_gambling")
			open_stone(clampi(value,0,3),0)
		"stone_force": overrides.arm("stone.result",["","common","gold","core","failure","protected"][clampi(value,0,5)])
		"materials":
			for i in range(5): materials[i] += 20
			spirit_stones += 2000
		"recipe":
			if activity_id.is_empty(): enter_side_activity("alchemy")
			start_recipe(clampi(value,0,4))
		"alchemy_force":
			overrides.arm("alchemy.result",["","normal","upper","failure"][clampi(value,0,3)])
		"race_winner": overrides.arm("race.winner",clampi(value,0,4))
		"mine":
			if activity_id != "mines" or mines.state != "mining": return
			for cell in range(25):
				if cell not in mines.revealed and ((cell in mines.dangers) == (value == 1)):
					reveal_mine(cell)
					break
		"exit": exit_side_activity()

func queue_ticket_notification(kind: String) -> void:
	notification_id += 1
	# Mark the reward at grant time, before any view consumes/displays it.
	notified_rewards[notification_id] = true
	sfx_event.emit("ticket_obtained")
	notification_events.append({"id":notification_id,"kind":kind,"amount":1,"count":tickets[kind]})
func take_notifications() -> Array[Dictionary]:
	var events: Array[Dictionary] = notification_events.duplicate(true)
	notification_events.clear()
	return events

func activity_unlocked(id: String) -> bool:
	return id == "flying_boat" or realm >= C.FOUNDATION_REALM
func grant_foundation_unlock() -> void:
	if foundation_unlock_granted: return
	foundation_unlock_granted = true
	for i in range(4): raw_stones[i] += T.FOUNDATION_GIFT[i]
	check_unlocks()
func show_help(id: String, first: bool = false) -> void:
	if not modal.is_empty(): return
	if id=="foundation":
		help_seen[id]=true;new_features.erase(id)
		sect.story(self,"foundation_rules_v2",preload("res://scripts/foundation_rules.gd").lesson(foundation))
		return
	new_features.erase(id)
	if alchemy != null: alchemy.release_fire()
	if not T.HELP.has(id): return
	var copy: Array = (T.FIRST[id] if first and T.FIRST.has(id) else T.HELP[id]).duplicate()
	if id == "calendar": copy = ["天元历",calendar_text()]
	if id == "duel":
		if not sect.duel_taught:
			copy[1] = "劍勢越接近二十一越好，超過便爆勢。覺得夠了，就收劍。"
			if duel != null and duel.story_mode == "junior":
				if duel.round_index >= 2: copy[1] += "\n再出一劍，可以補一枚劍印。"
				if duel.round_index >= 4: copy[1] += "\n靈印可算一或十一。"
				if duel.round_index >= 5: copy[1] += "\n起手十或十一可孤注一劍，再拿一印便收劍，勝負算兩籌。"
		var descriptions := ["神識探查：每小局施放一次，三秒後揭開對手藏印。","劍罡護體：每場首次爆勢穩在二十並收劍。","天命一劍：每場首次孤注必到二十一。","窺天一線：學會後持續看見當前頂牌；抽走後自動顯示新頂牌。劇情指點只揭示一次。","逆轉光陰：每場可重開一小局。"]
		for i in range(5):
			if (sect.probe_learned if i == 0 else sect.senior_lesson_complete and realm >= sect.C.SKILL_REALMS[i]): copy[1] += "\n"+descriptions[i]
	modal = {"kind":"help","id":id,"title":copy[0],"text":copy[1],"full_help":not first and copy[1].length() > 240}
	if first: modal.kind = "waiting_help";modal["wait"] = preload("res://scripts/tutorial_pacing.gd").ENTRY_READ
	sfx_event.emit("stop_charge")
func acknowledge_modal() -> void:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if modal.get("route","")=="blood_exit" and modal.has("closing_line"):
		modal={"kind":"notice","title":modal.get("closing_speaker","魔修"),"text":modal.closing_line,"route":"blood_exit"};return
	if modal.get("kind","") == "dialogue": sect.next_dialogue(self);return
	if modal.get("route","") == "sicbo_demo":
		var lines: Array = modal.lines;modal.clear();sect.story(self,"sicbo_after",lines);return
	if modal.get("route","") == "sect_return": modal.clear();activate_activity("sect");return
	if modal.get("route","") == "senior_result": finish_senior_dialogue();return
	if modal.is_empty(): return
	if modal.get("kind","") == "blood_arrival": return
	if modal.get("kind","") == "festival":
		modal.clear()
		save_session()
		return
	var route: String = modal.get("route","")
	if route == "repeat_activity":
		modal.clear();pending_result.clear();result_delay=0
		exit_side_activity();enter_side_activity("opportunities");return
	if route in ["duel_active","duel_passive","tournament_next","repeat_activity","blood_exit","jade_exit"]:
		modal.clear()
		exit_side_activity()
		return
	var first_alchemy: bool = modal.kind == "help" and modal.get("id","") == "alchemy" and not practice_completed
	if modal.kind == "help": help_seen[modal.id] = true
	modal.clear()
	sfx_event.emit("result_confirm")
	if first_alchemy: start_practice()
	if auto_after_help:
		auto_after_help = false
		set_auto(true)

func reward_description(amount: int) -> String:
	return ("+%d 靈石" % amount if amount > 0 else "本次未收取收益全部失去。")+("\n%s ×%d" % [E.RAW_NAMES[last_raw_drop],entry_shares] if last_raw_drop >= 0 else "")
func queue_result(title: String, message: String, effect: String) -> void:
	if not presentation_enabled: return
	pending_result = {"kind":"result","title":title,"text":message}
	if activity_id in E.TICKETS: pending_result["route"] = "repeat_activity"
	feedback_kind = effect
	result_delay = 1.35 if effect in ["mines_failure","furnace_explosion","stone_shatter","boat_crash"] else .45
	feedback_duration = result_delay
func start_practice() -> void:
	if activity_id != "alchemy" or alchemy.state not in ["ready","result"]: return
	alchemy = preload("res://scripts/alchemy_state.gd").new()
	alchemy.overrides = overrides
	alchemy.cue.connect(_foundation_cue)
	alchemy.practice = true
	alchemy.start(0)

func duel_action(action: String) -> void:
	if activity_id != "duel" or not modal.is_empty() or result_delay > 0: return
	if action == "story_next" and not duel.story_mode.is_empty(): duel.story_next();save_session()
	if action == "accept": duel.accept()
	if action == "draw": duel.draw()
	if action == "double": duel.double_down()
	if action == "stand": duel.stand()
	if action == "next": duel.next_round()
	if duel.state == "arrival" and action in ["refuse","escape"]:
		var cost: int = D.ESCAPE[duel.archetype]
		if action == "escape" and spirit_stones < cost:
			duel.message = "靈石不足：需要 %d，持有 %d。可接受問劍或拒絕。" % [cost,spirit_stones]
			return
		var penalty: int = mini(cultivation,int(ceil(requirement()*D.REFUSAL[duel.archetype])))
		if action == "escape": spirit_stones -= cost
		else: cultivation -= penalty
		duel.state = "result"
		duel.paid_out = true
		duel.message = "遁走：靈石 -%d" % cost if action == "escape" else "拒絕問劍：修為 -%d。" % penalty
		history.append(duel.message)
		queue_result("問劍已了",duel.message,"collect")
		set_duel_result_route()
		duel.message = ""
	finish_duel()
func finish_duel() -> void:
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if duel == null or duel.state != "result" or duel.paid_out: return
	if duel.story_mode.is_empty() and not duel.fair and not duel.match_confirmed and not duel.skill_used.has(4) and (duel.skill_available(4) or sect.inventory.get(sect.C.CARDS[4],0) > 0):
		duel.state = "round_result";return
	duel.paid_out = true
	if not duel.story_mode.is_empty():
		var mode: String = duel.story_mode
		activate_activity("sect");modal.clear()
		if mode == "junior":
			sect.duel_taught = true;sect.junior_met = true;sect.away["小師妹"] = 0;sect.seen["junior_intro"] = true;sect.pending.erase("junior_intro");duel_counter = 0;duel_due = false;duel_threshold = economy_rng.randi_range(D.FIRST_INTERVAL[0],D.FIRST_INTERVAL[1]);sect.seen["double_help"] = true;help_seen["duel"] = true;check_unlocks()
		else: sect.story(self,"senior_post",sect.L.SENIOR_POST)
		save_session();return
	if duel.source == "junior":
		var pool: String = "junior_spar_player_win" if duel.score[0] >= D.WINS else "junior_spar_player_loss"
		var words: String = sect.L.POOLS[pool][sect.pick(pool,self)]
		queue_result("小師妹","%s\n\n這場切磋 · %d：%d" % [words,duel.score[0],duel.score[1]],"collect");pending_result.route = "sect_return";save_session();return
	if duel.source == "senior":
		var pool := "senior_spar_player_win" if duel.score[0] >= D.WINS else "senior_spar_player_loss"
		var words: String = sect.L.POOLS[pool][sect.pick(pool,self)]
		queue_result("大師姐",words+"\n這場切磋 · %d：%d" % [duel.score[0],duel.score[1]],"collect")
		pending_result["route"] = "senior_result"
		return
	var win: bool = duel.score[0] >= D.WINS
	if tournament != null and tournament.stage == "fighting":
		tournament.record(win,duel.score)
		duel.message = tournament.title()+" · 第 %d / 5 戰\n%s · 目前 %d 勝 %d 負" % [tournament.index,"此戰告捷" if win else "此戰惜敗",tournament.wins,tournament.losses]
		history.append(duel.message)
		sfx_event.emit("duel_match_win" if win else "duel_match_lose")
		award_tournament()
		queue_result("問劍告捷" if win else "問劍惜敗","先取三籌 · %d：%d\n大比戰績 %d 勝 %d 負" % [duel.score[0],duel.score[1],tournament.wins,tournament.losses],"collect")
		set_duel_result_route()
		duel.message = ""
		return
	sect.reaction = "duel_win" if win else "duel_loss"
	sect.duel_streak = maxi(1,sect.duel_streak+1) if win else mini(-1,sect.duel_streak-1)
	sect.last_duel_attempt = attempts
	var reward: int = duel_reward(duel.archetype,duel.score[1]) if win else 0
	spirit_stones += reward
	duel.message = "%d:%d · 靈石 +%d" % [duel.score[0],duel.score[1],reward]
	if win and duel.archetype > 0:
		var tier: int = 2 if duel.archetype == 3 else 1
		raw_stones[tier] += 1
		duel.message += "\n%s ×1" % E.RAW_NAMES[tier]
	if not win:
		var penalty:=duel_penalty(duel.archetype,duel.score[0])
		var stones_lost: int=penalty.stones
		var progress_lost: int=penalty.cultivation
		spirit_stones -= stones_lost
		cultivation -= progress_lost
		duel.message = "%d:%d · 靈石 -%d · 修為 -%d" % [duel.score[0],duel.score[1],stones_lost,progress_lost]
	var treasure_force: bool = overrides.take("duel.treasure",false) if win else false
	if win and (treasure_force or economy_rng.randf() < D.TREASURE_CHANCES[duel.archetype]*D.SCORE_BONUS[clampi(duel.score[1],0,2)]):
		var item := economy_rng.randi_range(0,2)
		treasures[item] += 1
		duel.message += "\n獲得 %s" % D.TREASURES[item]
		sfx_event.emit("duel_treasure")
	sfx_event.emit("duel_match_win" if win else "duel_match_lose")
	history.append("問劍｜"+duel.message)
	queue_result("問劍告捷" if win else "問劍惜敗","先取三籌 · %d：%d\n" % [duel.score[0],duel.score[1]]+duel.message.substr(duel.message.find("·")+1).strip_edges(),"collect" if win else "duel_loss")
	set_duel_result_route()
	duel.message = ""

func clear_overrides() -> void:
	overrides.clear()
	if alchemy != null: alchemy.force = ""
func reset_current_test() -> void:
	if not OS.is_debug_build(): return
	begin_developer_test()
	tournament = null
	blood = null
	blood_due = false
	clear_overrides()
	sfx_event.emit("stop_all")
	modal.clear()
	pending_result.clear()
	result_delay = 0
	auto_after_help = false
	auto_enabled = false
	auto_owned = false
	auto_before_activity = false
	activity_id = ""
	pending_activity = ""
	duel_due = false
	focus_paused = false
	state = "foundation_ready" if realm == C.QI_COMPLETE else "idle"
	sequence.clear()
	phase = ""
	hold = 0
	risk = 0
	potential = 0
	boat.reset()
	stone = null
	alchemy = null
	mines = null
	race = null
	duel = null
	foundation = null
func debug_enter(id: String) -> void:
	if not OS.is_debug_build(): return
	reset_current_test()
	if id == "qi":
		realm = 0
		foundation_grade = 0
		cultivation = 0
		state = "idle"
		return
	if id == "foundation":
		realm = C.QI_COMPLETE
		foundation_grade = 0
		state = "foundation_ready"
		start_foundation()
		return
	realm = maxi(10,realm)
	foundation_grade = maxi(1,foundation_grade)
	state = "idle"
	if id == "foundation_realm": return
	if E.TICKETS.has(id): tickets[id] = maxi(1,tickets[id])
	enter_side_activity(id)
func debug_fill_recipe(index: int) -> void:
	if not OS.is_debug_build() or index < 0 or index > 4: return
	for i in range(5): materials[i] = maxi(materials[i],E.RECIPES[index][i])
	spirit_stones = maxi(spirit_stones,E.RECIPE_COST[index])
func debug_stone_settle(deeper: bool) -> void:
	if not OS.is_debug_build() or stone == null: return
	for depth_index in range(3 if deeper else 1):
		if stone.state == "choice" and deeper and stone.depth < 2: stone.deeper()
		for y in range(11):
			for x in range(20): scratch_stone(Vector2((x+.5)/20.0,(y+.5)/11.0))
		if stone.state == "result": return
	collect_stone()

func resolve_debug_cultivation() -> bool:
	var forced: String = overrides.take("cultivation.result")
	if forced.is_empty(): return false
	risk = {"normal":.18,"risky":.4,"extreme":.95,"failure":.85,"rebirth":.85}[forced]
	hold = C.hold_for_instability(risk)
	potential = C.cultivation_gain(hold,realm,attempt_modifier)
	if forced in ["failure","rebirth"]: fail(1 if forced == "rebirth" else 0)
	else: settle("success")
	return true

# Unlock availability is independent of popup lifetime and tutorial visitation.
func check_unlocks():
	if not tutorials_enabled or state == "dead": return
	var available: Array[String] = ["calendar"]
	if realm == C.QI_COMPLETE and foundation_grade == 0: available.append("foundation")
	if attempts >= 5: available.append_array(["opportunities","flying_boat"])
	if realm >= 10: available.append_array(["opportunities","flying_boat","auto","lobby","sword_race","mines","stone_gambling","alchemy","preparation"])
	if realm >= C.FOUNDATION_REALM and first_passive_seen: available.append("duel")
	if realm >= D.ACTIVE_REALM and sect.duel_taught: available.append("active_duel")
	if sect.pavilion_unlocked: available.append("pavilion")
	if practice_completed: available.append("real_alchemy")
	if realm >= 10: available.append_array(["sword_notice","tournament","blood"])
	for i in range(5):
		if (sect.probe_learned if i == 0 else realm >= sect.C.SKILL_REALMS[i] and sect.senior_lesson_complete): available.append("skill"+str(i))
	for id in available:
		if not unlock_notified.has(id) and id not in unlock_queue:
			unlock_queue.append(id)
			new_features[id] = true
func show_next_unlock() -> bool:
	if not tutorials_enabled or unlock_queue.is_empty() or not modal.is_empty() or result_delay > 0: return false
	if state not in ["idle","foundation_ready"] or not activity_id.is_empty() or not pending_activity.is_empty(): return false
	var id: String = unlock_queue.pop_front()
	if unlock_notified.has(id): return false
	var entry: Array = T.UNLOCKS[id]
	modal = {"kind":"unlock", "id":id, "title":entry[0], "text":entry[1]}
	unlock_notified[id] = true
	sfx_event.emit("feature_unlock")
	save_session()
	return true
func open_unlock():
	if modal.get("kind","") == "blood_arrival":
		modal.clear()
		enter_side_activity("blood")
		return
	if modal.get("kind","") == "festival":
		var kind: String = modal.get("festival_kind","sect")
		var year: int = modal.get("year",festival_seen)
		modal.clear()
		tournament = preload("res://scripts/tournament_state.gd").new()
		tournament.kind = kind
		tournament.year = year
		enter_side_activity("tournament")
		sect.festival_intro(self)
		return
	if modal.get("kind","") == "unlock": acknowledge_modal()

const NPC = preload("res://scripts/duel_opponents.gd")
var last_passive_npc := -1
func refresh_board():
	if board_attempt >= 0 and attempts-board_attempt < D.BOARD_INTERVAL: return
	board_attempt = attempts
	board.clear()
	for i in range(NPC.NPCS.size()): board.append({"npc_id":i,"archetype":NPC.NPCS[i].economy,"used":false})
func challenge_opponent(index: int):
	if activity_id != "active_duel" or not modal.is_empty() or index < 0 or index >= board.size() or board[index].used: return
	board[index].used = true
	selected_opponent = index
	activate_activity("duel")
	duel.accept()
func duel_reward(kind: int, losses: int) -> int:
	return int(D.REWARDS[kind]*D.SCORE_BONUS[clampi(losses,0,2)])
func duel_penalty(kind: int, wins: int) -> Dictionary:
	var factor: float=D.LOSS_SCALE[clampi(wins,0,2)]
	return {"stones":mini(spirit_stones,int(round(D.LOSSES[kind]*factor))),"cultivation":mini(cultivation,int(ceil(requirement()*D.CULTIVATION_LOSS[kind]*factor)))}
func duel_limits(kind: int) -> Dictionary:
	var limits:=duel_penalty(kind,0)
	limits["win"]=duel_reward(kind,0)
	return limits
func duel_stakes(kind: int) -> String:
	var limits:=duel_limits(kind)
	return "若胜：最多 %d 灵石\n若败：最多损失 %d 灵石、%d 修为" % [limits.win,limits.stones,limits.cultivation]
func debug_quick_play(id: String):
	if not OS.is_debug_build(): return
	var resume_auto := auto_enabled or auto_before_activity
	reset_current_test()
	realm = maxi(10,realm)
	foundation_grade = maxi(1,foundation_grade)
	state = "idle"
	auto_enabled = resume_auto
	if id == "foundation":
		realm = 9
		foundation_grade = 0
		state = "foundation_ready"
		start_foundation()
		return
	if id == "tournament":
		tournament = null
		festival_pending = next_festival_year()
		show_festival_offer()
		return
	if id == "blood":
		blood_due = true
		spirit_stones = maxi(spirit_stones,B.REVERSE_COST*2)
		show_blood_offer(true)
		return
	if id == "alchemy":
		for i in range(5): debug_fill_recipe(i)
	enter_side_activity(id)
func begin_developer_test():
	if not OS.is_debug_build() or developer_test_session: return
	# Preserve the playable session before a test changes realm, resources or activity.
	save_session()
	developer_test_session = true
func save_session():
	if persistence_path.is_empty() or developer_test_session: return
	preload("res://scripts/session_store.gd").save_run(self,persistence_path)
func restore_session(path: String):
	persistence_path = path
	preload("res://scripts/session_store.gd").load_run(self,path)

func world_year() -> float:
	return snappedf(P.START_YEAR+age-C.STARTING_AGE,0.000001)
func next_festival_year() -> int:
	return (int(floor((world_year()+.000001)/P.FESTIVAL_INTERVAL))+1)*P.FESTIVAL_INTERVAL
func check_calendar():
	if not challenges_enabled: return
	var cycle := int(floor((world_year()+.000001)/P.FESTIVAL_INTERVAL))*P.FESTIVAL_INTERVAL
	if cycle <= festival_seen: return
	festival_seen = cycle
	if realm >= 10: festival_pending = cycle
func show_festival_offer() -> bool:
	if festival_pending > 0 and world_year() > festival_pending + .00001: festival_pending = 0
	if sect.tianji_pending > 0 and world_year() > sect.tianji_pending + .00001: sect.tianji_pending = 0
	if festival_pending == 0 and sect.tianji_pending > 0:
		festival_pending = sect.tianji_pending;sect.tianji_pending = 0;sect.offer_kind = "tianji"
	elif festival_pending > 0 and sect.offer_kind != "tianji": sect.offer_kind = "sect"
	if festival_pending == 0 or state != "idle" or not activity_id.is_empty() or not modal.is_empty() or result_delay > 0 or not pending_activity.is_empty(): return false
	festival_seen = maxi(festival_seen,festival_pending)
	modal = {"kind":"festival","festival_kind":sect.offer_kind,"year":festival_pending,"title":("天機大比" if sect.offer_kind == "tianji" else "宗門大比")+" · 開幕","text":"天元曆 %d 年，大比開場。\n宗門三戰、天機五戰，戰畢揭榜。\n大比之中，一切問劍神通皆被封禁。" % festival_pending}
	sect.offer_kind = "sect"
	festival_pending = 0
	sfx_event.emit("feature_unlock")
	save_session()
	return true
func tournament_next():
	if activity_id != "tournament" or tournament == null or tournament.stage != "between" or not modal.is_empty(): return
	var index: int = tournament.index
	if index >= tournament.total_matches(): return
	var schedule := [duel_counter,duel_threshold,duel_due,duel_count,first_passive_seen,last_passive_npc]
	activate_activity("duel")
	duel_counter = schedule[0]
	duel_threshold = schedule[1]
	duel_due = schedule[2]
	duel_count = schedule[3]
	first_passive_seen = schedule[4]
	last_passive_npc = schedule[5]
	duel.archetype = P.FESTIVAL_STYLES[index]
	duel.custom_name = tournament.names()[index]
	duel.custom_sect = tournament.sects()[index]
	duel.fair = true
	duel.learned_probe = false
	duel.card_enabled.clear()
	duel.player_level = 0
	duel.active_challenge = false
	duel.source = "tournament"
	tournament.stage = "fighting"
	save_session() # The supplied pre-match arena confirms the encounter before dealing.
func award_tournament():
	if tournament.index != tournament.total_matches() or tournament.paid: return
	tournament.paid = true
	var wins: int = tournament.wins
	sect.reaction = "festival_good" if wins >= 3 else "festival_bad"
	if tournament.kind == "sect":
		var cards: int = sect.C.LEGACY_SECT_CARDS[wins] if tournament.legacy_five else sect.C.SECT_CARDS[wins]
		sect.card_choices += cards
		if wins >= 3: sect.stipend_bonus = true
		sect.festival_result = mini(wins,3);sect.festival_serial += 1
		tournament.reward_text = "可選問劍神通符 %d 張" % cards
	else:
		sect.grant("天機券",sect.C.SECRET_TICKETS[wins]);sect.grant("金丹神通體驗券",sect.C.FUTURE_TICKETS[wins])
		tournament.reward_text = "天機券 ×%d\n金丹神通體驗券 ×%d" % [sect.C.SECRET_TICKETS[wins],sect.C.FUTURE_TICKETS[wins]]
	history.append("%s｜%d勝%d負 · %s" % [tournament.title(),wins,tournament.losses,tournament.reward_text])

func set_duel_result_route():
	if not presentation_enabled: return
	var source: String = duel.source
	if duel.active_challenge: source = "active"
	if tournament != null and tournament.stage != "done" and tournament.index > 0: source = "tournament"
	pending_result["route"] = "tournament_final" if source == "tournament" and tournament.index == tournament.total_matches() else ("tournament_next" if source == "tournament" else "duel_"+source)
	result_delay = D.MATCH_MODAL_DELAY
	feedback_duration = result_delay
func repeat_label() -> String:
	return "再選一柄" if activity_id == "sword_race" else "再來一次"
func repeat_activity():
	if modal.get("route","") != "repeat_activity": return
	var id := activity_id
	modal.clear();pending_result.clear();sfx_event.emit("stop_all")
	activate_activity(id)
func result_secondary():
	if modal.get("kind","") == "dialogue": sect.next_dialogue(self,1);return
	if modal.get("route","") == "jade_exit": modal.clear();sect.start_jade(self);return
	if modal.get("route","") == "repeat_activity": repeat_activity()
	else: open_unlock()

func show_blood_offer(test_entry: bool = false) -> bool:
	if not test_entry and attempts < sect.event_until: return false
	if (not challenges_enabled and not (test_entry and OS.is_debug_build())) or not blood_due or realm < B.UNLOCK_REALM: return false
	if state != "idle" or not activity_id.is_empty() or not pending_activity.is_empty() or not modal.is_empty() or result_delay > 0 or (not unlock_queue.is_empty() and not test_entry): return false
	sect.blood_title = sect.C.BLOOD_TITLES[sect.rng.randi_range(0,4)]
	sect.blood_name = sect.C.BLOOD_NAMES[sect.rng.randi_range(0,3)]
	sect.blood_elite = sect.rng.randf() < minf(sect.C.ELITE_MAX,sect.C.ELITE_BASE+maxi(0,realm-10)*sect.C.ELITE_PER_REALM+(age-C.STARTING_AGE)*sect.C.ELITE_PER_YEAR)
	modal = {"kind":"blood_arrival","title":sect.blood_title,"text":sect.blood_name+"攔住了去路。\n"+("這次來的是強敵。魔道似乎已經盯上你了。\n" if sect.blood_elite else "")+"血煞陣已起，擲下命骨，尋出生門。"}
	modal.text += "\n"+preload("res://scripts/demonic_dialogue.gd").line(sect.player_demonic_wins,"before",sect.demonic_encounters)
	sect.demonic_encounters+=1
	sfx_event.emit("blood_arrival")
	save_session()
	return true
func blood_action(action: String, side: int = -1):
	if activity_id not in ["blood","jade"] or blood == null or not modal.is_empty() or result_delay > 0 or bone_target_pending: return
	if action == "roll": blood.roll()
	elif action == "accept": blood.accept_fate()
	elif action == "reverse" and not blood.practice and blood.can_reverse() and spirit_stones >= B.REVERSE_COST:
		if blood.reverse(side):
			spirit_stones -= B.REVERSE_COST
			history.append("血煞命局｜逆命一骨 · 靈石 -%d" % B.REVERSE_COST)
func finish_blood():
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if blood == null or blood.state != "result" or blood.paid_out: return
	blood.paid_out = true
	if blood.practice:
		sect.interaction(self)
		var pool: String="junior_jade_player_win" if blood.outcome=="win" else "junior_jade_player_loss"
		queue_result("你贏了" if blood.outcome=="win" else "這局小師妹贏了",sect.L.POOLS[pool][sect.pick(pool,self)],"collect")
		pending_result["route"] = "jade_exit"
		return
	var description := ""
	if blood.outcome == "win":
		var gold: int = blood.rng.randi_range(B.STONES[0],B.STONES[1])
		var roll: float = blood.rng.randf()
		var tier := 3
		for i in range(B.RAW_WEIGHTS.size()):
			roll -= B.RAW_WEIGHTS[i]
			if roll <= 0: tier = i;break
		var material: int = blood.rng.randi_range(B.MATERIALS[0],B.MATERIALS[1])
		var fragments_found: int = blood.rng.randi_range(B.FRAGMENTS[0],B.FRAGMENTS[1])
		spirit_stones += gold
		raw_stones[tier] += 1
		blood_items["魔道素材"] += material
		blood_items["魔器碎片"] += fragments_found
		description = "靈石 +%d\n%s ×1\n魔道素材 ×%d · 魔器碎片 ×%d" % [gold,E.RAW_NAMES[tier],material,fragments_found]
		if blood.rng.randf() < B.RARE_CHANCE:
			blood_items["幽冥玉髓"] += 1
			description += "\n幽冥玉髓 ×1"
		description += "\n魔道之物已收入行囊。"
	else:
		var lost_gold := mini(spirit_stones,B.LOSS_STONES)
		var lost_progress := mini(cultivation,int(ceil(requirement()*B.LOSS_CULTIVATION)))
		spirit_stones -= lost_gold
		cultivation -= lost_progress
		description = "靈石 -%d\n修為 -%d" % [lost_gold,lost_progress]
	if blood.outcome=="win": sect.player_demonic_wins+=1
	var closing_line: String=preload("res://scripts/demonic_dialogue.gd").line(sect.player_demonic_wins,"win" if blood.outcome=="win" else "loss",sect.demonic_encounters)
	history.append("血煞命局｜"+("破陣而出" if blood.outcome == "win" else "劫殺失利")+"\n"+description)
	queue_result("破陣而出" if blood.outcome == "win" else "劫殺失利",description,"collect")
	if presentation_enabled:
		pending_result["route"] = "blood_exit";pending_result["closing_line"]=closing_line;pending_result["closing_speaker"]=sect.blood_name

func next_tianji_year() -> int: return (int(floor((world_year()+.000001)/P.TIANJI_INTERVAL))+1)*P.TIANJI_INTERVAL
func finish_senior_dialogue():
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	modal.clear();activate_activity("sect");sect.event_until = attempts+sect.C.EVENT_GAP
	if duel.score[0] >= 3 and not sect.senior_defeated:
		sect.senior_defeated = true;sect.story(self,"senior_win")
	elif duel.score[0] == 0 and not sect.seen.has("senior_loss"): sect.story(self,"senior_loss")
func duel_skill(index: int, card: bool = false):
	if activity_id != "duel" or duel == null or duel.fair or not modal.is_empty() or result_delay > 0: return
	if card:
		if index not in range(5) or duel.skill_pause > 0 or duel.skill_available(index) or duel.skill_used.has(index): return
		if index == 4:
			if duel.state != "round_result": return
		elif duel.state != "playing": return
		if not sect.consume(sect.C.CARDS[index]): return
		duel.card_enabled[index] = true
	if index in [0,3,4]: duel.use_skill(index)
	save_session()
func update_jade():
	if activity_id != "jade" or blood == null or blood.rolls == sect.last_blood_serial or blood.state in ["rolling"]: return
	sect.last_blood_serial = blood.rolls
	if blood.rolls == 1:
		if blood.total == 12: blood.message = "小師妹：……十二。\n噗。\n對不起，我真的忍不住。"
		elif blood.total == 11: blood.message = "小師妹：十一？！\n你平常修煉也有這運氣就好了。"
		elif blood.point > 0: blood.message = "小師妹：%d。記好了，現在%d就是你的生門。\n再擲到%d之前，別先撞上七。" % [blood.point,blood.point,blood.point]
	elif blood.total == 7: blood.message = "小師妹：七煞。\n我就知道你剛才那個表情要出事。"
	elif blood.rolls >= 8 and not sect.blood_long_seen:
		sect.blood_long_seen = true;blood.message = "小師妹：等等。我們是不是已經擲很久了？\n你這命怎麼這麼難算啊。"
func use_relic(key: String, value: int = 0):
	save_session.call_deferred() # Persist after this transaction, including early-return branches.
	if activity_id != "blood" or blood == null or not modal.is_empty() or blood.relic_used.has(key): return
	if key == "鎮煞令":
		if blood.state != "ready" or blood.ward or not sect.consume(key): return
		blood.ward = true
	elif key == "定命符":
		if blood.state not in ["ready","choice"] or blood.point == 0 or value not in B.POINTS or value == blood.point or not sect.consume(key): return
		blood.point = value;blood.fixed_point = true;blood.message = "生門改為 %d · 下一擲起生效" % value
	elif key == "偷天符":
		if blood.state != "ready" or not blood.preview.is_empty() or not sect.consume(key): return
		blood.preview.assign([blood.rng.randi_range(1,6),blood.rng.randi_range(1,6)])
	elif key == "換命符":
		if blood.state != "choice" or value not in [0,1] or not sect.consume(key): return
		blood.reroll_side = value;blood.dice[value] = blood.rng.randi_range(1,6);blood.visible_dice[value] = 0;blood.begin_roll()
	elif key == "斬魔敕令":
		if blood.state != "ready" or blood.rolls != 0 or sect.blood_elite or not sect.consume(key): return
		blood.paid_out = true;spirit_stones += sect.C.SUPPRESS_GOLD;blood.state = "result"
		queue_result("壓制魔修","靈石 +%d" % sect.C.SUPPRESS_GOLD,"collect");pending_result.route = "blood_exit"
	else: return
	blood.relic_used[key] = true;save_session()
func debug_sect(id: String):
	if not OS.is_debug_build(): return
	reset_current_test();state = "idle";modal.clear();pending_result.clear();result_delay = 0
	sect = preload("res://scripts/sect_state.gd").new();sicbo = null;festival_pending = 0;unlock_queue.clear()
	sect.intro_done = true;tutorials_enabled = true;sect.pending.clear()
	match id:
		"opening": sect.intro_done = false;sect.story(self,"opening")
		"junior": realm = 10;sect.junior_met = true;sect.story(self,"junior_intro")
		"affection": realm = 10;sect.junior_met = true;sect.affection = 7;activate_activity("sect");modal.clear();sect.talk(self,"小師妹")
		"senior", "senior7":
			realm = 12 if id == "senior" else 16;sect.senior_met = true
			if id == "senior7": sect.story(self,"senior_reunion",[["大師姐","終於到了。"],["你","築基七層。"],["大師姐","我知道。\n所以今天不讓你了。"]])
			else: sect.story(self,"senior_lesson_intro",sect.L.SENIOR_INTRO)
		"stipend", "sicbo":
			realm = 10;sect.junior_met = true;sect.stipends.assign([180,180,180]);activate_activity("sect");modal.clear()
			if id == "sicbo": sect.sicbo_seen = false;sect.stipend(self,true)
		"sect_festival", "tianji":
			realm = 12;tournament = null;festival_pending = next_festival_year() if id == "sect_festival" else next_tianji_year();sect.offer_kind = "sect" if id == "sect_festival" else "tianji";show_festival_offer()
		"pavilion": realm = 10;sect.grant("天機券",20);activate_activity("pavilion")
		"multi": realm = 10;spirit_stones = 2000;tickets = {"flying_boat":20,"sword_race":20,"mines":20};activate_activity("opportunities")
		"blood":
			realm = 12
			for key in sect.C.RELICS: sect.grant(key)
			blood_due = true;show_blood_offer(true)

func debug_story(id: String):
	if not OS.is_debug_build(): return
	debug_sect("stipend");realm = 12;modal.clear();sect.junior_met = true;sect.senior_met = true
	match id:
		"junior": sect.start_lesson(self,"junior")
		"senior": sect.duel_taught = true;sect.story(self,"senior_lesson_intro",sect.L.SENIOR_INTRO)
		"probe": sect.story(self,"senior_post",sect.L.SENIOR_POST)
		"pool": sect.duel_taught = true;sect.senior_lesson_complete = true;sect.probe_learned = true;sect.talk(self,"小師妹")
		"context": sect.last_cultivation = "rebirth";sect.last_cultivation_attempt = attempts;sect.reaction = "rebirth";sect.talk(self,"小師妹")
		"result0", "result1", "result2", "result3", "runner", "champion":
			tournament = preload("res://scripts/tournament_state.gd").new()
			var wins: int = int(id.trim_prefix("result")) if id.begins_with("result") else 3
			for i in range(3): tournament.stage = "fighting";tournament.record(i < wins,[3,0] if i < wins else [0,3])
			award_tournament();activate_activity("tournament");modal.clear()
			sect.runner_up_seen = id not in ["runner","result3"]
			if id == "champion": tournament.stage = "final"

func choose_bone_target(side: int):
	if not bone_target_pending: return
	if not preload("res://scripts/inventory_access.gd").usable(self,"換命符"): bone_target_pending = false;return
	use_relic("換命符",side)
	bone_target_pending = false;save_session()
func cancel_bone_target():
	bone_target_pending = false;save_session()

func debug_master(context: String):
	if not OS.is_debug_build(): return
	debug_sect("stipend");modal.clear();sect.chat.clear();sect.away["師父"] = 0
	sect.reset_master_clicks();sect.dialogue_seen["master_foundation"] = true;sect.dialogue_seen["master_late"] = true
	sect.context_seen.clear();sect.context_cooldowns.clear();sect.festival_result = -1;sect.duel_streak = 0;sect.last_cultivation = "";sect.master_last_visit = attempts
	match context:
		"foundation": sect.dialogue_seen.erase("master_foundation")
		"late": realm = 17;sect.dialogue_seen.erase("master_late")
		"failure", "rebirth": sect.last_cultivation = context;sect.last_cultivation_attempt = attempts
		"festival": sect.festival_result = 3;sect.festival_serial += 1
		"repeat": sect.master_clicks = 1;sect.master_click_attempt = attempts;sect.master_click_age = age
	sect.talk(self,"師父")

func surrender_blood():
	if modal.get("kind","")!="blood_arrival": return
	var paid: int=int(spirit_stones/2)
	spirit_stones-=paid;blood_due=false;blood_counter=0
	sect.event_until=attempts+4
	modal={"kind":"notice","title":"魔修冷笑","text":sect.blood_name+"收起灵石，侧身让开。\n“这点胆量，也敢问长生？滚吧。”\n交出 %d 灵石，已可离开。"%paid}
	history.append("魔道截杀｜交出一半灵石 -%d"%paid);save_session()

func calendar_status(kind: String) -> String:
	if tournament != null and tournament.kind == kind and tournament.stage not in ["done","final"]: return "进行中"
	if modal.get("kind","") == "festival" and modal.get("festival_kind","sect") == kind: return "进行中"
	var pending: int = sect.tianji_pending if kind == "tianji" else festival_pending
	if festival_pending > 0 and sect.offer_kind == "tianji": pending = festival_pending if kind == "tianji" else 0
	if pending > 0 and absf(float(pending)-world_year()) < .00001: return "进行中"
	var next: int = next_tianji_year() if kind == "tianji" else next_festival_year()
	return "还有 %.1f 年" % maxf(0,float(next)-world_year())
func calendar_text() -> String:
	return "天元历 %.1f 年\n\n宗门大比：%s\n天机大比：%s" % [world_year(),calendar_status("sect"),calendar_status("tianji")]
