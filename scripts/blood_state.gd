extends RefCounted
const B = preload("res://scripts/blood_config.gd")
signal cue(key: String)
var practice := false
const PACING = preload("res://scripts/tutorial_pacing.gd")
var extra_swap := false
var ward := false
var ward_used := false
var fixed_point := false
var preview: Array[int] = []
var relic_used: Dictionary = {}
var awaiting_judgement := false
var rng := RandomNumberGenerator.new()
var state := "ready"
var phase := ""
var left := 0.0
var duration := 0.0
var sequence: Array = []
var dice: Array[int] = [0,0]
var visible_dice: Array[int] = [0,0]
var point := 0
var total := 0
var rolls := 0
var reverse_used := false
var reroll_side := -1
var outcome := ""
var paid_out := false
var message := "定命 · 擲下兩枚命骨，尋一線生機。"
func _init(): rng.randomize()
func roll():
 if state == "choice" and total != 7: state = "ready"
 if state != "ready": return
 rolls += 1
 reroll_side = -1
 if preview.is_empty(): dice.assign([rng.randi_range(1,6),rng.randi_range(1,6)])
 else: dice.assign(preview);preview.clear()
 visible_dice.assign([0,0])
 begin_roll()
func can_reverse() -> bool:
 return not practice and state == "choice" and point > 0 and not reverse_used
func reverse(side: int) -> bool:
 if not can_reverse() or side not in [0,1]: return false
 reverse_used = true
 reroll_side = side
 dice[side] = rng.randi_range(1,6)
 visible_dice[side] = 0
 cue.emit("blood_reverse")
 begin_roll()
 return true
func begin_roll():
 awaiting_judgement = false
 state = "rolling"
 total = 0
 message = "命骨離掌……" if reroll_side < 0 else "逆命 · 一骨再起，命數未定。"
 sequence = B.ROLL_PHASES.duplicate(true)
 sequence.append(["observe",PACING.RESULT_READ])
 next_phase()
func next_phase():
 var step: Array = sequence.pop_front()
 phase = step[0]
 duration = step[1]
 left = duration
 if phase == "left":
  visible_dice[0] = dice[0]
  if reroll_side != 1: cue.emit("blood_bone")
 if phase == "right":
  visible_dice[1] = dice[1]
  if reroll_side != 0: cue.emit("blood_bone")
 if phase == "total": total = dice[0]+dice[1]
 if phase == "quiet": cue.emit("silence")
 if phase == "seven": cue.emit("blood_seven")
 if phase == "gate": cue.emit("blood_gate")
func advance(delta: float):
 if state not in ["rolling","presenting"]: return
 left -= delta
 if left > 0: return
 # One reveal per frame, including after a stalled frame; presentation never draws RNG.
 if not sequence.is_empty(): next_phase()
 elif state == "rolling": judge()
 else:
  state = "result"
  phase = ""
func judge():
 if not practice and extra_swap and not relic_used.has("換命符") and (point == 0 or total == point):
  awaiting_judgement = true;state = "choice";phase = ""
  message = "命骨落定。可以就此定命，或用換命符重擲一骨。";return
 if point > 0 and total == 7 and ward:
  ward = false;ward_used = true;state = "ready";phase = "";message = "鎮煞令壓住了七煞，再擲一次。";return
 if point == 0:
  if total in B.FIRST_WIN: conclude(true,"破陣")
  elif total in B.FIRST_LOSS: conclude(false,"凶煞鎖命")
  else:
   point = total
   state = "ready"
   phase = ""
   message = "生門已定 · %d\n再尋生門，避開七煞。" % point
 elif total == point:
  conclude(true,"逆命成功 · 生門重現" if reroll_side >= 0 else "生門重現")
 elif not practice and (not reverse_used or extra_swap):
  state = "choice"
  phase = ""
  message = "七煞將臨……可逆命一次，或認命。" if total == 7 else "命數未定。可繼續擲，或逆命一骨。"
  if reverse_used: message = "可用換命符重擲一骨，或接受這次命數。"
 elif total == 7: conclude(false,"七煞臨身")
 else:
  state = "ready"
  phase = ""
  message = "命數未定。"
func accept_fate():
 if state != "choice": return
 if awaiting_judgement:
  awaiting_judgement = false;extra_swap = false;judge();return
 if total == 7: conclude(false,"七煞臨身")
 else: roll()
func conclude(win: bool, text: String):
 outcome = "win" if win else "loss"
 message = text
 state = "presenting"
 sequence = B.RESULT_PHASES[outcome].duplicate(true)
 next_phase()
