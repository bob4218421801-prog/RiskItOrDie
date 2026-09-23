extends RefCounted
const C=preload("res://scripts/balance.gd")
const R=preload("res://scripts/foundation_rules.gd")
signal cue(key: String)
var version:=2
var rng:=RandomNumberGenerator.new()
var overrides: RefCounted
var grid: Array=[]
var locks: Array=[]
var committed: Array=[]
var pending_grid: Array=[]
var reforges:=0
var stability:=100
var grade:=0
var state:="choice"
var phase:=""
var left:=0.0
var duration:=0.0
var result: Dictionary={}
var settled:=false
var serial:=0
func _init():
 rng.randomize()
 for i in range(9):grid.append(draw_pattern());locks.append(false);committed.append(false)
func draw_pattern() -> String:
 var roll: float=rng.randf()*R.WEIGHTS.reduce(func(a,b):return a+b,0)
 for i in R.PATTERNS.size():
  roll-=R.WEIGHTS[i]
  if roll<=0:return R.PATTERNS[i]
 return R.PATTERNS[-1]
func preview() -> Dictionary:return R.evaluate(grid,stability)
func toggle(index: int):
 if state!="choice" or reforges>=R.MAX_REFORGES or index<0 or index>=9 or committed[index]:return
 locks[index]=not locks[index]
func reforge():
 if state!="choice" or reforges>=R.MAX_REFORGES or not locks.has(false):return
 pending_grid=grid.duplicate()
 for i in range(9):
  if locks[i]:committed[i]=true
  else:pending_grid[i]=draw_pattern()
 reforges+=1;stability=R.STABILITY[reforges]
 state="reforging";phase="reforge";duration=R.REFORGE_SECONDS;left=duration
func stop():
 if state!="choice":return
 var p:=preview()
 var loss:=0
 if rng.randf()<p.risk*R.RESULT_RULE.drop_one:loss+=1
 if rng.randf()<p.risk*R.RESULT_RULE.drop_two:loss+=2
 var conflict: bool=p.conflict and rng.randf()<p.risk*R.RESULT_RULE.conflict
 if conflict:loss+=1
 var flaw: bool=rng.randf()<p.risk*R.RESULT_RULE.flaw
 var rare_lost: bool=p.recipe.rare and rng.randf()<p.risk*R.RESULT_RULE.rare_loss
 var r: Dictionary=R.recipe("mixed") if rare_lost else p.recipe
 grade=maxi(1,p.quality-mini(loss,R.RESULT_RULE.max_drop))
 result={"final":grade,"potential":p.quality,"type":r.id,"name":r.name,"rare":r.rare,"flags":r.effects.duplicate(),"flaw":flaw,"conflict":conflict,"rare_lost":rare_lost,"multiplier":C.foundation_modifier(grade)}
 if flaw:result.flags.append("flawed")
 state="finalizing";phase="gather";duration=R.FINAL_SECONDS+(1.0 if grade>=8 or r.rare else 0.0);left=duration
func advance(delta: float):
 if state not in ["reforging","finalizing"]:return
 left=maxf(0,left-delta)
 if state=="finalizing":
  var t: float=1-left/duration
  phase="illuminate" if t<.2 else "connect" if t<.4 else "gather" if t<.65 else "burst" if t<.85 else "reveal"
 if left>0:return
 if state=="reforging":grid=pending_grid.duplicate();pending_grid.clear();state="choice";phase=""
 else:state="locked";settled=true;serial+=1;phase="result"
# Compatibility for old focus/restore hooks; the obsolete hold mechanic is removed.
func release_hold():pass
func attempt(_force: String="",_severity: int=0):reforge()
