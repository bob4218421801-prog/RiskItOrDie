extends RefCounted
const E = preload("res://scripts/economy_config.gd")
var rng := RandomNumberGenerator.new()
var state := "ready"
var crystals: Dictionary = {}
var dangers: Array[int] = []
var revealed: Array[int] = []
var lost_reward := 0
var reward := 0
var paid_out := false
func _init(): rng.randomize()
func start() -> void:
 if state != "ready": return
 var cells: Array[int] = []
 for i in range(E.MINES_SIZE): cells.append(i)
 for i in range(E.MINES_SIZE-1,0,-1):
  var j := rng.randi_range(0,i)
  var value := cells[i]
  cells[i] = cells[j]
  cells[j] = value
 dangers.assign(cells.slice(0,E.MINES_DANGERS))
 for cell in cells.slice(E.MINES_DANGERS): crystals[cell] = "rare" if rng.randf() < .08 else "ordinary"
 state = "mining"
func reveal(cell: int) -> void:
 if state != "mining" or cell < 0 or cell >= E.MINES_SIZE or cell in revealed: return
 revealed.append(cell)
 if cell in dangers:
  lost_reward = reward
  reward = 0
  state = "failed"
  return
 var survival := 1.0
 for i in range(revealed.size()): survival *= float(E.MINES_SIZE-E.MINES_DANGERS-i)/(E.MINES_SIZE-i)
 reward = int(floor(E.ENTRY_COST*E.MINES_RETURN/survival))
 if revealed.size() == E.MINES_SIZE-E.MINES_DANGERS: collect()
func collect() -> void:
 if state != "mining" or revealed.is_empty(): return
 state = "collected"
