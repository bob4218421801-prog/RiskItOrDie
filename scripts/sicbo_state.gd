extends RefCounted
const C = preload("res://scripts/sect_config.gd")
var rng := RandomNumberGenerator.new()
var state := "ready"
var demo := false
var stake := 0
var bet_selected := false
var bet := "小"
var target := 10
var dice: Array[int] = [0,0,0]
var shown: Array[int] = [0,0,0]
var index := 0
var timer := 0.0
var reward := 0
var paid := false
func _init(): rng.randomize()
func start(is_demo: bool = false):
 if state != "ready": return
 demo = is_demo
 dice.assign([5,5,5] if demo else [rng.randi_range(1,6),rng.randi_range(1,6),rng.randi_range(1,6)])
 state = "rolling";timer = .8;index = 0
func advance(delta: float):
 if state == "observing":
  timer -= delta
  if timer <= 0: state = "result"
  return
 if state != "rolling": return
 timer -= delta
 if timer > 0: return
 if index < 3:
  shown[index] = dice[index];index += 1;timer = C.SICBO_REVEAL*(2 if index == 2 else 1)
 else:
  reward = stake*multiplier(dice,bet,target)
  state = "observing";timer = preload("res://scripts/tutorial_pacing.gd").RESULT_READ
static func multiplier(values: Array, choice: String, exact: int = 10) -> int:
 var total: int = values[0]+values[1]+values[2]
 var triple: bool = values[0] == values[1] and values[1] == values[2]
 if choice == "指定總點數": return C.SICBO_TOTAL.get(exact,0) if total == exact else 0
 if triple: return C.SICBO_PAYOUT["任意豹子"] if choice == "任意豹子" else 0
 var won: bool = (choice == "小" and total in range(4,11)) or (choice == "大" and total in range(11,18)) or (choice == "單" and total%2 == 1) or (choice == "雙" and total%2 == 0)
 return C.SICBO_PAYOUT.get(choice,0) if won else 0
