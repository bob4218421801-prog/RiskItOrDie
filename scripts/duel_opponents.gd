extends RefCounted
## NPC identity/AI share the four existing economy profiles. Tournament AI stays separate.
const NPCS = [
 {"name":"韩青","sect":"玄剑门","style":"沉稳剑修","economy":0,"stop":15,"cap":16,"lead_stop":true,"risk":.30,"range":[15,15],"comeback":0,"early_weight":8},
 {"name":"赤锋","sect":"赤霄山","style":"狂剑修","economy":1,"stop":19,"cap":20,"lead_stop":false,"risk":.90,"range":[19,19],"comeback":1,"early_weight":3},
 {"name":"柳玄白","sect":"青衡宗","style":"灵巧剑修","economy":2,"stop":17,"cap":19,"lead_stop":false,"risk":.65,"range":[15,19],"comeback":1,"early_weight":5},
 {"name":"沈孤鸿","sect":"太清宗","style":"冷静剑修","economy":3,"stop":18,"cap":19,"lead_stop":true,"risk":.65,"range":[18,18],"comeback":0,"early_weight":1},
 {"name":"叶惊尘","sect":"凌霄剑派","style":"锋锐剑修","economy":3,"stop":18,"cap":20,"lead_stop":false,"risk":.85,"range":[18,18],"comeback":1,"early_weight":1},
 {"name":"苏晚晴","sect":"云岚宗","style":"稳健剑修","economy":0,"stop":16,"cap":17,"lead_stop":true,"risk":.45,"range":[16,16],"comeback":0,"early_weight":6},
 {"name":"顾长风","sect":"藏剑谷","style":"藏锋剑修","economy":2,"stop":16,"cap":19,"lead_stop":false,"risk":.70,"range":[16,16],"comeback":3,"early_weight":3},
 {"name":"洛无尘","sect":"天剑门","style":"极意剑修","economy":3,"stop":18,"cap":20,"lead_stop":true,"risk":.75,"range":[18,18],"comeback":1,"early_weight":1}
]
static func choose(rng: RandomNumberGenerator, last: int, level: int) -> int:
 var weights: Array[int]=[]
 var total:=0
 for i in range(NPCS.size()):
  var weight: int=0 if i==last else (NPCS[i].early_weight if level<13 else 4)
  weights.append(weight);total+=weight
 var roll:=rng.randi_range(1,total)
 for i in range(weights.size()):
  roll-=weights[i]
  if roll<=0:return i
 return 0
