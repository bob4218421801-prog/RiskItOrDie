extends RefCounted
const INTERVAL = [12,20]
const FIRST_INTERVAL = [4,8]
const HARD_LIMIT = 24
const LIMIT = 21
const WINS = 3
const NAMES = ["韓青", "赤鋒", "柳無痕", "顧青玄"]
const SECTS = ["玄劍門", "赤霄山", "藏鋒谷", "太虛劍宗"]
const ARCHETYPES = ["沉穩劍修", "狂劍修", "詭劍修", "天才劍修"]
const STYLES = ["劍路沉穩，常會提早收勢。", "偏愛追高劍勢，也容易貪進失控。", "出劍忽疾忽緩，收勢難以捉摸。", "善觀已露劍勢，判斷更為老練。"]
const RISKS = ["尚可一試", "鋒芒逼人", "吉凶難料", "險象環生"]
const STOP = [15,19,17,17]
const ESCAPE = [120,240,260,400]
const REFUSAL = [.03,.04,.04,.05]
const REWARDS = [320,550,600,850]
const LOSSES = [200,350,400,550]
const CULTIVATION_LOSS = [.06,.10,.11,.15]
const LOSS_SCALE = [1.15,1.0,.75]
const SCORE_BONUS = [1.2,1.08,1.0]
const TREASURE_CHANCES = [.04,.10,.12,.20]
const TREASURE_CHANCE = .12
const TREASURES = ["定靈玉","護脈佩","鎮魂鈴"]
const DRAW_RANGE = [1,10]
const REVEAL_DELAY = .65
const DRAW_DELAY = .9
const RESULT_DELAY = .5
const BUST_DELAY = .8
const BOARD_INTERVAL = 20
const ACTIVE_REALM = 11

const TRICKY_RANGE = [14,20]
const GENIUS_MIN = 18
const GENIUS_CHASE_CAP = 20

const DRAW_POOL = [1,2,3,4,5,6,7,8,9,10] # 1 is 靈; repeat entries to tune weights.
const PEAK_DELAY = .75
const DOUBLE_DELAY = .55
const MATCH_MODAL_DELAY = .9

const FAIR_STOP = [16,18,17,18]
