extends RefCounted
static func allowed(m) -> bool:
 return not (m.activity_id == "tournament" or (m.activity_id == "duel" and m.duel != null and (m.duel.fair or not m.duel.story_mode.is_empty())))
static func entries(m) -> Array:
 var result: Array = []
 var keys: Array = m.sect.inventory.keys()
 if m.activity_id == "duel": keys = m.sect.C.CARDS
 elif m.activity_id == "blood": keys = m.sect.C.RELICS.keys()
 elif m.activity_id == "jade": keys = []
 for key in keys:
  var count: int = m.sect.inventory.get(key,0)
  if count <= 0: continue
  var detail: String = m.sect.C.RELIC_HELP.get(key,"留待合適時機使用。")
  if key in m.sect.C.CARDS: detail = "本場問劍啟用「"+m.sect.C.SKILLS[m.sect.C.CARDS.find(key)]+"」。"
  if key == m.BREAKTHROUGH_PILL: detail = "提升一個小境界，不跨大境界。"
  result.append({"key":key,"count":count,"detail":detail})
 if m.activity_id in ["","sect","lobby","materials","preparation","shop"]:
  for i in range(m.materials.size()):
   if m.materials[i] > 0: result.append({"key":m.E.MATERIAL_NAMES[i],"count":m.materials[i],"detail":"煉丹材料 · 到洞府開爐。"})
  for i in range(m.pills.size()):
   if m.pills[i] > 0: result.append({"key":m.E.PILL_NAMES[i],"count":m.pills[i],"detail":"結丹準備用丹藥。"})
  for key in m.blood_items:
   if m.blood_items[key] > 0: result.append({"key":key,"count":m.blood_items[key],"detail":"歷練所得，留待後用。"})
 return result
static func usable(m, key: String) -> bool:
 if not allowed(m) or not m.modal.is_empty() or m.result_delay > 0 or m.sect.inventory.get(key,0) <= 0: return false
 if key == m.BREAKTHROUGH_PILL: return m.can_use_breakthrough_pill()
 if m.activity_id == "duel" and key in m.sect.C.CARDS:
  var i: int = m.sect.C.CARDS.find(key)
  var valid_state: bool = m.duel.state == ("round_result" if i == 4 else "playing")
  return m.duel.skill_pause <= 0 and valid_state and not m.duel.skill_available(i) and not m.duel.skill_used.has(i)
 if m.activity_id != "blood" or m.blood == null or m.blood.relic_used.has(key): return false
 var b = m.blood
 match key:
  "換命符": return b.state == "choice"
  "定命符": return b.state in ["ready","choice"] and b.point > 0
  "鎮煞令": return b.state == "ready" and not b.ward
  "偷天符": return b.state == "ready" and b.preview.is_empty()
  "斬魔敕令": return b.state == "ready" and b.rolls == 0 and not m.sect.blood_elite
 return false
