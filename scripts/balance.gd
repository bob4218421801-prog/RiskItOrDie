extends RefCounted
## Single tuning source. No balance values belong in UI scripts.
const STARTING_AGE := 16.0
const STARTING_LIFESPAN := 25.0
const TIME_PER_CULTIVATION := 0.5
const REALMS := ["練氣一層", "練氣二層", "練氣三層", "練氣四層", "練氣五層", "練氣六層", "練氣七層", "練氣八層", "練氣九層", "練氣圓滿", "築基一層", "築基二層", "築基三層", "築基四層", "築基五層", "築基六層", "築基七層", "築基八層", "築基九層", "築基圓滿"]
const REQUIREMENTS := [5000, 15000, 40000, 100000, 170000, 315000, 561000, 989000, 1730000, 0, 7750000, 10630000, 14300000, 21070000, 29000000, 40840000, 57860000, 81410000, 112740000]
const REALM_MULTIPLIERS := [1.0, 11.62, 21.58, 40.78, 55.0, 85.0, 130.0, 200.0, 310.0, 310.0, 400.0, 520.0, 676.0, 878.8, 1142.44, 1485.17, 1930.72, 2510.0, 3263.0, 3263.0]
const LIFESPAN_REWARDS := [2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 0.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0]
const GAIN_SCALE := 10.84
const GAIN_RATE := 1.1
const INSTABILITY_SECONDS := 5.0
const INSTABILITY_POWER := 2.0
const HAZARD_BASE := 0.0005
const HAZARD_SCALE := 35.0
const HAZARD_POWER := 5.0
const REBIRTH_CHANCE := 0.03
const FIRST_REBIRTH_WEIGHTS := [0.0, 0.0, 0.03, 0.03, 0.15, 0.35, 1.0]
const FIRST_REBIRTH_DEADLINE := 6
const REBIRTH_MULTIPLIER := 3
const FAILURE_PAUSE := 0.90
const LOSS_SEQUENCE := [["loss", 0.32], ["silence", 0.95]]
const REBIRTH_SEQUENCE := [["burst", 0.45], ["reversal", 0.70], ["multiply", 0.65], ["jackpot", 1.05]]
const REWARD_SECONDS := 0.35
const BREAKTHROUGH_SECONDS := 0.90
const RECENT_COUNT := 5
const MIN_RECENT_COUNT := 2
const PROJECTION_COMFORT_MULTIPLIER := 1.20
const COMMENT_SECONDS := 1.3
# Upper bounds, tested with '<'; equality enters the next band.
const COMMENT_BOUNDS := [0.04, 0.12, 0.30, 0.50, 0.70, 0.90]
const COMMENT_WORDS := ["謹小慎微", "穩中求進", "見好就收", "富貴險求", "刀尖起舞", "向死而生", "逆天而行"]
const EARLY_FAILURE_INSTABILITY := 0.16
const GREED_INSTABILITY := 0.70
const GREED_HOLD_FRACTION := 0.80
const HIGH_POTENTIAL_RATIO := 0.20
const NEAR_DEATH_ATTEMPTS := 2.0
const NEAR_DEATH_INSTABILITY := 0.50
const AURA_START := 48.0
const AURA_MAX := 220.0
const AURA_EXPANSION_SECONDS := 1.8
const SIM_BANDS := [[0.07, 0.11], [0.28, 0.299], [0.34, 0.46], [0.54, 0.66]]
const SIM_STYLE_NAMES := ["穩中求進", "見好就收", "富貴險求", "刀尖起舞"]
const BASELINE_RATE_MIN := 0.80
const BASELINE_RATE_MAX := 0.85
# Visual intensity uses the same style boundaries as the commentary. Tiny warning
# throughout 見好就收; pronounced leakage/shake starts in 刀尖起舞.
const FEEDBACK_LEVELS := [0.0, 0.0, 0.015, 0.07, 0.32, 0.65, 0.90, 1.0]
const TOAST_SECONDS := 7.0
const TOAST_SLIDE_SECONDS := 0.35
const OPPORTUNITY_PULSE_HZ := 0.6
const OPPORTUNITY_EVERY := 5
const BOAT_BASE_STONES := 100
const BOAT_MULTIPLIER_RATE := 0.34
const BOAT_HAZARD_BASE := 0.015
const BOAT_HAZARD_SCALE := 0.009
const BOAT_HAZARD_POWER := 2.0

static func boat_multiplier(t: float) -> float:
	return exp(BOAT_MULTIPLIER_RATE * minf(t, 40.0))

static func boat_hazard_integral(t: float) -> float:
	return BOAT_HAZARD_BASE * t + BOAT_HAZARD_SCALE * pow(t, BOAT_HAZARD_POWER + 1.0) / (BOAT_HAZARD_POWER + 1.0)

static func hold_for_instability(value: float) -> float:
	return INSTABILITY_SECONDS * pow(clampf(value, 0.0, 1.0), 1.0 / INSTABILITY_POWER)

static func cultivation_gain(t: float, realm: int, modifier: float = 1.0) -> int:
	return int(floor(GAIN_SCALE * (exp(GAIN_RATE * minf(t, 25.0)) - 1.0) * REALM_MULTIPLIERS[realm] * modifier))

static func gain(t: float) -> int:
	return int(floor(GAIN_SCALE * (exp(GAIN_RATE * minf(t, 25.0)) - 1.0)))

static func instability(t: float) -> float:
	return clampf(pow(maxf(t, 0.0) / INSTABILITY_SECONDS, INSTABILITY_POWER), 0.0, 1.0)

static func hazard(t: float) -> float:
	# Unclamped internal pressure continues rising beyond normalized instability 1.
	return HAZARD_BASE + HAZARD_SCALE * pow(maxf(t, 0.0) / INSTABILITY_SECONDS, INSTABILITY_POWER * HAZARD_POWER)

static func cumulative_hazard(t: float) -> float:
	var power := INSTABILITY_POWER * HAZARD_POWER
	return HAZARD_BASE * t + HAZARD_SCALE * pow(t, power + 1.0) / ((power + 1.0) * pow(INSTABILITY_SECONDS, power))

static func failure_time(budget: float, upper: float) -> float:
	var low := 0.0
	var high := upper
	for step in range(48):
		var middle := (low + high) * 0.5
		if cumulative_hazard(middle) < budget:
			low = middle
		else:
			high = middle
	return (low + high) * 0.5

static func commentary(result: Dictionary) -> String:
	# Pure function: never reads RNG or changes cultivation, age, or rewards.
	var risk: float = result.instability
	if result.outcome == "rebirth":
		return "破而後立"
	if result.outcome == "failure":
		if risk < EARLY_FAILURE_INSTABILITY:
			return "時運不濟"
		if risk >= GREED_INSTABILITY and result.hold_fraction >= GREED_HOLD_FRACTION:
			return "貪念噬心"
		if result.potential_ratio >= HIGH_POTENTIAL_RATIO:
			return "功虧一簣"
		return "靈息逆亂"
	if result.remaining_attempts <= NEAR_DEATH_ATTEMPTS and risk >= NEAR_DEATH_INSTABILITY:
		return "死中求生"
	for index in range(COMMENT_BOUNDS.size()):
		if risk < COMMENT_BOUNDS[index]:
			return COMMENT_WORDS[index]
	return COMMENT_WORDS[-1]

const GAIN_PILL_MULTIPLIER := 1.5
const PROTECTION_RETAIN := 0.5
const LONGEVITY_YEARS := 1.0
const SHOP := {
	"gain": {"name": "聚氣丹", "price": 240, "detail": "下一次修煉收益 ×1.5；使用後消耗，不疊加"},
	"protection": {"name": "護脈丹", "price": 360, "detail": "下一次失控保留 50% 潛在修為；成功也消耗"},
	"longevity": {"name": "延壽丹", "price": 1600, "detail": "立即增加 1 年最大壽元"},
	"breakthrough": {"name": "破境丹", "price": 6000, "detail": "立即升一個小境界，保留已有修為；不跨大境界"}
}

static func feedback_intensity(normalized: float) -> float:
	var knots: Array = [0.0]
	knots.append_array(COMMENT_BOUNDS)
	knots.append(1.0)
	var value := clampf(normalized, 0.0, 1.0)
	for i in range(knots.size() - 1):
		if value <= knots[i + 1]:
			return lerpf(FEEDBACK_LEVELS[i], FEEDBACK_LEVELS[i + 1], inverse_lerp(knots[i], knots[i + 1], value))
	return 1.0

# Presentation-only settings; these never feed simulation or hazard.
const CHARACTER_RISK_ENTER := COMMENT_BOUNDS[2]
const CHARACTER_DRAW_SIZE := Vector2(380, 380)
const SPIRIT_PARTICLE_COLOR := Color(1.0, 1.0, 1.0, 0.6)
const SPIRIT_PARTICLE_BASE_COUNT := 4

# Foundation event: independent RNG, no cultivation/lifespan wager during this event.
const QI_COMPLETE := 9
const FOUNDATION_REALM := 10
const FOUNDATION_LIFE_REWARD := 20.0
const FOUNDATION_SUCCESS := [0.98, 0.95, 0.91, 0.82, 0.70, 0.52, 0.32, 0.16]
const FOUNDATION_DANGER := ["十拿九穩", "尚算安穩", "尚算安穩", "略有兇險", "吉凶難料", "險象環生", "逆天而行", "天道不容"]
const FOUNDATION_SEVERITY := [0.55, 0.30, 0.15]
const FOUNDATION_REBIRTH_CHANCE := 0.02
const FOUNDATION_TIMES := {"condense":0.5,"fall":0.25,"impact":0.15,"pause":0.3,"crack":0.35,"burst":0.25,"silence":1.8,"freeze":0.2,"reverse":0.45,"rebuild":0.35,"reveal":0.6,"result":0.9}

# Long foundation progression. All costs and auto policy share this source.
const FOUNDATION_COMPLETE := 19
const FOUNDATION_TIME_COST := 0.1
const FOUNDATION_MODIFIERS := [1.0, 1.04, 1.08, 1.12, 1.16, 1.18, 1.20, 1.26, 1.34]
const AUTO_INSTABILITY := [0.28, 0.46]
const AUTO_SPEED := 1.6
const AUTO_REST := 0.65
static func time_cost(realm: int) -> float:
	return FOUNDATION_TIME_COST if realm >= FOUNDATION_REALM else TIME_PER_CULTIVATION
static func foundation_modifier(grade: int) -> float:
	return FOUNDATION_MODIFIERS[clampi(grade, 1, 9)-1]

