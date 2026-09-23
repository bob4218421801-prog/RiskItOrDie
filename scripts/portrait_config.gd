extends RefCounted
# Reference aliases only. Files are unmodified user-supplied PNGs.
const IMAGES = {
 "大師姐":{"neutral":"dashijie_neutral.png","smile":"dashijie_smile.png","stern":"dashijie_stern.png","surprised":"dashijie_surprised.png"},
 "小師妹":{"neutral":"xiaoshimei_neutral.png","happy":"xiaoshimei_happy.png","teasing":"xiaoshimei_teasing.png","handsonhips":"xiaoshimei_teasing.png","surprised":"xiaoshimei_surprised.png"}}
const DEFAULTS = {"大師姐":"neutral","小師妹":"happy"}
const LAYOUT = {"大師姐":{"position":Vector2(46,110),"size":Vector2(848,1092)},"小師妹":{"position":Vector2(70,35),"size":Vector2(800,1030)}}
const FALLBACK = {"大師姐":{"happy":"smile","teasing":"smile","angry":"stern","worried":"stern","sad":"neutral"},"小師妹":{"smile":"happy","stern":"teasing","angry":"teasing","worried":"surprised","sad":"happy"}}
const RULES = {
 "大師姐":[["surprised",["……？","竟然","居然","你倒是","我聽得到"]],["stern",["功課","站住","出劍","禁法","別指望","教訓","別以為","別把","回去調息","第一次爆","築基七層","逆轉光陰"]],["smile",["不錯","很好","有進步","確實不大","可惜了","哪一勝","你現在贏了嗎","你終於懂了","不累","所以你第二"]]],
 "小師妹":[["surprised",["？！","欸？","啊？","等等","完了","還真","這都","居然","二十一？","都那樣了"]],["teasing",["別笑","我就知道","我就說","先別笑","面子","耍賴","不准","赴死","吐槽","沒笑","不重要","表情","她自己","好新鮮","第二名","算我慫恿","不想去做功課"]],["happy",["贏啦","來找我","陪我","坐，","不收","很好","打得不錯","師兄！"]]]}
static func emotion(who: String, words: String, context: String = "", explicit: String = "") -> String:
 if not IMAGES.has(who): return ""
 if not explicit.is_empty(): return resolve(who,explicit)
 if who == "小師妹" and words.contains("好吧，這回算我慫恿你的。"):
  return "surprised"
 if who == "小師妹" and words.contains("看見沒，這就叫眼光。"):
  return "teasing"
 for rule in RULES[who]:
  for phrase in rule[1]:
   if words.contains(phrase): return rule[0]
 if who == "大師姐" and context in ["duel","senior","tournament"]: return "stern"
 return DEFAULTS[who]
static func resolve(who: String, mood: String) -> String:
 if not IMAGES.has(who): return ""
 if IMAGES[who].has(mood): return mood
 return FALLBACK[who].get(mood,DEFAULTS[who])
static func path(who: String, mood: String) -> String:
 if not IMAGES.has(who): return ""
 for candidate in [resolve(who,mood),DEFAULTS[who]]+IMAGES[who].keys():
  var resource: String = "res://assets/portraits/"+IMAGES[who][candidate]
  if ResourceLoader.exists(resource): return resource
 return ""
