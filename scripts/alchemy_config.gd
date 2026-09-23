extends RefCounted
# All durations in seconds, heat and pressure normalized. No random explosions.
const CENTER = .53
const WIDTHS = [0.1488, 0.12896, 0.11408, 0.0992, 0.08432]
const RISE = [0.57915, 0.62205, 0.66495, 0.7293, 0.7722]
const FALL = [0.429, 0.45045, 0.49335, 0.5148, 0.5577]
const FORM_SECONDS = [7.0,8.0,9.0,10.0,11.0]
const DRIFT = [0.0,.01,.015,.02,.025]
const OVERHEAT = .83
const WARNING = .70
const EXPLODE_SECONDS = [2.31,2.15,2.0,1.85,1.69]
const PRESSURE_RECOVERY = .45
const EXTRA_WIDTH = .88
const EXTRA_SPEED = 1.25
const EXTRA_PRESSURE = 1.15
const STEP = .01
