extends RefCounted
## Read-only presentation. Never writes to RunState, RNG, time, or rewards.
const C = preload("res://scripts/balance.gd")
const TEXTURES := {
 "calm": preload("res://assets/characters/char01/char01_cultivation_calm.png"),
 "risky": preload("res://assets/characters/char01/char01_cultivation_risky.png"),
 "failure": preload("res://assets/characters/char01/char01_cultivation_failure.png")
}
var current := "calm"
var risky_latched := false
var was_holding := false
var seen_run := -1
func update(model: RefCounted, result_visible: bool) -> void:
 if seen_run != model.run_serial:
  seen_run = model.run_serial
  risky_latched = false
  was_holding = false
  current = "calm"
 if model.state == "holding":
  if not was_holding: risky_latched = false
  if model.risk >= C.CHARACTER_RISK_ENTER: risky_latched = true
  current = "risky" if risky_latched else "calm"
 elif model.state == "rupture":
  # True failure has occurred; composure returns only when the reversal begins.
  current = "failure" if model.phase in ["loss", "silence"] else "risky"
 elif (result_visible or model.state == "presenting") and not model.last_result.is_empty():
  if model.last_result.outcome == "failure": current = "failure"
  elif model.last_result.outcome == "rebirth" or model.last_result.instability >= C.CHARACTER_RISK_ENTER: current = "risky"
  else: current = "calm"
 else:
  current = "calm"
 was_holding = model.state == "holding"
func texture() -> Texture2D:
 return TEXTURES[current]
