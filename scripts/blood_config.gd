extends RefCounted
const UNLOCK_REALM = 10
const INTERVAL = [45,70]
const REVERSE_COST = 150
const STONES = [650,950]
const MATERIALS = [1,3]
const FRAGMENTS = [1,2]
const LOSS_STONES = 350
const LOSS_CULTIVATION = .12
const RAW_WEIGHTS = [.0,.60,.35,.05]
const RARE_CHANCE = .04
const FIRST_WIN = [7,11]
const FIRST_LOSS = [2,3,12]
const POINTS = [4,5,6,8,9,10]
const ROLL_PHASES = [["rise",.3],["spin",.45],["fall",.3],["left",.35],["right",.35],["total",.4]]
const RESULT_PHASES = {"win":[["pause",.35],["gate",.7],["break",.6]],"loss":[["quiet",.4],["seven",.7],["close",.55]]}
