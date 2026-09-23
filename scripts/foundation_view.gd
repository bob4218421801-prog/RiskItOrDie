extends Control
const C=preload("res://scripts/balance.gd")
const R=preload("res://scripts/foundation_rules.gd")
const A=preload("res://scripts/migration_art.gd")
const FONT=preload("res://scripts/ui_typography.gd")
var model: RefCounted
var visual_time:=0.0
var cells: Array=[]
var heading: Label
var top: Label
var tendency: Label
var estimate: Label
var bonus: Label
var risk: Label
var hint: Label
var detail: Label
var stop_button: Button
var push_button: Button
var start_button: Button
var portrait: TextureRect
var result_panel: Panel
var result_title: Label
var result_body: Label
var preview_panel: Panel
func label_at(value: String,rect: Rect2,pixels: int=28) -> Label:
 var l:=A.label(value,pixels);l.position=rect.position;l.size=rect.size;l.mouse_filter=MOUSE_FILTER_IGNORE;add_child(l);return l
func button(value: String,rect: Rect2,callback: Callable) -> Button:
 var b=preload("res://scripts/art_hit_button.gd").new();b.text=value;b.position=rect.position;b.size=rect.size;b.theme=A.T.theme();b.add_theme_font_size_override("font_size",30)
 b.set_hit_texture(load("res://assets/ui_v3/reference_home/small_normal.png"));b.mouse_default_cursor_shape=CURSOR_POINTING_HAND;b.pressed.connect(func():
  if model.modal.is_empty():callback.call();model.save_session();refresh())
 add_child(b);return b
func panel(rect: Rect2) -> Panel:
 var p:=Panel.new();p.position=rect.position;p.size=rect.size;p.mouse_filter=MOUSE_FILTER_IGNORE
 var box:=StyleBoxFlat.new();box.bg_color=Color(.035,.105,.115,.91);box.border_color=Color("8f845b");box.set_border_width_all(1);box.set_corner_radius_all(12);p.add_theme_stylebox_override("panel",box);add_child(p);return p
func _ready():
 size=Vector2(1920,1080);mouse_filter=MOUSE_FILTER_STOP
 var bg:=TextureRect.new();bg.texture=load("res://assets/foundation_v8/background.png");bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;bg.size=size;bg.mouse_filter=MOUSE_FILTER_IGNORE;bg.show_behind_parent=true;add_child(bg)
 label_at("筑 基",Rect2(88,62,460,85),68).add_theme_font_override("font",FONT.TITLE)
 label_at("凝天地灵气 · 铸长生道基",Rect2(92,157,490,60),25)
 heading=label_at("九宫灵纹铸基",Rect2(650,68,680,75),48);heading.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;heading.add_theme_font_override("font",FONT.TITLE)
 panel(Rect2(585,172,1190,62));top=label_at("",Rect2(620,184,1100,46),27)
 button("?",Rect2(1790,174,65,60),func():model.show_help("foundation"))
 portrait=TextureRect.new();portrait.texture=load("res://assets/characters/char01/char01_cultivation_calm.png");portrait.position=Vector2(10,295);portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;portrait.size=Vector2(570,590);portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;portrait.mouse_filter=MOUSE_FILTER_IGNORE;add_child(portrait)
 label_at("九纹归一 · 道基乃成",Rect2(105,859,470,50),27)
 for i in range(9):
  var b=preload("res://scripts/foundation_rune_button.gd").new();b.position=Vector2(632+(i%3)*220,265+(i/3)*205);b.size=Vector2(194,194);add_child(b);cells.append(b)
  var n:=i;b.pressed.connect(func():
   if model.modal.is_empty() and model.foundation!=null:model.foundation.toggle(n);model.save_session();refresh())
 preview_panel=panel(Rect2(1335,272,480,594))
 var preview_heading=label_at("道 基 观 象",Rect2(1368,295,420,50),34)
 tendency=label_at("",Rect2(1368,367,412,55),32)
 estimate=label_at("",Rect2(1368,432,412,90),29)
 bonus=label_at("",Rect2(1368,534,412,52),26)
 risk=label_at("",Rect2(1368,590,412,94),25)
 detail=label_at("",Rect2(1368,695,410,150),23)
 for label in [preview_heading,tendency,estimate,bonus,risk,detail]:
  label.position-=preview_panel.position;label.reparent(preview_panel,false)
 hint=label_at("",Rect2(587,899,1230,48),25);hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 push_button=button("重铸未锁定",Rect2(650,953,480,82),func():model.foundation.reforge())
 stop_button=button("筑基定型",Rect2(1245,953,480,82),func():model.foundation.stop())
 var gold: Texture2D=load("res://assets/duel_v7/double.png")
 stop_button.set_hit_texture(gold)
 for mode in ["normal","hover","pressed","disabled"]:
  var skin:=StyleBoxTexture.new();skin.texture=gold;skin.modulate_color=Color(.42,.45,.42) if mode=="disabled" else Color(1.2,1.2,1.1) if mode=="hover" else Color(.8,.8,.7) if mode=="pressed" else Color.WHITE;stop_button.add_theme_stylebox_override(mode,skin)
 start_button=button("初铸九宫",Rect2(880,953,540,82),func():model.start_foundation())
 result_panel=panel(Rect2(565,360,900,350));result_panel.hide()
 result_title=A.label("",57);result_title.position=Vector2(35,60);result_title.size=Vector2(830,95);result_title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;result_panel.add_child(result_title)
 result_body=A.label("",30);result_body.position=Vector2(55,176);result_body.size=Vector2(790,150);result_body.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;result_panel.add_child(result_body)
func refresh():
 visible=model.state in ["foundation_ready","foundation"]
 if not visible:return
 portrait.size=Vector2(570,590)
 var f=model.foundation
 var ready: bool=model.state=="foundation_ready" or f==null
 start_button.visible=ready;push_button.visible=not ready;stop_button.visible=not ready
 if ready:
  top.text="初铸不耗次数      ·      最多重铸 %d 次      ·      一品最低，九品最高" % R.MAX_REFORGES
  tendency.text="静待灵纹凝成";estimate.text="初铸后可随时定型";bonus.text="品数决定修炼加成";risk.text="每次重铸会降低稳定度";detail.text="点击灵纹锁定；重铸只改变未锁定格。\n\n类型与品数独立。";hint.text="九宫初铸，不消耗重铸次数"
 else:
  var p: Dictionary=f.preview()
  top.text="剩余重铸：%d / %d     ｜     已锁定：%d / 9     ｜     灵脉稳定度：%d%%"%[R.MAX_REFORGES-f.reforges,R.MAX_REFORGES,f.locks.count(true),f.stability]
  tendency.text=p.recipe.name
  estimate.text="组合潜力：%s品\n预计定型：%s"%[numeral(p.quality),numeral(p.quality)+"品" if p.low==p.quality else numeral(p.low)+"～"+numeral(p.quality)+"品"]
  bonus.text="修炼修为：+%d%%"%roundi((C.foundation_modifier(p.quality)-1)*100) if p.low==p.quality else "修炼修为：+%d%% ～ +%d%%"%[roundi((C.foundation_modifier(p.low)-1)*100),roundi((C.foundation_modifier(p.quality)-1)*100)]
  risk.text="灵脉稳固 · 按当前组合定型" if f.stability==100 else "灵脉承压 · 可能降品或留瑕\n"+("稀有类型有失稳风险" if p.recipe.rare else "水火相冲风险" if p.conflict else "继续冲品会进一步失稳")
  detail.text=p.recipe.description+"\n\n锁定在重铸后固定；此前可取消。\n一品最低，九品最高。"
  push_button.disabled=f.state!="choice" or f.reforges>=R.MAX_REFORGES or not f.locks.has(false)
  stop_button.disabled=f.state!="choice"
  hint.text="重铸次数已耗尽，必须筑基定型。" if f.reforges>=R.MAX_REFORGES else "九格已锁定，可筑基定型。" if not f.locks.has(false) else "点击灵纹锁定 · 下次重铸稳定度降至 %d%%"%R.STABILITY[f.reforges+1]
  if f.state=="reforging":hint.text="灵纹重凝……已锁定灵纹保持原位"
  if f.state=="finalizing":hint.text={"illuminate":"九纹同辉","connect":"灵纹共鸣","gather":"九宫归一 · 灵气入体","burst":"道基凝成","reveal":"筑基定型"}.get(f.phase,"道基凝成")
 for i in range(9):
  var b=cells[i];b.rune=R.PATTERNS[i] if ready else f.grid[i];b.locked=not ready and f.locks[i];b.committed=not ready and f.committed[i];b.disabled=ready or f.state!="choice" or f.reforges>=R.MAX_REFORGES or b.committed
  b.fade=1.0;b.glow=0
  b.position=Vector2(632+(i%3)*220,265+(i/3)*205);b.scale=Vector2.ONE;b.modulate=Color.WHITE
  if not ready and f.state=="reforging":
   var t: float=1-f.left/f.duration
   b.fade=1 if b.locked else absf(2*t-1);b.glow=sin(t*PI)
   if not b.locked: b.rotation=sin(t*TAU)*.018*(f.reforges+1)
  else:b.rotation=0
  if not ready and f.state=="finalizing":
   var t: float=1-f.left/f.duration
   b.glow=1
   if t>.4:
    var q: float=clampf((t-.4)/.3,0,1)
    b.position=b.position.lerp(Vector2(840,465),minf(q*2,1)).lerp(Vector2(230,530),maxf(0,q*2-1))
    b.scale=Vector2.ONE*(1-q*.85);b.modulate.a=1-q
  stop_button.modulate=Color(1.12+sin(visual_time*3)*.08,1.06,1) if not ready and f.reforges==R.MAX_REFORGES and f.state=="choice" else Color.WHITE
  b.queue_redraw()
 result_panel.visible=not ready and f.state=="finalizing" and f.phase=="reveal"
 preview_panel.visible=not result_panel.visible
 if result_panel.visible:push_button.hide();stop_button.hide();hint.text=""
 if result_panel.visible:
  result_title.text="%s品 · %s"%[numeral(f.grade),f.result.name]
  result_body.text="修炼修为获取：+%d%%\n%s"%[roundi((f.result.multiplier-1)*100),"灵纹留瑕 · 品数加成仍然生效" if f.result.flaw else "灵纹归一，道基已成"]
static func numeral(n: int) -> String:return ["零","一","二","三","四","五","六","七","八","九"][clampi(n,0,9)]
func _process(delta):
 visual_time+=delta
 if visible:refresh();queue_redraw()
func _draw():
 if not visible:return
 var f=model.foundation
 var hot: bool=f!=null and (f.reforges==R.MAX_REFORGES or (f.state=="finalizing" and (f.grade>=8 or f.result.rare)))
 var color:=Color("e8c27b") if hot else Color("84c8b5")
 var center:=Vector2(947,564)
 if f!=null and f.state in ["reforging","finalizing"]:
  var t: float=1-f.left/f.duration
  var power: float=sin(t*PI)
  for j in range(3):draw_arc(center,320+j*15,visual_time*.3+j,visual_time*.3+j+TAU*.85,100,Color(color,.25+power*.5),2,true)
  for i in range(9):
   var from: Vector2=cells[i].position+cells[i].size*.5
   if f.state=="finalizing":
    draw_line(from,center,Color(color,power*.65),2,true)
    var target:=Vector2(302,591)
    for k in range(5):
     var q: float=fmod(t*2+k*.19,1)
     draw_circle(from.lerp(target,q)+Vector2(0,sin(q*PI)*-100),3,Color(color,power))
   elif not f.locks[i]:
    for k in range(8):draw_circle(from+Vector2.from_angle(k*TAU/8+visual_time)*70*power,3,Color(color,power))
  if f.state=="finalizing" and f.phase=="burst":
   var strong: bool=f.grade>=8 or f.result.rare
   draw_circle(center,170,Color(color,.23 if strong else .09))
   if strong:
    for j in range(12):
     var offset:=Vector2.from_angle(j*TAU/12)*230
     draw_line(center+offset,center+offset*1.5,Color("ffe7a5"),4,true)
    draw_line(Vector2(947,100),Vector2(947,970),Color(1,.85,.45,.65),14,true)
