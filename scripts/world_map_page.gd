extends Control
const T=preload("res://scripts/reference_home_theme.gd")
var host: Control
var model: RefCounted
var kind:=""
var places: Array[Dictionary]=[]
var entries: Array[Button]=[]
var background: TextureRect
func _ready():
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);mouse_filter=MOUSE_FILTER_STOP
func refresh():
 if kind!=model.activity_id: kind=model.activity_id;build()
 for i in range(places.size()):
  var p: Dictionary=places[i];var b: Button=entries[i];var suffix:=""
  b.visible=model.modal.is_empty() and model.sect.chat.is_empty()
  b.disabled=false
  if kind=="sect":
   b.disabled=(p.id=="小師妹" and not model.sect.junior_met) or (p.id=="大師姐" and not model.sect.senior_met)
   if model.sect.C.ENABLE_JUNIOR_REMINDERS and p.id=="小師妹" and not model.sect.reaction.is_empty(): suffix=" · 有话想说"
   if p.id=="俸祿堂": suffix=" · %d期待领"%model.sect.stipends.size()
  elif kind=="opportunities":
   b.disabled=not model.activity_unlocked(p.id)
   suffix="\n免费次数 %d"%model.tickets[p.id] if not b.disabled else "\n筑基后开放"
  elif p.id=="array": suffix="\n剩余 %d 次"%model.array_attempts
  if model.new_features.has(p.id): suffix=" · 新"+suffix
  b.text="";b.tooltip_text=""
  b.set_meta("accessible_name",p.title+suffix)
func build():
 for child in get_children(): remove_child(child);child.queue_free()
 entries.clear();places.clear()
 background=TextureRect.new();background.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;background.size=Vector2(1920,1080);background.mouse_filter=MOUSE_FILTER_IGNORE;add_child(background)
 var file: String={"sect":"zongmen","opportunities":"jiyuan","lobby":"dongfu"}[kind]
 background.texture=load("res://assets/ui_v5/"+file+".png")
 if kind=="sect":
  places=[{"id":"師父","title":"师父","pos":Vector2(220,185),"area":Vector2(220,85)},{"id":"小師妹","title":"小师妹的家","pos":Vector2(1385,475),"area":Vector2(245,90)},{"id":"大師姐","title":"大师姐的家","pos":Vector2(1325,205),"area":Vector2(240,90)},{"id":"俸祿堂","title":"俸禄堂","pos":Vector2(190,475),"area":Vector2(230,80)}]
 elif kind=="opportunities":
  places=[{"id":"sword_race","title":"飞虹剑场","pos":Vector2(90,215),"area":Vector2(95,270)},{"id":"flying_boat","title":"灵舟渡口","pos":Vector2(1135,140),"area":Vector2(95,260)},{"id":"mines","title":"玄晶矿场","pos":Vector2(1270,535),"area":Vector2(95,270)}]
 else:
  places=[{"id":"alchemy","title":"炼丹坊","pos":Vector2(190,142),"area":Vector2(230,75)},{"id":"stone_gambling","title":"解石坊","pos":Vector2(1270,140),"area":Vector2(230,80)},{"id":"materials","title":"材料库","pos":Vector2(1270,475),"area":Vector2(230,80)},{"id":"array","title":"聚灵阵","pos":Vector2(175,480),"area":Vector2(230,80)}]
 var layout: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/ui_v6/hitplates/layout.json"))
 for i in places.size():
  var p: Dictionary=places[i];var id: String=p.id
  var b: Button=make_plate(i,layout[kind][i]);entries.append(b)
  b.set_meta("accessible_name",p.title)
  b.pressed.connect(func(): visit(id))
 var back: Button=make_plate(places.size(),layout[kind][places.size()])
 back.set_meta("accessible_name","返回修炼")
 back.pressed.connect(func(): model.exit_side_activity())
func make_plate(index: int, coords: Array) -> Button:
 var b: Button=preload("res://scripts/art_hit_button.gd").new()
 var factor:=Vector2(1920.0/1672,1080.0/941)
 b.position=Vector2(coords[0],coords[1])*factor;b.size=Vector2(coords[2],coords[3])*factor
 var path: String="res://assets/ui_v6/hitplates/%s_%d"%[kind,index]
 var texture: Texture2D=load(path+".png")
 b.set_hit_texture(texture)
 b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 for state in ["normal","hover","pressed","disabled","focus"]:
  var box:=StyleBoxTexture.new();box.texture=load(path+"_locked.png") if state=="disabled" else texture
  box.modulate_color=Color(1,1,1,0) if state=="normal" else Color(1.13,1.13,1.08) if state in ["hover","focus"] else Color(.86,.9,.86) if state=="pressed" else Color.WHITE
  b.add_theme_stylebox_override(state,box)
 add_child(b);return b
func visit(id: String):
 if not model.modal.is_empty(): return
 if kind=="sect":
  if id=="俸祿堂":
   var total:=0
   for amount in model.sect.stipends: total+=amount
   model.modal={"kind":"stipend_offer","title":"俸禄堂","text":"本期俸禄：%d 灵石\n待领 %d 期 · 累计 %d 灵石\n（俸禄最多累计 %d 期）"%[model.sect.stipends[0] if not model.sect.stipends.is_empty() else 0,model.sect.stipends.size(),total,model.sect.C.STIPEND_CAP]};return
  if not model.sect.present(id,model.attempts):
   model.modal={"kind":"notice","title":"宗门","text":model.sect.away_reason.get(id,"正在闭关，过几次修炼再来。")};return
  if id=="師父": model.sect.talk(model,id)
  else: model.modal={"kind":"npc_visit","title":id,"text":"想找%s做什么？"%id,"id":"npc_visit"}
 elif id=="array":
  model.modal={"kind":"array_purchase","title":"聚灵阵","text":"%d 灵石 · 生效 %d 次\n修炼收益 +20%%\n当前剩余 %d 次"%[model.E.ARRAY_COST,model.E.ARRAY_ATTEMPTS,model.array_attempts],"id":"array_purchase"}
 else:
  if id in model.E.TICKETS and not model.can_pay_entry(id):
   model.modal={"kind":"notice","title":"机缘尚待","text":"暂无免费次数，灵石也不足以入场。"};return
  host.navigate(id)
 model.save_session()
