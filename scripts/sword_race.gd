extends RefCounted
const E = preload("res://scripts/economy_config.gd")
var rng := RandomNumberGenerator.new()
var state := "ready"
var selected := -1
var winner := -1
var elapsed := 0.0
var reward := 0
var paid_out := false
func _init(): rng.randomize()
func start(choice: int, forced: int = -1) -> void:
 if state != "ready" or choice < 0 or choice >= E.RACE_NAMES.size(): return
 selected = choice
 var roll := rng.randf()
 winner = 4
 for i in range(E.RACE_WEIGHTS.size()):
  roll -= E.RACE_WEIGHTS[i]
  if roll <= 0.0:
   winner = i
   break
 if OS.is_debug_build() and forced >= 0: winner = clampi(forced,0,4)
 state = "racing"
func advance(delta: float) -> void:
 if state != "racing": return
 elapsed = minf(elapsed+delta,E.RACE_SECONDS)
 if elapsed >= E.RACE_SECONDS:
  state = "result"
  reward = int(E.ENTRY_COST * E.RACE_PAYOUT[selected]) if selected == winner else 0
func progress(index: int) -> float:
 var t := elapsed / E.RACE_SECONDS
 # Presentation cannot alter the precommitted winner.
 var finish := 1.0 if index == winner else .82 + index*.023
 return clampf(t*finish + sin(t*TAU+index)*.055*sin(t*PI),0,1)
