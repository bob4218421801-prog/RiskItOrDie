extends RefCounted
const P = preload("res://scripts/polish_config.gd")
const C = preload("res://scripts/sect_config.gd")
var kind := "sect"
var reward_text := ""
var rng := RandomNumberGenerator.new()
var year := 750
var stage := "between"
var wins := 0
var losses := 0
var index := 0
var rank := 0
var paid := false
var board: Array[Dictionary] = []
var records: Array[Dictionary] = []
var ceremony := 0
var timer := 0.0
var legacy_five := false
var story_delay := 1.0
func total_matches() -> int: return 5 if kind == "tianji" or legacy_five else C.SECT_MATCHES
func _init(): rng.randomize()
func record(win: bool, score: Array):
 if stage != "fighting" or index >= total_matches(): return
 records.append({"name":names()[index],"win":win,"score":score.duplicate()})
 if win: wins += 1
 else: losses += 1
 index += 1
 stage = "between"
 if index == total_matches():
  var bounds: Array = P.RANK_RANGES[wins]
  rank = rng.randi_range(bounds[0],bounds[1]) if kind == "tianji" or legacy_five else C.SECT_RANKS[wins]
  build_board()
  stage = "ceremony" if wins == total_matches() else "final"
  ceremony = 0
  timer = P.CHAMPION_STAGES[0]
func advance(delta: float):
 if stage != "ceremony": return
 timer -= delta
 if timer > 0: return
 ceremony += 1
 if ceremony >= P.CHAMPION_STAGES.size(): stage = "final"
 else: timer = P.CHAMPION_STAGES[ceremony]
func build_board():
 board.clear()
 # Abstract record bands; deliberately no fictitious full NPC tournament simulator.
 for place in range(1,25):
  if place == rank:
   board.append({"rank":place,"name":"你","sect":"本宗弟子","wins":wins,"losses":losses,"player":true})
  elif kind == "sect" and place == 1:
   board.append({"rank":1,"name":"大師姐","sect":"宗門魁首","wins":total_matches(),"losses":0,"player":false})
  else:
   var victories := 5 if place == 1 else (4 if place <= 3 else (3 if place <= 8 else (2 if place <= 16 else 1)))
   victories = mini(total_matches(),victories)
   board.append({"rank":place,"name":["顧","林","沈","柳","白","陸"][place%6]+["清霄","望川","雲舟","問塵"][(place-1)/6],"sect":P.FESTIVAL_SECTS[place%5] if kind == "tianji" else ["劍峰弟子","丹堂弟子","內門弟子"][place%3],"wins":victories,"losses":total_matches()-victories,"player":false})
 if rank == 0: board.append({"rank":0,"name":"你","sect":"本宗弟子","wins":0,"losses":5,"player":true})

func title() -> String: return "天機大比" if kind == "tianji" else "宗門大比"
func board_title() -> String: return "天機榜" if kind == "tianji" else "宗門榜"
func champion() -> String: return "天機魁首" if kind == "tianji" else "宗門亞軍"
func names() -> Array: return preload("res://scripts/sect_config.gd").SECRET_NAMES if kind == "tianji" else ["林照","白行舟","陸赤嵐","沈清霄","柳望川"]
func sects() -> Array: return preload("res://scripts/sect_config.gd").SECRET_SECTS if kind == "tianji" else ["劍峰弟子","丹堂弟子","內門弟子","劍峰弟子","內門弟子"]
