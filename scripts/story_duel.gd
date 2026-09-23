extends "res://scripts/duel_state.gd"
# Separate, saved story timeline. No call to draw_token() or gameplay RNG.
var tutorial_duel_deck_sequence: Array = []
var lesson_deck: Array[int] = []
var cursor := -1
var expected := ""
var speaker := ""
var dialogue := ""
var completed_rounds := 0
var peak_round_seen: Dictionary = {}
const PACING = preload("res://scripts/tutorial_pacing.gd")
var dealt_player: Array = []
var dealt_enemy: Array = []
var deal_index := 0
func setup(mode: String):
 peak_round_seen.clear();story_mode = mode;source = "tutorial_"+mode;custom_name = "小師妹" if mode == "junior" else "大師姐"
 custom_sect = "同門" if mode == "junior" else "同門 · 築基七層"
 player_level = 0;senior = false
 tutorial_duel_deck_sequence = preload("res://scripts/story_lessons.gd").build(mode)
 step()
func step():
 cursor += 1;expected = "";speaker = "";dialogue = "";message = "";skill_time = 0
 if cursor >= tutorial_duel_deck_sequence.size(): state = "result";return
 var event: Dictionary = tutorial_duel_deck_sequence[cursor]
 match event.kind:
  "say":
   state = "story_dialogue";speaker = event.who;dialogue = event.text
  "deal":
   round_index += 1;peak_round_seen.clear();dealt_player = event.player.duplicate();dealt_enemy = event.enemy.duplicate()
   player_hand.clear();opponent_hand.clear();player = 0;opponent = 0;deal_index = 0
   revealed = false;peeked = false;doubled = false
   if story_mode == "junior" and round_index == 4: revealed = true;opponent = 10
   record("第 %d 局 · 双方出剑" % round_index)
   state = "story_dealing";timer = PACING.DEAL_BEAT;feedback = ""
  "wait": state = "playing";expected = event.action;message = event.get("hint","")
  "draw":
   last_actor = "player" if event.actor == "player" else "opponent"
   record(("你" if last_actor == "player" else custom_name)+"再出一剑 · %d" % event.value)
   if event.actor == "player": player_hand.append(event.value);player = hand_total(player_hand)
   else: opponent_hand.append(event.value);opponent = hand_total(opponent_hand)
   state = "story_effect";timer = .7;feedback = "draw";feedback_left = .7;cue.emit("duel_draw")
  "reveal":
   revealed = true;state = "story_effect";timer = .6;cue.emit("duel_draw")
   if story_mode == "junior" and round_index == 4: opponent = 10
  "effect":
   state = "rewind_hold" if event.get("effect","") == "rewind" else "story_effect"
   effect_target = "player" if event.get("effect","") == "probe" else "opponent"
   if event.get("effect","") == "foresight":
    lesson_deck.assign([8]);shared_next = lesson_deck[0];peek_visible = true
   record(custom_name+" · "+str(event.text).replace("\n"," · "))
   timer = event.get("time",1.0);message = event.text;feedback = event.get("effect","peak");feedback_left = timer
   if event.has("player"): player = event.player
   if event.has("enemy"): opponent = event.enemy
   if event.get("clear",false): player_hand.clear();opponent_hand.clear();player = 0;opponent = 0
   if event.has("score"): score.assign(event.score)
   if feedback in ["natural","peak"]:
    var actor: String="opponent" if feedback=="natural" else "player"
    if not claim_peak(actor): feedback="";feedback_left=0
   cue.emit("silence" if feedback == "quiet" else ("duel_bust" if feedback == "bust" else "duel_pressure"))
  "score":
   record(event.get("text","胜负已定"))
   score.assign(event.value);completed_rounds = event.round
   state = "story_effect";timer = .8;message = event.get("text","")
  "end": state = "result"
func story_next():
 if state == "story_dialogue": step()
func draw() -> void:
 if state == "playing" and expected == "draw": step()
func stand() -> void:
 if state == "playing" and expected == "stand": step()
func double_down():
 if can_double(): doubled = true;step()
func can_double() -> bool: return state == "playing" and expected == "double"
func next_round() -> void: pass
func skill_available(_index: int) -> bool: return false
func advance(delta: float):
 feedback_left = maxf(0,feedback_left-delta)
 if state == "story_dealing":
  timer -= delta
  if timer > 0: return
  if deal_index < dealt_player.size():
   var token: int = dealt_player[deal_index]
   if not lesson_deck.is_empty():
    token = lesson_deck.pop_front();shared_next = -1;peek_visible = false
   player_hand.append(token);player = hand_total(player_hand)
  else:
   opponent_hand.append(dealt_enemy[deal_index-dealt_player.size()]);opponent = hand_total(opponent_hand)
   if story_mode == "junior" and round_index == 4: opponent = 10
  cue.emit("duel_draw");deal_index += 1;timer = PACING.DEAL_BEAT
  if deal_index == dealt_player.size()+dealt_enemy.size():
   state = "story_observe";timer = PACING.FIRST_HAND_READ if round_index == 1 else PACING.LATER_HAND_READ
  return
 if state == "story_observe":
  timer -= delta
  if timer <= 0: step()
  return
 if state not in ["story_effect","rewind_hold"]: return
 timer -= delta
 if timer <= 0:
  state = "story_observe";timer = PACING.RESULT_READ

# The lesson contains several explanation events for the same 21. Claim the
# presentation once per actor and effective round, not once per UI refresh.
func claim_peak(actor: String) -> bool:
 var total: int=opponent if actor=="opponent" else player
 if total!=21 or peak_round_seen.get(actor,-1)==round_index: return false
 peak_round_seen[actor]=round_index
 return true
