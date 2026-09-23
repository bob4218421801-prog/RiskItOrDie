extends Control
const STYLE = preload("res://scripts/narrative_style.gd")
const P = preload("res://scripts/portrait_config.gd")
var model: RefCounted
var portrait: TextureRect
var box: Panel
var nameplate: TextureRect
var recipe_grid: GridContainer
var speaker_label: Label
var body_label: Label
var hint: Label
var choices: HBoxContainer
var current := {}
var source_key := ""
var page := 0
var pages: Array[String] = []
var last_event := ""
var last_who := ""
var last_mood := ""
var shown_path := ""
var transition: Tween
var dismissed := {}
var closing := false
var visibility_tween: Tween
var emotion_cache := {}
var typing_clock:=0.0
func _ready():
 name = "DialogueBox"
 theme = preload("res://scripts/modern_theme.gd").theme()
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter = Control.MOUSE_FILTER_STOP;focus_mode = Control.FOCUS_ALL
 var shade := ColorRect.new();shade.color = Color(0,0,0,.12);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);shade.mouse_filter = Control.MOUSE_FILTER_IGNORE;add_child(shade)
 portrait = TextureRect.new();portrait.position = Vector2(70,35);portrait.size = Vector2(800,1030);portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED;portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE;add_child(portrait)
 box = Panel.new();box.position = Vector2(60,800);box.size = Vector2(1800,255);box.mouse_filter = Control.MOUSE_FILTER_IGNORE;add_child(box)
 var skin:=StyleBoxTexture.new();skin.texture=load("res://assets/ui_v4/dialogue.png");skin.modulate_color=Color(1,1,1,.9);box.add_theme_stylebox_override("panel",skin)
 nameplate=TextureRect.new();nameplate.texture=load("res://assets/ui_v4/nameplate.png");nameplate.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;nameplate.position=Vector2(490,10);nameplate.size=Vector2(330,63);nameplate.mouse_filter=Control.MOUSE_FILTER_IGNORE;box.add_child(nameplate)
 move_child(portrait,get_child_count()-1)
 speaker_label = label(box,Vector2(380,28),Vector2(1360,42),32)
 speaker_label.add_theme_color_override("font_color",Color("3e6758"))
 body_label = label(box,Vector2(380,82),Vector2(1360,138),32);body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;body_label.add_theme_constant_override("line_spacing",7)
 hint = label(box,Vector2(1390,213),Vector2(340,35),22);hint.text = "點擊 / Enter / Space 繼續 ›";hint.add_theme_color_override("font_color",Color("627665"))
 recipe_grid=GridContainer.new();recipe_grid.columns=3;recipe_grid.position=Vector2(206,165);recipe_grid.add_theme_constant_override("h_separation",24);recipe_grid.add_theme_constant_override("v_separation",8);box.add_child(recipe_grid);recipe_grid.hide()
 choices = HBoxContainer.new();choices.alignment=BoxContainer.ALIGNMENT_CENTER;choices.position = Vector2(880,700);choices.size = Vector2(800,75);choices.add_theme_constant_override("separation",20);add_child(choices)
 hide()
func label(parent: Node, pos: Vector2, area: Vector2, pixels: int) -> Label:
 var node := Label.new();node.position = pos;node.size = area;node.add_theme_font_size_override("font_size",pixels);node.mouse_filter = Control.MOUSE_FILTER_IGNORE;parent.add_child(node);return node
func source() -> Dictionary:
 var m: Dictionary = model.modal
 if not m.is_empty():
  if m.get("kind","")=="npc_visit":
   var options: Array=["聊聊"]
   if m.title=="小師妹":
    options.append("演命玉骨")
    if model.sect.duel_taught: options.append("问剑切磋")
   else: options.append("切磋")
   options.append("离开")
   return {"kind":"npc_visit","who":m.title,"text":m.text,"event":"npc_visit","key":str(m),"choice":true,"options":options}
  if m.get("kind","")=="stipend_offer": return {"kind":"stipend_offer","who":"俸禄堂","text":m.text,"event":"stipend","key":str(m),"choice":true,"options":["安稳领取","去试试运气","暂不领取"]}
  if m.get("kind","")=="recipe_select": return {"kind":"recipe_select","who":m.title,"text":m.text,"event":"recipe","key":str(m),"choice":true,"options":["开始炼制","返回"]}
  if m.get("kind","")=="array_purchase": return {"kind":"array_purchase","who":"聚灵阵","text":m.text,"event":"array","key":str(m),"choice":true,"options":["布置聚灵阵","返回"]}
  var who: String = m.get("title","")
  if m.get("kind","") == "dialogue" or who in P.IMAGES:
   return {"kind":"modal","who":who,"text":m.get("text",""),"event":m.get("id",m.get("route","result")),"key":str(m),"choice":m.get("id","") == "junior_close","emotion":m.get("emotion","")}
  if m.get("route","") == "jade_exit": return {"kind":"modal","who":"小師妹","text":m.text,"event":"jade_result","key":str(m),"choice":true,"jade":true}
  if m.get("full_help",false) or m.get("kind","") == "waiting_help": return {}
  var kind: String = m.get("kind","")
  var route: String = m.get("route","")
  var options: Array = []
  if kind == "festival": options = ["參加大比","這次先不參加"]
  elif kind == "blood_arrival": options = ["踏入血煞命局","交出一半灵石"]
  elif route == "repeat_activity": options = [model.repeat_label(),"返回机缘"]
  return {"kind":"modal","who":"系統 · "+who,"text":m.get("text",""),"event":m.get("id","system"),"key":str(m),"choice":not options.is_empty(),"options":options}
 if model.activity_id == "duel" and model.duel != null and not model.duel.story_mode.is_empty() and model.duel.state == "story_dialogue":
  var d = model.duel
  return {"kind":"lesson","who":d.speaker,"text":d.dialogue,"event":"lesson_"+d.story_mode,"key":str(d.get_instance_id())+":"+str(d.cursor)}
 if model.activity_id in ["sect","tournament"] and not model.sect.chat.is_empty():
  var c: Dictionary = model.sect.chat
  return {"kind":"chat","who":c.who,"text":c.pages[c.index],"event":c.id,"key":str(c)}
 if model.activity_id == "jade" and model.blood != null and model.blood.state in ["ready","choice"]:
  var b = model.blood;var key: String = str(b.get_instance_id())+b.message
  if b.message.begins_with("小師妹：") and not dismissed.has(key): return {"kind":"jade","who":"小師妹","text":b.message.trim_prefix("小師妹："),"event":"jade","key":key}
 return {}
func refresh():
 var data := source()
 if data.is_empty():
  source_key = ""
  if visible and not closing:
   closing = true
   if visibility_tween != null: visibility_tween.kill()
   visibility_tween = create_tween()
   visibility_tween.tween_property(self,"modulate:a",0.0,.12)
   visibility_tween.tween_callback(func(): hide();closing = false)
  return
 if closing:
  visibility_tween.kill();closing = false;modulate.a = 1
 var danger: bool=model.activity_id=="blood" or model.modal.get("kind","")=="blood_arrival"
 box.add_theme_stylebox_override("panel",preload("res://scripts/migration_art.gd").skin("dark_dialogue",25) if danger else dialogue_skin())
 hint.modulate=Color("eadacb") if danger else Color.WHITE
 var fresh := not visible;show()
 if fresh: grab_focus();visibility_tween = STYLE.fade_in(self)
 if source_key == data.key:
  if not portrait.visible and not narrative_speaker(current.who): box.add_theme_stylebox_override("panel",preload("res://scripts/migration_art.gd").skin("frame",80))
  return
 current = data;source_key = data.key;page = 0;pages.clear();emotion_cache.clear()
 # Explicit speaker lines in mixed banter get their own page.
 var chunk := ""
 for line in str(data.text).replace("。","。\n").split("\n"):
  if line.is_empty(): continue
  while line.length() > 72:
   if not chunk.is_empty(): pages.append(chunk);chunk = ""
   pages.append(line.left(72));line = line.substr(72)
  if chunk.length()+line.length() > 88 or chunk.count("\n") >= 2 or line.begins_with("你：") or line.begins_with("大師姐：") or line.begins_with("小師妹："):
   if not chunk.is_empty(): pages.append(chunk);chunk = ""
  chunk += ("\n" if not chunk.is_empty() else "")+line
 if not chunk.is_empty(): pages.append(chunk)
 if data.kind in ["recipe_select","array_purchase","stipend_offer"]: pages.assign([str(data.text)])
 if pages.is_empty(): pages.append("")
 update_page()
func update_page():
 var who: String = current.who;var words: String = pages[page]
 for name in ["你","大師姐","小師妹"]:
  if words.begins_with(name+"："): who = name;words = words.trim_prefix(name+"：");break
 speaker_label.text = "你 ·【心想】" if who.contains("心想") else who.trim_prefix("系統 · ")
 speaker_label.add_theme_font_size_override("font_size",25 if speaker_label.text.length()>8 else 30)
 typing_clock=0;body_label.visible_characters=0
 body_label.text = words;body_label.add_theme_color_override("font_color",Color("66766a") if who.contains("心想") else Color("30463f"))
 if model.activity_id=="blood" or model.modal.get("kind","")=="blood_arrival": body_label.add_theme_color_override("font_color",Color("f0dac9"))
 set_portrait(who,words)
 speaker_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;speaker_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 choices.alignment=BoxContainer.ALIGNMENT_CENTER
 if portrait.visible or narrative_speaker(who):
  body_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT;body_label.vertical_alignment=VERTICAL_ALIGNMENT_TOP
  box.position=Vector2(60,800);box.size=Vector2(1800,255)
  nameplate.position=Vector2(490,10);nameplate.size=Vector2(330,63)
  speaker_label.position=Vector2(510,14);speaker_label.size=Vector2(290,50)
  body_label.position=Vector2(490,82);body_label.size=Vector2(1250,138);body_label.add_theme_font_size_override("font_size",32)
  hint.position=Vector2(1390,213);hint.size=Vector2(340,35);hint.add_theme_color_override("font_color",Color("627665"))
  choices.position=Vector2(800,700);choices.size=Vector2(1000,75)
 else:
  body_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER if words.length()<45 else HORIZONTAL_ALIGNMENT_LEFT;body_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
  box.position=Vector2(460,270);box.size=Vector2(1000,540)
  box.add_theme_stylebox_override("panel",preload("res://scripts/migration_art.gd").skin("frame",80))
  nameplate.position=Vector2(335,65);nameplate.size=Vector2(330,63)
  speaker_label.position=Vector2(355,69);speaker_label.size=Vector2(290,50)
  body_label.position=Vector2(110,165);body_label.size=Vector2(780,210);body_label.add_theme_font_size_override("font_size",28);body_label.add_theme_color_override("font_color",Color("f0eadb"))
  hint.position=Vector2(370,425);hint.size=Vector2(500,35);hint.add_theme_color_override("font_color",Color("c3ccbe"))
  choices.position=Vector2(560,670);choices.size=Vector2(800,75)
 body_label.visible=current.kind!="recipe_select";recipe_grid.visible=not body_label.visible
 for child in recipe_grid.get_children(): recipe_grid.remove_child(child);child.queue_free()
 if recipe_grid.visible:
  var recipe: int=model.modal.get("recipe",0)
  var entries: Array=["材料","需要","持有"]
  for i in range(5):
   if model.E.RECIPES[recipe][i]>0: entries.append_array([model.E.MATERIAL_NAMES[i],str(model.E.RECIPES[recipe][i]),str(model.materials[i])])
  entries.append_array(["灵石费用","",str(model.E.RECIPE_COST[recipe])])
  for i in entries.size():
   var cell:=preload("res://scripts/migration_art.gd").label(entries[i],26);cell.custom_minimum_size=Vector2([200,120,220][i%3],34);cell.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT if i%3==0 else HORIZONTAL_ALIGNMENT_RIGHT
   if i<3: cell.add_theme_color_override("font_color",Color("c0cabb"))
   recipe_grid.add_child(cell)
 for child in choices.get_children(): choices.remove_child(child);child.queue_free()
 var selecting: bool = current.get("choice",false) and page == pages.size()-1
 hint.visible = not selecting
 if selecting:
  var options: Array = current.get("options",["再玩一局","回宗門"] if current.get("jade",false) else ["就是來找你的","順便而已"])
  for i in range(options.size()):
   var index := i;var b := Button.new();b.text = options[i];b.custom_minimum_size = Vector2(310 if model.modal.get("kind","")=="blood_arrival" else 245 if current.kind=="stipend_offer" else 220,72);preload("res://scripts/reference_home_theme.gd").small(b);b.add_theme_font_size_override("font_size",28);choices.add_child(b)
   if current.kind=="recipe_select" and index==0: b.disabled=not model.can_start_recipe(int(model.modal.get("recipe",0)))
   if current.kind=="array_purchase" and index==0: b.disabled=model.array_attempts>0 or model.spirit_stones<model.E.ARRAY_COST
   if current.kind=="stipend_offer" and index<2: b.disabled=model.sect.stipends.is_empty()
   b.pressed.connect(func():
    if current.kind=="stipend_offer":
     model.modal.clear()
     if index<2: model.sect.stipend(model,index==1)
     model.save_session();return
    if current.kind=="npc_visit":
     var choice: String=options[index];var npc: String=current.who;model.modal.clear()
     if choice=="聊聊": model.sect.talk(model,npc)
     elif choice=="演命玉骨": model.sect.start_jade(model)
     elif choice=="问剑切磋": model.sect.start_junior_spar(model)
     elif choice=="切磋": model.sect.start_senior(model)
     model.save_session();return
    if current.kind=="recipe_select":
     var recipe: int=model.modal.get("recipe",0);model.modal.clear()
     if index==0: model.start_recipe(recipe)
     model.save_session();return
    if current.kind=="array_purchase":
     model.modal.clear()
     if index==0: model.buy_array()
     model.save_session();return
    if model.modal.get("kind","")=="blood_arrival" and index==1: model.surrender_blood();return
    if index == 0: model.result_secondary()
    else: model.acknowledge_modal())
 choices.visible = selecting
func set_portrait(who: String, words: String):
 var event: String = current.event
 if who.begins_with("你"):
  portrait.hide();return
 if not P.IMAGES.has(who): portrait.hide();last_who = "";return
 portrait.position = Vector2(-65,420);portrait.size = Vector2(585,1000)
 var mood: String = emotion_cache.get(who,P.emotion(who,str(current.text),current.get("context",""),current.get("emotion","")))
 emotion_cache[who] = mood
 if event == last_event and who == last_who and mood == P.DEFAULTS[who] and not last_mood.is_empty(): mood = last_mood
 var path := P.path(who,mood);portrait.show()
 if path.is_empty(): portrait.hide();return
 if path != shown_path:
  if transition != null: transition.kill()
  var original: Texture2D = load(path)
  var crop := AtlasTexture.new();crop.atlas = original
  crop.region = Rect2(Vector2.ZERO,Vector2(original.get_width(),original.get_height()*.60))
  portrait.texture = crop;portrait.modulate = Color(1,1,1,0)
  transition = create_tween()
  transition.tween_property(portrait,"modulate",Color.WHITE,.18)
 else: portrait.modulate = Color.WHITE
 shown_path = path;last_who = who;last_mood = mood;last_event = event
func advance_page():
 if not visible or closing: return
 if body_label.visible_ratio<1.0: body_label.visible_characters=-1;return
 if choices.visible: return
 if page+1 < pages.size(): page += 1;update_page();return
 match current.kind:
  "modal": model.acknowledge_modal()
  "lesson": model.duel_action("story_next")
  "chat": model.sect.next_chat(model)
  "jade": dismissed[current.key] = true
 model.save_session.call_deferred()
 refresh()
func _gui_input(event):
 if event is InputEventKey and event.echo: return
 if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or event.is_action_pressed("ui_accept"):
  accept_event();advance_page()

func _process(delta: float):
 if visible and body_label.visible_characters>=0:
  typing_clock+=delta
  body_label.visible_characters=int(typing_clock*42)

func dialogue_skin() -> StyleBoxTexture:
 var s:=StyleBoxTexture.new();s.texture=load("res://assets/ui_v4/dialogue.png");s.modulate_color=Color(1,1,1,.9);return s

func narrative_speaker(who: String) -> bool:
 return who.begins_with("你") or who=="師父" or who in P.IMAGES
