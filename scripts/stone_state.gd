extends RefCounted
## Outcomes are committed before the first scratch. Pointer coordinates only expose them.
const E = preload("res://scripts/economy_config.gd")
var overrides: RefCounted
var rng := RandomNumberGenerator.new()
var state := "ready"
var tier := 0
var assistance := 0
var depth := 0
var covered: Dictionary = {}
var rewards: Array[Dictionary] = []
var failures: Array[bool] = []
var protected := false
var result: Dictionary = {}
var paid_out := false
var clue := ""
func _init(): rng.randomize()
func start(raw_tier: int, service: int, force: String = "") -> void:
 if state != "ready": return
 tier = raw_tier
 assistance = service
 for stage in range(3):
  var weights: Array = E.MATERIAL_WEIGHTS[tier].duplicate()
  if assistance == 2:
   weights[3] *= E.GREED_RARE_MULTIPLIER
   weights[4] *= E.GREED_RARE_MULTIPLIER
  var cap: int = [1,3,4][stage]
  for i in range(cap+1,5): weights[i] = 0.0
  var total := 0.0
  for weight in weights: total += weight
  var roll := rng.randf()*total
  var material := 0
  for i in range(5):
   roll -= weights[i]
   if roll <= 0:
    material = i
    break
  if OS.is_debug_build():
   if force == "common": material = 0
   if force == "gold" and stage == 2: material = 3
   if force == "core" and stage == 2: material = 4
  rewards.append({"material":material,"quantity":1+stage if material < 3 else 1})
  var risk: float = E.STONE_FAIL[stage]
  if assistance == 1: risk *= E.PROTECTION_RISK_SCALE
  if assistance == 2 and stage > 0: risk += E.GREED_EXTRA_RISK
  failures.append(rng.randf() < risk)
 if OS.is_debug_build() and force in ["common","gold","core"]: failures.assign([false,false,false])
 if OS.is_debug_build() and force in ["failure","protected"]: failures.assign([false,true,true])
 protected = assistance == 1 and rng.randf() < E.PROTECTION_KEEP_CHANCE
 if OS.is_debug_build() and force == "protected": protected = assistance == 1
 clue = ["靈韻平平","淡青靈光","紫氣若隱","金芒暗藏","天華暗藏"][rewards[2].material] if assistance == 3 else "石皮未開，靈息難辨"
 state = "scratching"
func scratch(point: Vector2) -> void:
 if state != "scratching": return
 var cell := Vector2(point.x*E.SCRATCH_COLUMNS,point.y*E.SCRATCH_ROWS)
 for y in range(maxi(0,int(cell.y)-2),mini(E.SCRATCH_ROWS,int(cell.y)+3)):
  for x in range(maxi(0,int(cell.x)-2),mini(E.SCRATCH_COLUMNS,int(cell.x)+3)):
   if Vector2(x+.5,y+.5).distance_to(cell) <= E.SCRATCH_BRUSH: covered[y*E.SCRATCH_COLUMNS+x] = true
 if coverage() >= E.SCRATCH_REQUIRED:
  var broken: bool = failures[depth]
  var forced: String = overrides.peek("stone.result") if overrides != null else ""
  if not forced.is_empty():
   var target := 2 if forced in ["purple","gold","core","stage3","greed"] else (1 if forced in ["stage2","failure","protected","protection_failure"] else 0)
   broken = false
   if depth >= target:
    overrides.take("stone.result")
    if forced in ["stage2","stage3","failure","protected","protection_failure"]:
     broken = true
     protected = forced == "protected" and assistance == 1
    else:
     rewards[depth].material = {"common":0,"purple":2,"gold":3,"core":4,"greed":4}.get(forced,0)
     rewards[depth].quantity = 1
  if broken: finish(true)
  else:
   state = "choice"
   clue = ["淡青靈光","赤氣浮動","紫氣若隱","金芒暗藏","天華暗藏"][rewards[depth].material]
func coverage() -> float:
 return float(covered.size())/(E.SCRATCH_COLUMNS*E.SCRATCH_ROWS)
func deeper() -> void:
 if state != "choice" or depth >= 2: return
 depth += 1
 covered.clear()
 state = "scratching"
func collect() -> void:
 if state == "choice": finish(false)
func finish(failed: bool) -> void:
 if state not in ["scratching","choice"]: return
 var kept := failed and depth > 0 and protected
 result = {"failed":failed,"protected":kept,"material":-1,"quantity":0,"fragments":E.STONE_FRAGMENTS[tier] if failed else 0}
 if not failed or kept:
  var reward: Dictionary = rewards[depth-1 if kept else depth]
  result.material = reward.material
  result.quantity = reward.quantity
 state = "result"

