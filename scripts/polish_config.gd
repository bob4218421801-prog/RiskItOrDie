extends RefCounted
const FOUNDATION_HOLD = 1.5
const FOUNDATION_TIMES = {"condense":.25,"fall":.32,"impact":.18,"suspense":1.2,"stabilize":.65,"pause":.15,"crack":.45,"burst":.25,"silence":1.8,"freeze":.15,"reverse":.4,"rebuild":.3,"reveal":.45,"result":.9}
const NATURAL_DELAY = .6
const NATURAL_HIGHLIGHT = .8
const START_YEAR = 742.0
const FESTIVAL_INTERVAL = 10
const TIANJI_INTERVAL = 25
const PREVIEW_YEARS = 1.0
const CHAMPION_STAGES = [.65,.9,1.5]
const FESTIVAL_NAMES = ["林照", "白行舟", "陸赤嵐", "沈映雪", "顧長青"]
const FESTIVAL_SECTS = ["青嵐門", "藏鋒谷", "赤霄山", "玄霜宗", "太虛劍宗"]
const FESTIVAL_STYLES = [0,2,1,3,3]
const RANK_RANGES = [[0,0],[17,24],[9,16],[4,8],[2,3],[1,1]]
# Rewards indexed by total wins; future items remain inert inventory entries.
const REWARD_TOKENS = [1,2,4,7,11,18]
const REWARD_FRAGMENTS = [0,1,2,4,7,12]
const REWARD_RAW_TIER = [-1,0,1,1,2,3]
const REWARD_RAW_COUNT = [0,1,1,2,2,3]
