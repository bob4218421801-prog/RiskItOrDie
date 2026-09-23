extends RefCounted
const C = preload("res://scripts/balance.gd")
var overrides: RefCounted
var rng := RandomNumberGenerator.new()
var state := "ready"
var elapsed := 0.0
var multiplier := 1.0
var hazard_budget := 0.0
var reward_base := C.BOAT_BASE_STONES
var reward := 0

func _init() -> void:
	rng.randomize()

func reset() -> void:
	state = "ready"
	elapsed = 0.0
	multiplier = 1.0
	reward = 0

func start() -> void:
	if state != "ready": return
	state = "flying"
	hazard_budget = -log(maxf(rng.randf(), 0.000000001))

func advance(delta: float) -> void:
	if state != "flying": return
	var forced: String = overrides.take("boat.next") if overrides != null else ""
	if forced == "cashout":
		collect()
		return
	if forced in ["early","high"]:
		elapsed = .2 if forced == "early" else log(12.0)/C.BOAT_MULTIPLIER_RATE
		multiplier = C.boat_multiplier(elapsed)
		state = "crashed"
		reward = 0
		return
	var next := elapsed + delta
	if forced != "safe" and C.boat_hazard_integral(next) >= hazard_budget:
		var lo := elapsed
		var hi := next
		for step in range(48):
			var middle := (lo + hi) * 0.5
			if C.boat_hazard_integral(middle) < hazard_budget: lo = middle
			else: hi = middle
		elapsed = (lo + hi) * 0.5
		multiplier = C.boat_multiplier(elapsed)
		state = "crashed"
		reward = 0
	else:
		elapsed = next
		multiplier = C.boat_multiplier(elapsed)

func collect() -> void:
	if state != "flying": return
	state = "collected"
	reward = int(floor(reward_base * multiplier))
