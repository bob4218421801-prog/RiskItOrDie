extends Translation
## Display-only compatibility for legacy Traditional text and dynamic numbers.
## Model strings, item IDs, saves, dialogue matching and RNG remain untouched.
var terms: Dictionary = {}
var characters: Dictionary = {}
var phrases: Dictionary = {}
var longest := 1
var cache: Dictionary = {}
func configure(tag: String) -> void:
 locale = "zh_CN" if tag == "zh-Hans" else "zh_TW"
 terms = JSON.parse_string(FileAccess.get_file_as_string("res://localization/"+tag+".json"))
 var prefix := "TS" if tag == "zh-Hans" else "ST"
 characters = JSON.parse_string(FileAccess.get_file_as_string("res://localization/"+prefix+"Characters.json"))
 phrases = JSON.parse_string(FileAccess.get_file_as_string("res://localization/"+prefix+"Phrases.json"))
 for key in phrases: longest = maxi(longest,key.length())
func _get_message(source: StringName, _context: StringName) -> StringName:
 var value := String(source)
 if terms.has(value): return StringName(terms[value])
 if cache.has(value): return cache[value]
 var result := ""
 var i := 0
 while i < value.length():
  var count := mini(longest,value.length()-i)
  var matched := false
  while count > 1:
   var part := value.substr(i,count)
   if phrases.has(part):
    result += phrases[part];i += count;matched = true;break
   count -= 1
  if not matched:
   result += characters.get(value[i],value[i]);i += 1
 if cache.size() > 8192: cache.clear()
 cache[value] = StringName(result)
 return StringName(result)
