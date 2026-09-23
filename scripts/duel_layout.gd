extends RefCounted
## Art-space geometry only (1672 x 941). No combat or information rules.
## The four classic layouts restore work/before-latest-duel-update/duel_view.gd.
## Each record is independent: general/ranking must never be a classic fallback.
const SCENE_LAYOUT = {
 "wenjian":"general", "xiaoshimei":"xiaoshimei", "dashijie":"dashijie",
 "zongmendabi":"zongmendabi", "tianjidabi":"tianjidabi"
}
const VARIANTS = {
 "general": {
  "origins":[Vector2(420,125),Vector2(420,515)],
  "profiles":[Rect2(22,8,168,36),Rect2(22,8,168,70)], "sect":Rect2(22,44,168,30),
  "hand":Vector2(207,15), "many_hand":Vector2(25,82), "many_width":760.0,
  "total":Vector2(613,17), "mottos":[Vector2(31,105),Vector2(31,105)],
  "message":Vector2(492,96), "quote":Vector2(478,96),
  "actions":[Rect2(510,765,295,84),Rect2(853,765,305,84)], "button_art":"xiaoshimei",
  "double":Rect2(936,855,300,70), "profile_font":24
 },
 "xiaoshimei": {
  "origins":[Vector2(420,125),Vector2(420,505)],
  "profiles":[Rect2(40,-4,170,52),Rect2(40,-2,170,52)], "sect":Rect2(40,48,170,30),
  "hand":Vector2(207,0), "many_hand":Vector2(62,63), "many_width":670.0,
  "total":Vector2(594,0), "mottos":[Vector2(51,93),Vector2(51,75)],
  "message":Vector2(492,75), "quote":Vector2(478,85),
  "actions":[Rect2(510,765,295,84),Rect2(853,765,305,84)], "button_art":"xiaoshimei",
  "double":Rect2(936,855,300,70), "profile_font":30
 },
 "dashijie": {
  "origins":[Vector2(420,128),Vector2(420,510)],
  "profiles":[Rect2(40,-4,170,52),Rect2(40,-2,170,52)], "sect":Rect2(40,48,170,30),
  "hand":Vector2(207,0), "many_hand":Vector2(62,63), "many_width":670.0,
  "total":Vector2(614,0), "mottos":[Vector2(51,90),Vector2(51,70)],
  "message":Vector2(492,72), "quote":Vector2(478,80),
  "actions":[Rect2(508,731,291,85),Rect2(852,731,296,85)], "button_art":"dashijie",
  "double":Rect2(936,855,300,70), "profile_font":30
 },
 "zongmendabi": {
  "origins":[Vector2(420,122),Vector2(420,514)],
  "profiles":[Rect2(40,-4,170,52),Rect2(40,-2,170,52)], "sect":Rect2(40,48,170,30),
  "hand":Vector2(207,0), "many_hand":Vector2(62,63), "many_width":500.0,
  "total":Vector2(614,0), "mottos":[Vector2(51,96),Vector2(51,66)],
  "message":Vector2(492,78), "quote":Vector2(478,76),
  "actions":[Rect2(511,747,284,83),Rect2(852,747,286,83)], "button_art":"zongmendabi",
  "double":Rect2(936,855,300,70), "profile_font":30
 },
 "tianjidabi": {
  "origins":[Vector2(420,144),Vector2(420,536)],
  "profiles":[Rect2(40,-4,170,52),Rect2(40,-2,170,52)], "sect":Rect2(40,48,170,30),
  "hand":Vector2(207,0), "many_hand":Vector2(62,63), "many_width":670.0,
  "total":Vector2(614,0), "mottos":[Vector2(51,90),Vector2(51,75)],
  "message":Vector2(492,75), "quote":Vector2(478,75),
  "actions":[Rect2(515,766,278,82),Rect2(855,766,292,82)], "button_art":"tianjidabi",
  "double":Rect2(936,855,300,70), "profile_font":30
 }
}
static func for_scene(scene: String) -> Dictionary:
 assert(SCENE_LAYOUT.has(scene), "Unmapped duel background: "+scene)
 return VARIANTS[SCENE_LAYOUT[scene]].duplicate(true)
