extends RefCounted
# FoundationPattern / DaoFoundationRecipe / FoundationResultRule: UI reads these only.
const PATTERNS = ["金","木","水","火","土","阴","阳","剑","灵"]
const WEIGHTS = [1,1,1,1,1,1,1,1,1]
const STABILITY = [100,72,42,42]
const MAX_REFORGES = 3
const REFORGE_SECONDS = .85
const FINAL_SECONDS = 3.6
const LINES = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
const RECIPES = [
 {"id":"red_sword","name":"赤霄剑基","need":{"火":3,"剑":3},"weight":90,"base_grade":7,"focus":["火","剑"],"step":2,"stability_bonus":0,"rare":true,"effects":["fire","sword","red_sword"],"description":"火与剑相融，剑气染霞。"},
 {"id":"five_elements","name":"五行道基","need":{"金":1,"木":1,"水":1,"火":1,"土":1},"weight":70,"base_grade":6,"focus":["金","木","水","火","土"],"step":2,"stability_bonus":5,"rare":true,"effects":["five_elements"],"description":"五行俱全，灵纹相生。"},
 {"id":"yin_yang","name":"阴阳道基","need":{"阴":2,"阳":2},"weight":60,"base_grade":6,"focus":["阴","阳"],"step":2,"stability_bonus":5,"rare":true,"effects":["yin_yang"],"description":"阴阳相济，动静同源。"},
 {"id":"sword","name":"剑道道基","need":{"剑":4},"weight":50,"base_grade":6,"focus":["剑"],"step":1,"stability_bonus":0,"rare":false,"effects":["sword"],"description":"剑纹凝聚，道心如锋。"},
 {"id":"fire","name":"火灵道基","need":{"火":4},"weight":40,"base_grade":6,"focus":["火"],"step":1,"stability_bonus":0,"rare":false,"effects":["fire"],"description":"炎纹聚气，赤焰内蕴。"},
 {"id":"water","name":"水灵道基","need":{"水":4},"weight":40,"base_grade":6,"focus":["水"],"step":1,"stability_bonus":0,"rare":false,"effects":["water"],"description":"水纹归流，灵息悠长。"},
 {"id":"mixed","name":"混合道基","need":{},"weight":0,"base_grade":2,"focus":[],"step":1,"stability_bonus":0,"rare":false,"effects":["mixed"],"description":"万象杂糅，尚待磨砺。"}
]
# Result roll: one draw at confirmation; never in rendering or previews.
const RESULT_RULE = {"drop_one":.48,"drop_two":.24,"conflict":.32,"flaw":.30,"rare_loss":.58,"max_drop":3}
static func recipe(id: String) -> Dictionary:
 for r in RECIPES:
  if r.id==id:return r
 return RECIPES[-1]
static func evaluate(grid: Array, stability: int) -> Dictionary:
 var counts: Dictionary={}
 for p in PATTERNS:counts[p]=grid.count(p)
 var chosen: Dictionary=RECIPES[-1]
 for r in RECIPES:
  var matches:=true
  for p in r.need:
   if counts[p]<r.need[p]:matches=false
  if matches and r.weight>chosen.weight:chosen=r
 var lines:=0
 for line in LINES:
  if grid[line[0]]==grid[line[1]] and grid[line[1]]==grid[line[2]]:lines+=1
 var focus:=0
 var required:=0
 for p in chosen.focus:focus+=counts[p];required+=int(chosen.need.get(p,0))
 var quality: int=chosen.base_grade+int((focus-required)/chosen.step)+mini(lines,1)
 if chosen.id=="mixed":quality=2+maxi(0,int(counts.values().max())-2)+mini(lines,1)
 quality=clampi(quality,1,9)
 var risk: float=clampf((100.0-stability-chosen.stability_bonus)/100.0,0,1)
 return {"recipe":chosen,"quality":quality,"low":maxi(1,quality-RESULT_RULE.max_drop) if risk>0 else quality,"risk":risk,"counts":counts,"lines":lines,"conflict":counts["火"]>=2 and counts["水"]>=2 and chosen.id!="five_elements"}

static func lesson(f) -> Array:
 var used: int=0 if f==null else f.reforges
 return [
  ["師父","徒儿，先不急着动手。筑基关乎往后的修行，眼前这些变化，你得先看明白。"],
  ["師父","初铸会生成九格灵纹，不耗重铸次数。这里没有必须凑齐的通关组合：初铸完成后，便可选择『筑基定型』。"],
  ["師父","右侧的类型由灵纹数量组合决定；组合潜力是一至九品，预计定型显示可能落在哪些品数。修炼修为加成按最终品数计算，类型与品数分开看。"],
  ["你","那若是眼下的结果不合适，我该如何调整？"],
  ["師父","点灵纹可锁定，再点可取消。按『重铸未锁定』只重抽未锁定格；已锁定格保留原位，经过重铸后便不能再取消锁定。"],
  ["師父","这一轮共有 %d 次重铸，当前剩余 %d 次。初铸不算一次；关闭再进或读档，都不会补回已经用掉的次数。" % [MAX_REFORGES,maxi(0,MAX_REFORGES-used)]],
  ["師父","重铸不另扣灵石、材料或寿元。代价是灵脉承压：稳定度依次为 %s。新增末次沿用末档，不再降低。" % str(STABILITY)],
  ["師父","稳定度不足时，定型可能降品或留瑕；水火冲突可能再降品，稀有类型也可能变成混合道基。具体预计范围看右侧，不必一味追高。"],
  ["你（心想）","先看类型、预计品数和稳定度，再决定要不要重铸。剩余机会再多，也不必全用完。"],
  ["師父","觉得合适，随时按『筑基定型』。次数耗尽或九格全锁，就不能再重铸，应当定型。定型演出结束，结果才真正落定。"],
  ["師父","失稳最多降 %d 品，最低保留一品，仍会进入筑基一层，寿元增加 %d 年。留瑕不取消最终品数的修炼加成。想明白了，再动手不迟。" % [RESULT_RULE.max_drop,preload("res://scripts/balance.gd").FOUNDATION_LIFE_REWARD]]
 ]
