extends Control
# Coordinates share the supplied 1672 x 941 illustration canvas; hit areas scale with it.
const ART="res://assets/duel_v7/"
const T=preload("res://scripts/reference_home_theme.gd")
const LAYOUT=preload("res://scripts/duel_layout.gd")
var layout: Dictionary={}
var opponent_sect_label: Label
const HIT=preload("res://scripts/art_hit_button.gd")
var model: RefCounted
var textures: Dictionary={}
var background: TextureRect
var table: Control
var opponent_area: Control
var player_area: Control
var upper: Control
var lower: Control
var upper_total: Label
var lower_total: Label
var opponent_profile: Label
var player_profile: Label
var draw_button: Button
var stand_button: Button
var double_button: Button
var next_button: Button
var leave_button: Button
var skill_buttons: Array[Button]=[]
var skill_states: Array[Label]=[]
var peek_card: TextureRect
var log_text: RichTextLabel
var message: Label
var arrival: Panel
var arrival_text: Label
var refuse: Button
var escape: Button
var accept_button: Button
var clock:=0.0
var hand_key:=""
var seen_score: Array=[0,0]
var flight_from_score: Array=[0,0]
var sword_flight:=0.0
var last_duel: RefCounted
var theme_id:=""
var effect_canvas: Control
var button_theme:=""
var opponent_motto: Label
var player_motto: Label
var player_quote: Label
var notice_queue: Array[String]=[]
var notice_left:=0.0
var previous_log: Array=[]
const BACKGROUNDS={
 "wenjian":[preload("res://assets/duel_backgrounds/wenjian.png"),preload("res://assets/duel_backgrounds/wenjian1.png")],
 "xiaoshimei":[preload("res://assets/duel_backgrounds/xiaoshimei.png"),preload("res://assets/duel_backgrounds/xiaoshimei1.png")],
 "dashijie":[preload("res://assets/duel_backgrounds/dashijie.png"),preload("res://assets/duel_backgrounds/dashijie1.png")],
 "zongmendabi":[preload("res://assets/duel_backgrounds/zongmendabi.png"),preload("res://assets/duel_backgrounds/zongmendabi1.png")],
 "tianjidabi":[preload("res://assets/duel_backgrounds/tianjidabi.png"),preload("res://assets/duel_backgrounds/tianjidabi1.png")]
}

func tex(key: String) -> Texture2D:
 if not textures.has(key): textures[key]=load(ART+key+".png")
 return textures[key]
func picture(key: String, rect: Rect2, parent: Node=self) -> TextureRect:
 var image:=TextureRect.new();image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;image.texture=tex(key);image.position=rect.position;image.size=rect.size
 image.stretch_mode=TextureRect.STRETCH_SCALE;image.mouse_filter=Control.MOUSE_FILTER_IGNORE;parent.add_child(image);return image
func label_at(words: String, rect: Rect2, font: int=24, parent: Node=self, dark: bool=false) -> Label:
 var label:=Label.new();label.text=words;label.position=rect.position;label.size=rect.size;label.mouse_filter=Control.MOUSE_FILTER_IGNORE
 label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 label.add_theme_font_override("font",T.FONT.TITLE);label.add_theme_font_size_override("font_size",font);label.add_theme_color_override("font_color",Color("2c433e") if dark else Color("fff5db"));parent.add_child(label);return label
func panel(rect: Rect2, parent: Node=self) -> Panel:
 var p:=Panel.new();p.position=rect.position;p.size=rect.size;p.mouse_filter=Control.MOUSE_FILTER_IGNORE
 p.add_theme_stylebox_override("panel",preload("res://scripts/migration_art.gd").skin("frame",32));parent.add_child(p);return p
func button(words: String, rect: Rect2, callback: Callable, art: String="", parent: Node=self) -> Button:
 var b=HIT.new();b.text=words;b.position=rect.position;b.size=rect.size;b.add_theme_font_override("font",T.FONT.TITLE);b.add_theme_font_size_override("font_size",25)
 if art.is_empty(): T.small(b)
 else:
  b.set_hit_texture(tex(art))
  for state in ["normal","hover","pressed","disabled","focus"]:
   var style:=StyleBoxTexture.new();style.texture=tex(art)
   style.modulate_color=Color(1.3,1.25,1.1) if state in ["hover","focus"] else (Color(.8,.8,.75) if state=="pressed" else (Color(.5,.55,.55) if state=="disabled" else Color.WHITE))
   b.add_theme_stylebox_override(state,style)
 b.tooltip_text="";b.pressed.connect(func():
  if model.modal.is_empty() and model.result_delay<=0: callback.call();model.sfx_event.emit("ui_confirm");refresh())
 parent.add_child(b);return b
func _ready():
 name="SwordDuelArena";position=Vector2.ZERO;size=Vector2(1672,941);scale=Vector2(1920.0/1672,1080.0/941);mouse_filter=Control.MOUSE_FILTER_STOP
 scale=Vector2.ONE*minf(1920.0/1672,1080.0/941);position=(Vector2(1920,1080)-size*scale)*.5
 background=picture("xiaoshimeidapai",Rect2(0,0,1672,941))
 background.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 table=Control.new();table.size=size;table.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(table)
 opponent_profile=label_at("",Rect2(460,121,170,52),30,table)
 opponent_sect_label=label_at("",Rect2(460,173,170,30),18,table)
 player_profile=label_at("你",Rect2(460,503,170,52),30,table)
 upper_total=label_at("",Rect2(1014,125,165,55),30,table)
 lower_total=label_at("",Rect2(1014,505,165,55),30,table)
 upper=Control.new();upper.position=Vector2(627,125);upper.size=Vector2(250,179);upper.mouse_filter=Control.MOUSE_FILTER_IGNORE;table.add_child(upper)
 lower=Control.new();lower.position=Vector2(627,505);lower.size=Vector2(250,179);lower.mouse_filter=Control.MOUSE_FILTER_IGNORE;table.add_child(lower)
 opponent_motto=label_at("剑意清灵\n不胜不休",Rect2(471,218,140,72),23,table)
 player_motto=label_at("心有凌云\n剑指山海",Rect2(471,580,140,85),23,table)
 message=label_at("",Rect2(912,200,285,88),22,table)
 player_quote=label_at("剑心既定\n纵有千山，亦可一越",Rect2(898,590,302,80),22,table)
 picture("scroll",Rect2(1292,24,370,874),table)
 label_at("剑法秘卷",Rect2(1340,104,270,53),34,table,true)
 label_at("感悟剑道 · 逆天改命",Rect2(1340,153,270,28),18,table,true)
 var ys=[200,284,368,452,672]
 for i in range(5):
  var index: int=i
  var b=button(model.sect.C.SKILLS[i],Rect2(1350,ys[i],245,47),func():
   model.duel_skill(index,not model.duel.skill_available(index) and not model.duel.skill_used.has(index)),"",table)
  b.add_theme_font_size_override("font_size",24);skill_buttons.append(b)
  skill_states.append(label_at("",Rect2(1352,ys[i]+47,240,26),18,table,true))
 label_at("下一张",Rect2(1372,536,70,30),19,table,true)
 peek_card=picture("card_0",Rect2(1442,533,79,127),table)
 label_at("洞察\n天机\n预见\n一线",Rect2(1527,544,62,116),18,table,true)
 label_at("天道无常，剑心不灭",Rect2(1340,760,275,32),18,table,true)
 log_text=RichTextLabel.new();log_text.position=Vector2(48,420);log_text.size=Vector2(316,285);log_text.scroll_active=false;log_text.mouse_filter=Control.MOUSE_FILTER_IGNORE
 log_text.add_theme_font_size_override("normal_font_size",22);log_text.add_theme_color_override("default_color",Color("fff3d3"));log_text.add_theme_color_override("font_outline_color",Color("172a30"));log_text.add_theme_constant_override("outline_size",5);table.add_child(log_text)
 draw_button=button("",Rect2(510,765,295,84),func():model.duel_action("draw"),"draw",table)
 stand_button=button("",Rect2(853,765,305,84),func():model.duel_action("stand"),"stand",table)
 double_button=button("孤注一剑",Rect2(936,855,300,70),func():model.duel_action("double"),"double",table)
 double_button.add_theme_font_size_override("font_size",30)
 for mode in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:double_button.add_theme_color_override(mode,Color("fff2c9"))
 next_button=button("下一局",Rect2(510,855,325,67),func():model.duel_action("next"),"",table)
 leave_button=button("返回",Rect2(510,855,325,67),func():model.exit_side_activity(),"",table)
 button("规则说明",Rect2(42,835,176,53),func():model.show_help("duel"),"",table)
 arrival=panel(Rect2(435,230,794,468))
 arrival_text=label_at("",Rect2(40,36,714,295),28,arrival)
 accept_button=button("接下剑帖",Rect2(26,352,237,74),func():model.duel_action("accept"),"",arrival)
 refuse=button("婉拒",Rect2(280,352,237,74),func():model.duel_action("refuse"),"",arrival)
 escape=button("避战",Rect2(534,352,237,74),func():model.duel_action("escape"),"",arrival)
 opponent_area=Control.new();opponent_area.name="OpponentArea";opponent_area.size=Vector2(840,215);opponent_area.mouse_filter=Control.MOUSE_FILTER_IGNORE;table.add_child(opponent_area)
 player_area=Control.new();player_area.name="PlayerArea";player_area.size=Vector2(840,215);player_area.mouse_filter=Control.MOUSE_FILTER_IGNORE;table.add_child(player_area)
 for node in [opponent_profile,opponent_sect_label,upper,upper_total,opponent_motto,message]:node.reparent(opponent_area,false)
 for node in [player_profile,lower,lower_total,player_motto,player_quote]:node.reparent(player_area,false)
 effect_canvas=Control.new();effect_canvas.size=size;effect_canvas.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(effect_canvas);effect_canvas.draw.connect(paint_effects)
 refresh()
func scene_key(d) -> String:
 if d.fair and model.tournament!=null: return "tianjidabi" if model.tournament.kind=="tianji" else "zongmendabi"
 if d.senior or d.story_mode=="senior" or d.custom_name.contains("大師姐"): return "dashijie"
 if d.source=="junior" or d.story_mode=="junior": return "xiaoshimei"
 return "wenjian"
func fill_hand(row: Control, hand: Array, hidden: bool):
 for c in row.get_children():row.remove_child(c);c.queue_free()
 var w:=108.0;var step:=116.0;var area:=250.0;var height:=174.0
 if hand.size()>2: area=layout.many_width;w=76;step=minf(90,(area-w)/maxi(1,hand.size()-1));height=120
 var width: float=w+step*maxi(0,hand.size()-1)
 for i in range(hand.size()):
  var value: int=0 if hidden and i==1 else clampi(hand[i],1,10)
  picture("card_"+str(value),Rect2((area-width)*.5+i*step,0,w,height),row)
func apply_layout(d):
 opponent_area.position=layout.origins[0];player_area.position=layout.origins[1]
 upper.position=layout.many_hand if d.opponent_hand.size()>2 else layout.hand
 lower.position=layout.many_hand if d.player_hand.size()>2 else layout.hand
 for i in range(2):
  var profile: Label=[opponent_profile,player_profile][i]
  profile.position=layout.profiles[i].position;profile.size=layout.profiles[i].size
  profile.add_theme_font_size_override("font_size",layout.profile_font)
 opponent_sect_label.position=layout.sect.position;opponent_sect_label.size=layout.sect.size
 opponent_motto.position=layout.mottos[0];player_motto.position=layout.mottos[1]
 upper_total.position=layout.total;lower_total.position=layout.total
 message.position=layout.message;player_quote.position=layout.quote
 double_button.position=layout.double.position;double_button.size=layout.double.size
 # Theme identity includes geometry, even where two themes use the same button art.
 if button_theme!=theme_id:
  button_theme=theme_id
  for i in range(2):
   var b: Button=[draw_button,stand_button][i]
   b.position=layout.actions[i].position;b.size=layout.actions[i].size
   var texture:=tex(("draw_" if i==0 else "stand_")+layout.button_art);b.set_hit_texture(texture)
   for state in ["normal","hover","pressed","disabled","focus"]:b.get_theme_stylebox(state).texture=texture

func refresh():
 visible=model.activity_id=="duel" and model.duel!=null
 if not visible:return
 var d=model.duel
 if d!=last_duel: last_duel=d;hand_key="";seen_score=[0,0];notice_queue.clear();previous_log.clear();notice_left=0;log_text.text="";sword_flight=0
 var pre: bool=d.state=="arrival" or (not d.story_mode.is_empty() and d.round_index==0)
 theme_id=scene_key(d);background.texture=BACKGROUNDS[theme_id][0 if pre else 1]
 layout=LAYOUT.for_scene(theme_id)
 apply_layout(d)
 table.visible=not pre;arrival.visible=d.state=="arrival" and model.modal.is_empty()
 opponent_motto.visible=d.opponent_hand.size()<=2;player_motto.visible=d.player_hand.size()<=2;player_quote.visible=d.player_hand.size()<=2
 opponent_sect_label.visible=d.opponent_hand.size()<=2
 message.visible=d.opponent_hand.size()<=2 and theme_id!="zongmendabi"
 opponent_profile.text=d.opponent_name();opponent_sect_label.text=d.opponent_sect();player_profile.text="你"
 upper_total.text=str(d.opponent) if d.revealed or d.peeked else (str(d.opponent_hand[0]) if not d.opponent_hand.is_empty() else "—")+" / ?"
 lower_total.text=str(d.player)
 var key=theme_id+str(d.player_hand)+str(d.opponent_hand)+str(d.revealed)+str(d.peeked)
 if key!=hand_key:hand_key=key;fill_hand(upper,d.opponent_hand,not (d.revealed or d.peeked));fill_hand(lower,d.player_hand,false)
 var top_visible: bool=not d.fair and (not d.story_mode.is_empty() or d.persistent_top_peek() or d.peek_visible)
 peek_card.texture=tex("card_"+str(maxi(0,d.exposed_top()) if top_visible else 0))
 for i in range(5):
  var available: bool=d.skill_available(i)
  var count: int=model.sect.inventory.get(model.sect.C.CARDS[i],0)
  var status: String="可用" if available else "未解锁"
  if available and i in [1,2]:status="自动触发" if i==1 else "孤注时自动"
  if available and i==3:status="持续观顶牌" if d.persistent_top_peek() else ("已展露" if d.peek_visible else "可用 · 观下一张")
  if available and i in [0,3,4] and not d.can_skill(i) and not (i==3 and (d.peek_visible or d.persistent_top_peek())):status="不可用 · 等待时机"
  if d.skill_used.has(i):status="已使用"
  elif not available and count>0:status="用符 × %d" % count
  if d.fair:status="大比禁法"
  if not d.story_mode.is_empty():status="教学示范" if d.story_mode=="senior" else "未解锁"
  skill_states[i].text=status
  skill_buttons[i].disabled=d.fair or not d.story_mode.is_empty() or not model.modal.is_empty() or d.skill_pause>0 or d.skill_used.has(i) or ((not d.can_skill(i) or (i==3 and d.persistent_top_peek())) if available else (count==0 or d.state!=("round_result" if i==4 else "playing")))
  skill_buttons[i].modulate=Color.WHITE if available or count>0 else Color(.7,.72,.7)
 if previous_log!=d.battle_log:
  var overlap:=0
  for count in range(mini(previous_log.size(),d.battle_log.size()),0,-1):
   if previous_log.slice(previous_log.size()-count)==d.battle_log.slice(0,count): overlap=count;break
  for entry in d.battle_log.slice(overlap):
   if notice_queue.is_empty() or notice_queue.back()!=entry: notice_queue.append(entry)
  previous_log=Array(d.battle_log).duplicate()
 if seen_score!=Array(d.score):flight_from_score=seen_score.duplicate();seen_score=Array(d.score);sword_flight=0.85
 draw_button.disabled=d.state!="playing" or d.skill_pause>0 or d.player==21
 stand_button.disabled=d.state!="playing" or d.skill_pause>0
 if not d.story_mode.is_empty():draw_button.disabled=draw_button.disabled or d.expected!="draw";stand_button.disabled=stand_button.disabled or d.expected!="stand"
 double_button.disabled=not d.can_double();next_button.visible=d.state=="round_result";leave_button.visible=d.state=="result" and not model.presentation_enabled
 message.text=d.skill_notice if d.skill_time>0 else d.message
 if arrival.visible:
  arrival_text.text=d.opponent_sect()+" · "+d.opponent_name()+"\n【"+(d.NPC.NPCS[d.npc_id].style if d.npc_id>=0 else d.D.ARCHETYPES[d.archetype])+"】\n\n"+model.duel_stakes(d.archetype)
  var friendly: bool=d.source in ["junior","senior"]
  refuse.visible=not (d.fair or friendly);escape.visible=refuse.visible
  accept_button.position.x=278 if d.fair or friendly else 26
  accept_button.text="开始问剑" if d.fair or friendly else "接下剑帖"
  if d.fair:arrival_text.text=model.tournament.title()+"\n\n下一位："+d.opponent_name()+"\n\n先取三筹获胜 · 禁用神通与神通符\n胜负记录在本次大比战绩中。"
  elif friendly:arrival_text.text=d.opponent_name()+" · 同门切磋\n\n先取三筹获胜。\n这场切磋不收灵石，不计外出问剑战绩。"
  else:
   refuse.text="婉拒\n-%d 修为"%mini(model.cultivation,int(ceil(model.requirement()*d.D.REFUSAL[d.archetype])))
   refuse.add_theme_font_size_override("font_size",21)
   escape.text="避战 · %d 灵石"%d.D.ESCAPE[d.archetype]
 effect_canvas.queue_redraw()
func _process(delta: float):
 if visible:
  notice_left=maxf(0,notice_left-delta)
  if notice_left<=0 and not notice_queue.is_empty():
   var batch: Array[String]=[]
   for i in range(mini(3,notice_queue.size())): batch.append(notice_queue.pop_front())
   log_text.text="\n".join(batch);notice_left=3.0
  log_text.modulate.a=minf(1,notice_left/.6)
 clock+=delta;sword_flight=maxf(0,sword_flight-delta)
 if visible and is_instance_valid(effect_canvas):
  double_button.self_modulate=Color(1.08+.09*sin(clock*3),1.04,.92) if not double_button.disabled else Color.WHITE
  effect_canvas.queue_redraw()
func paint_effects():
 if not visible or not table.visible:return
 var d=model.duel
 for side in range(2):
  for i in range(d.score[side]):
   var destination:=Vector2(398,(519 if side==0 else 135)+i*31)
   var progress:=1.0-sword_flight/.85
   var point: Vector2=Vector2(835+i*22,400).lerp(destination,1-pow(1-progress,3)) if i>=flight_from_score[side] and sword_flight>0 else destination
   for offset in [Vector2(-2,0),Vector2(2,0),Vector2(0,-2),Vector2(0,2)]:
    effect_canvas.draw_texture_rect(tex("sword"),Rect2(point+offset,Vector2(24,65)),false,Color("132833"))
   effect_canvas.draw_texture_rect(tex("sword"),Rect2(point,Vector2(24,65)),false,Color(1.7,1.25,.55))
 var power: String=d.feedback if not d.story_mode.is_empty() and d.state in ["story_effect","rewind_hold"] else (d.skill_effect if d.skill_pause>0 else "")
 var foresight: bool=power=="foresight"
 if foresight:power="probe"
 if power in ["probe","shield","destiny","rewind"]:
  var center:=Vector2(830,403)
  if power in ["probe","shield"]:center=Vector2(752,592 if d.effect_target=="player" else 212)
  var wh:=Vector2(410,342) if power in ["probe","shield"] else Vector2(550,460)
  if foresight:center=Vector2(1480,591);wh=Vector2(210,175)
  var pulse:=1.0+.035*sin(clock*4);wh*=pulse
  if power=="rewind":
   for echo in range(3):
    var phase: float=fmod(clock*.7+echo*.33,1.0)
    var echo_size: Vector2=wh*(1.3-phase*.55)
    effect_canvas.draw_set_transform(center,-phase*.18)
    effect_canvas.draw_texture_rect(tex(power),Rect2(-echo_size*.5,echo_size),false,Color(.65,.9,1,.16*(1-phase)))
   effect_canvas.draw_set_transform(Vector2.ZERO)
  effect_canvas.draw_set_transform(center,-.08*sin(clock*2) if power=="rewind" else 0)
  effect_canvas.draw_texture_rect(tex(power),Rect2(-wh*.5,wh),false);effect_canvas.draw_set_transform(Vector2.ZERO)
 elif d.feedback in ["peak","natural","destiny"] and d.feedback_left>0:
  effect_canvas.draw_texture_rect(tex("peak"),Rect2(575,285,500,416),false)
 elif d.feedback=="draw" and d.feedback_left>0:
  var y:=550 if d.last_actor=="player" else 165
  effect_canvas.draw_texture_rect(tex("slash"),Rect2(582,y,365,175),false,Color(1,1,1,minf(1,d.feedback_left*3)))
 if not double_button.disabled:
  effect_canvas.draw_texture_rect(tex("slash"),double_button.get_rect(),false,Color(1,1,1,.18+.08*sin(clock*3)))
