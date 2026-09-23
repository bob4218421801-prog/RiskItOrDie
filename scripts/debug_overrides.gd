extends RefCounted
## Only pending next-event directives live here. Completed results are never rerolled.
const KEYS = ["cultivation.result","foundation.result","stone.result","alchemy.heat","alchemy.result","duel.archetype","duel.draw","duel.player_bust","duel.opponent_bust","duel.round","duel.match","duel.treasure","mines.tile","boat.next","race.winner"]
var enabled := OS.is_debug_build()
var active: Dictionary = {}
func arm(key: String, value: Variant) -> void:
 if OS.is_debug_build() and enabled and key in KEYS: active[key] = value
func peek(key: String, fallback: Variant = "") -> Variant:
 return active.get(key,fallback) if enabled and OS.is_debug_build() else fallback
func take(key: String, fallback: Variant = "") -> Variant:
 var value: Variant = peek(key,fallback)
 active.erase(key)
 return value
func clear() -> void: active.clear()
