extends RefCounted
const D = preload("res://scripts/duel_config.gd")
const P = preload("res://scripts/polish_config.gd")
signal cue(key: String)
var battle_log: Array[String] = []
var peek_visible := false
var probe_pending := false
var effect_target := "opponent"
func record(line: String):
 battle_log.append(line)
 if battle_log.size() > 250: battle_log.pop_front()
# peek_visible remains a one-token revelation (lesson / consumable).
func persistent_top_peek() -> bool:
 return not fair and skill_available(3) and player_level >= preload("res://scripts/sect_config.gd").SKILL_REALMS[3]
func exposed_top() -> int:
 if fair: return -1
 if persistent_top_peek(): return peek_token()
 return shared_next if peek_visible else -1
var source := "passive"
var story_mode := ""
var learned_probe := false
var player_level := 0
var fair := false
var senior := false
var skill_used: Dictionary = {}
var card_enabled: Dictionary = {}
var enemy_used: Dictionary = {}
var round_start_score: Array[int] = [0,0]
var peeked := false
var skill_notice := ""
var skill_time := 0.0
var skill_pause := 0.0
var skill_effect := ""
var shared_next := -1
var match_confirmed := false
var doubled := false
var shift_left := 0.0
var custom_name := ""
var custom_sect := ""
var narrative_lines: Array=[]
var natural_side := ""
var natural_return := "playing"
var feedback_serial := 0
var round_index := 0
var last_actor := "player"
var rng := RandomNumberGenerator.new()
const NPC = preload("res://scripts/duel_opponents.gd")
var npc_id := -1
var npc_stop := 17
var archetype := 0
var state := "arrival"
var player := 0
var opponent := 0
var player_hand: Array[int] = []
var opponent_hand: Array[int] = []
var revealed := false
var score: Array[int] = [0,0]
var round_result := ""
var serial := 0
var paid_out := false
var feedback_left := 0.0
var feedback := ""
var message := ""
var timer := 0.0
var pending_outcome := ""
var tricky_stop := 17
var active_challenge := false
var overrides: RefCounted
func _init(): rng.randomize()
func take(key: String, fallback: Variant = "") -> Variant:
 return overrides.take("duel."+key,fallback) if overrides != null else fallback
func accept() -> void:
 if state == "arrival": next_round()
func next_round() -> void:
 if state not in ["arrival","round_result"]: return
 if score[0] >= D.WINS or score[1] >= D.WINS:
  match_confirmed = true;state = "result";return
 doubled = false
 peeked = false
 probe_pending = false
 peek_visible = false
 if learned_probe: skill_used.erase(0)
 round_start_score.assign(score)
 shift_left = 0
 last_actor = "player"
 round_index += 1
 player_hand.clear()
 opponent_hand.clear()
 for i in range(2):
  player_hand.append(draw_token())
  opponent_hand.append(draw_token())
 player = hand_total(player_hand)
 opponent = hand_total(opponent_hand)
 tricky_stop = rng.randi_range(D.TRICKY_RANGE[0],D.TRICKY_RANGE[1])
 if npc_id >= 0:
  var band: Array=NPC.NPCS[npc_id].range
  npc_stop=rng.randi_range(band[0],band[1])
 state = "playing"
 if skill_available(3):
  peek_token();peek_visible = true
 record("第 %d 局 · 双方各出两剑，藏锋未露" % round_index)
 revealed = false
 round_result = ""
 message = "先看對手亮出的劍印，再決定進退。"
 flash("draw")
 if player == 21: start_natural("player","auto_stand")
func flash(kind: String):
 feedback = kind
 feedback_left = .65 if kind == "bust" else .4
 serial += 1
 feedback_serial += 1
 cue.emit("duel_bust" if kind == "bust" else "duel_draw")
func draw() -> void:
 if state != "playing" or player == 21 or skill_pause > 0: return
 var amount := draw_token()
 var forced: String = take("draw")
 if forced in ["low","medium","high"]: amount = {"low":2,"medium":5,"high":10}[forced]
 if doubled and skill_available(2):
  amount = 1 if player == 10 else 10
  effect_target = "player"
  skill_used[2] = true;ability_notice("天命一劍 · 二十一")
 if take("player_bust",false): amount = 32
 var old_soft := is_soft(player_hand)
 player_hand.append(amount)
 player = hand_total(player_hand)
 if old_soft and not is_soft(player_hand): shift_left = .9
 last_actor = "player"
 record("你再出一剑 · %s" % ("灵" if amount == 1 else str(amount)))
 flash("draw")
 message = "你又遞一式。"
 if player > 21:
  if skill_available(1):
   effect_target = "player"
   skill_used[1] = true;player = 20;ability_notice("劍罡護體 · 劍勢穩住在二十")
   if senior: narrative_lines.append(["大師姐","這才對。總算知道怎麼把命留在自己手裡了。"])
   state = "double_lock";timer = D.DOUBLE_DELAY
  else: prepare_result("loss",true)
 elif player == 21:
  peak()
 elif doubled:
  state = "double_lock"
  timer = D.DOUBLE_DELAY
  message = "孤注已出 · 收劍守勢"
 elif player >= 18:
  cue.emit("duel_pressure")
  message = "劍氣逼人，再進須慎。"
func draw_token() -> int:
 var token := peek_token()
 shared_next = -1
 peek_visible = false
 return token
func can_double() -> bool:
 return state == "playing" and skill_pause <= 0 and player_hand.size() == 2 and player in [10,11] and not doubled
func double_down():
 if not can_double(): return
 doubled = true
 record("你发动孤注一剑 · 此局胜负算两筹")
 state = "double_intro"
 timer = D.DOUBLE_DELAY
 message = "孤注一劍\n此劍既出，再無退路。勝負皆算兩籌。"
 feedback = "double"
 feedback_left = D.DOUBLE_DELAY
 cue.emit("duel_double")
func peak():
 record("你达成二十一 · 剑势圆满")
 state = "peak_hold"
 timer = D.PEAK_DELAY
 message = "一劍定局 · 二十一" if doubled else "劍勢圓滿 · 二十一 · 此局極境"
 feedback = "peak"
 feedback_left = D.PEAK_DELAY
 cue.emit("duel_21")
func stand() -> void:
 if state != "playing" or skill_pause > 0: return
 record("你收剑守势")
 state = "reveal_wait"
 timer = D.REVEAL_DELAY
 message = opponent_name()+"凝神觀勢……"
func wants_draw() -> bool:
 if fair: return opponent < D.FAIR_STOP[archetype]
 if senior:
  if hand_total(opponent_hand+[peek_token()]) > 21 and enemy_used.has(1):
   if not enemy_used.has(3): enemy_used[3] = true;ability_notice("窺天一線\n大師姐：這一劍，不出了。")
   return false
 if npc_id >= 0 and not senior:
  var rule: Dictionary=NPC.NPCS[npc_id]
  if rule.lead_stop and opponent > player: return false
  var threshold: int=mini(rule.cap,npc_stop+(rule.comeback if score[0]>score[1] or round_index>=3 else 0))
  if opponent >= threshold and not (opponent < player and opponent < rule.cap): return false
  var busts:=0
  for token in D.DRAW_POOL:
   if hand_total(opponent_hand+[token]) > D.LIMIT: busts+=1
  return float(busts)/D.DRAW_POOL.size() <= rule.risk
 match archetype:
  0: return opponent < D.STOP[0]
  1: return opponent < D.STOP[1]
  2: return opponent < tricky_stop
  3:
   # Uses only visible current totals. No future draws or hidden player information.
   if opponent > player: return false
   return opponent < D.GENIUS_MIN or (opponent < player and opponent < D.GENIUS_CHASE_CAP)
 return false
func prepare_result(outcome: String, bust: bool = false):
 if senior and not fair and outcome == "win" and not enemy_used.has(4):
  enemy_used[4] = true;state = "round_result";score.assign(round_start_score);next_round()
  ability_notice("逆轉光陰\n大師姐：剛才那局。重來。")
  state = "rewind_hold";timer = 1.1;return
 if bust: record(("你" if outcome == "loss" else opponent_name())+"爆牌 · 势满而崩")
 pending_outcome = outcome
 state = "settling"
 timer = D.BUST_DELAY if bust else D.RESULT_DELAY
 if bust:
  message = "勢滿而崩 · 劍氣潰散"
  flash("bust")
 else:
  message = "雙劍收勢，勝負將分。"
  feedback = "compare"
  feedback_left = .5
  feedback_serial += 1
  cue.emit("duel_draw")
func resolve(outcome: String) -> void:
 round_result = take("round",outcome)
 if round_result == "win": score[0] += 2 if doubled else 1
 if round_result == "loss": score[1] += 2 if doubled else 1
 var forced: String = take("match")
 if not forced.is_empty(): score.assign([0,3] if forced == "loss" else [3,int(forced)])
 state = "result" if score[0] >= 3 or score[1] >= 3 else "round_result"
 message = {"win":"此局你勝", "loss":"此局惜敗", "tie":"勢均力敵 · 再戰一局"}[round_result]
 record("你赢下一局" if round_result=="win" else (opponent_name()+"赢下一局" if round_result=="loss" else "双方平局 · 不记胜筹"))
 revealed = true
 feedback = round_result
 feedback_left = .6
 feedback_serial += 1
 serial += 1
 cue.emit("duel_round_win" if round_result == "win" else "duel_round_lose")
func set_score(left: int, right: int):
 if OS.is_debug_build() and state != "result": score.assign([clampi(left,0,2),clampi(right,0,2)])
func advance(delta: float):
 if skill_pause > 0:
  skill_pause = maxf(0,skill_pause-delta)
  skill_time = maxf(0,skill_time-delta)
  if skill_pause <= 0 and probe_pending:
   probe_pending = false;peeked = true
   record("神识探查完成 · "+opponent_name()+"藏锋揭开，剑势 %d" % opponent)
  return
 feedback_left = maxf(0,feedback_left-delta)
 shift_left = maxf(0,shift_left-delta)
 skill_time = maxf(0,skill_time-delta)
 if state not in ["reveal_wait","opponent_turn","settling","natural_wait","natural_glow","peak_hold","double_intro","double_lock","rewind_hold"]: return
 timer -= delta
 if timer > 0: return
 # At most one visual action per frame, including after a stalled frame.
 if state == "rewind_hold":
  state = "playing"
  if player == 21: peak()
 elif state in ["peak_hold","double_lock"]:
  state = "playing"
  stand()
 elif state == "double_intro":
  state = "playing"
  draw()
 elif state == "natural_wait":
  state = "natural_glow"
  timer = P.NATURAL_HIGHLIGHT
  feedback = "natural"
  feedback_left = P.NATURAL_HIGHLIGHT
  feedback_serial += 1
  serial += 1
  message = "一劍天成 · 起手二十一" if natural_side == "player" else "一劍天成 · 對手開局劍勢圓滿"
  record(("你" if natural_side=="player" else opponent_name())+"起手二十一 · 剑势圆满")
  cue.emit("duel_natural21")
 elif state == "natural_glow":
  if natural_return == "auto_stand":
   state = "playing"
   stand()
  else:
   state = natural_return
   timer = D.DRAW_DELAY
 elif state == "reveal_wait":
  revealed = true
  if senior and not fair and not enemy_used.has(0):
   effect_target = "player"
   enemy_used[0] = true;ability_notice("神識探查\n大師姐：藏得太明顯了。")
  state = "opponent_turn"
  timer = D.DRAW_DELAY
  message = opponent_name()+"亮出藏鋒。"
  last_actor = "opponent"
  flash("draw")
  if opponent == 21 and opponent_hand.size() == 2: start_natural("opponent","opponent_turn")
 elif state == "opponent_turn":
  if senior and not fair and opponent_hand.size() == 2 and opponent in [10,11] and not enemy_used.has(2):
   draw_token() # Both actors consume the same next token, even when a power transforms it.
   effect_target = "opponent"
   enemy_used[2] = true;doubled = true;opponent_hand.append(1 if opponent == 10 else 10);opponent = 21
   ability_notice("天命一劍\n大師姐：要賭，就賭得乾脆一點。")
   timer = D.PEAK_DELAY;return
  if wants_draw():
   var amount := draw_token()
   if take("opponent_bust",false): amount = 32
   opponent_hand.append(amount)
   opponent = hand_total(opponent_hand)
   last_actor = "opponent"
   record(opponent_name()+"再出一剑 · %s" % ("灵" if amount == 1 else str(amount)))
   flash("draw")
   message = opponent_name()+"又遞一式。"
   timer = D.DRAW_DELAY
   if opponent > 21:
    if senior and not fair and not enemy_used.has(1):
     effect_target = "opponent"
     enemy_used[1] = true;opponent = 20
     ability_notice("劍罡護體\n大師姐：誰告訴你，勢滿就一定得崩？")
     prepare_result("win" if player > opponent else ("tie" if player == opponent else "loss"))
    else: prepare_result("win",true)
   elif opponent >= 18:
    cue.emit("duel_pressure")
    if opponent == 21:
     message = "劍勢圓滿 · 二十一"
     feedback = "peak";feedback_left = D.PEAK_DELAY;timer = D.PEAK_DELAY;feedback_serial += 1
     record(opponent_name()+"达成二十一 · 剑势圆满")
     cue.emit("duel_21")
  else: prepare_result("win" if player > opponent else ("tie" if player == opponent else "loss"))
 else:
  if not revealed and opponent == 21 and opponent_hand.size() == 2:
   revealed = true
   start_natural("opponent","settling")
  else: resolve(pending_outcome)

static func hand_total(hand: Array) -> int:
 var value := 0
 var aces := 0
 for token in hand:
  value += 11 if token == 1 else token
  if token == 1: aces += 1
 while value > 21 and aces > 0:
  value -= 10
  aces -= 1
 return value
static func is_soft(hand: Array) -> bool:
 var minimum := 0
 for token in hand: minimum += token
 return hand_total(hand) > minimum
func opponent_name() -> String:
 return custom_name if not custom_name.is_empty() else (NPC.NPCS[npc_id].name if npc_id>=0 else D.NAMES[archetype])
func opponent_sect() -> String:
 return custom_sect if not custom_sect.is_empty() else (NPC.NPCS[npc_id].sect if npc_id>=0 else D.SECTS[archetype])
func start_natural(side: String, return_to: String):
 natural_side = side
 natural_return = return_to
 state = "natural_wait"
 timer = P.NATURAL_DELAY
 message = "劍印落定……"
 serial += 1

func skill_available(index: int) -> bool:
 if fair or index not in range(5) or skill_used.has(index): return false
 if index == 0: return learned_probe or card_enabled.has(0)
 return player_level >= preload("res://scripts/sect_config.gd").SKILL_REALMS[index] or card_enabled.has(index)
func can_skill(index: int) -> bool:
 if skill_pause > 0: return false
 if not skill_available(index): return false
 if index == 0: return state == "playing" and not revealed and not peeked
 if index in [1,2]: return false
 if index == 3: return state == "playing" and not peek_visible
 if index == 4: return state == "round_result"
 return state == "playing"
func use_skill(index: int) -> bool:
 if not can_skill(index): return false
 if index == 0:
  effect_target = "opponent"
  probe_pending = true;skill_used[index] = true;ability_notice("神識探查 · 凝神窥视藏锋")
  skill_pause = 3.0;skill_time = 3.0
 elif index == 3:
  peek_token();peek_visible = true;record("你发动窥天一线 · 已展露真实顶牌")
 elif index == 4:
  effect_target = "player"
  skill_used[index] = true;score.assign(round_start_score);round_index -= 1;match_confirmed = false;state = "round_result";next_round()
  ability_notice("逆轉光陰 · 這一局重來")
  state = "rewind_hold";timer = 1.1
 else: return false
 return true
func peek_token() -> int:
 if shared_next < 0: shared_next = D.DRAW_POOL[rng.randi_range(0,D.DRAW_POOL.size()-1)]
 return shared_next
func ability_notice(value: String):
 var parts:=value.split("\n大師姐：",true,1)
 if parts.size()>1: narrative_lines.append(["大師姐",parts[1]])
 var actor: String=opponent_name() if parts.size()>1 else "你"
 value=parts[0]
 record(actor+"发动 · "+value.replace("\n"," · "))
 skill_notice = value;skill_time = 3.4;skill_pause = 3.4
 skill_effect = "shield" if value.contains("護體") else ("rewind" if value.contains("光陰") else ("foresight" if value.contains("窺天") else ("destiny" if value.contains("天命") else "probe")))
 cue.emit("duel_pressure")
