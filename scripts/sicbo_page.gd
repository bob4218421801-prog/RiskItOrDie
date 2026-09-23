extends Control
const ART=preload("res://scripts/migration_art.gd")
var model: RefCounted
var dice: Array[Control]=[]
var bets: Array[Button]=[]
var stake: Label
var forecast: Label
var target_label: Label
var confirm: Button
var back: Button
var exact: HBoxContainer
func label_at(words: String, rect: Rect2, pixels: int) -> Label:
 var node=ART.label(words,pixels);node.position=rect.position;node.size=rect.size;node.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;node.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 node.add_theme_color_override("font_color",Color("fff0cd"));node.add_theme_color_override("font_shadow_color",Color("163635"));node.add_theme_constant_override("shadow_offset_y",2);add_child(node);return node
func button_at(words: String, rect: Rect2, callback: Callable) -> Button:
 var b:=Button.new();b.text=words;b.position=rect.position;b.size=rect.size;ART.T.small(b);add_child(b)
 b.pressed.connect(func():
  if not model.modal.is_empty() or model.result_delay>0: return
  callback.call();model.save_session();refresh())
 return b
func _ready():
 size=Vector2(1920,1080)
 var bg:=TextureRect.new();bg.texture=preload("res://assets/ui_v6/sicbo.png");bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;bg.size=size;bg.mouse_filter=MOUSE_FILTER_IGNORE;add_child(bg)
 var title_plate:=Panel.new();title_plate.position=Vector2(660,58);title_plate.size=Vector2(600,100);title_plate.mouse_filter=MOUSE_FILTER_IGNORE;title_plate.add_theme_stylebox_override("panel",ART.T.skin("small_normal"));add_child(title_plate)
 var badge=preload("res://scripts/wallet_badge.gd").new();badge.model=model;badge.position=Vector2(100,70);badge.size=Vector2(370,74);add_child(badge)
 label_at("宗门骰宝",Rect2(680,65,560,85),44)
 stake=label_at("",Rect2(560,155,800,65),29)
 for i in 3:
  var d=preload("res://scripts/sicbo_die.gd").new();d.order=i;add_child(d);d.custom_minimum_size=Vector2.ZERO;d.position=Vector2(585+i*260,475);d.size=Vector2(230,240);dice.append(d)
 var names=["大","小","單","雙","任意豹子","指定總點數"]
 for i in names.size():
  var value: String=names[i]
  bets.append(button_at(value,Rect2(360+i*200,735,190,68),func(): model.sicbo.bet=value;model.sicbo.bet_selected=true))
 exact=HBoxContainer.new();exact.position=Vector2(720,818);exact.size=Vector2(480,65);exact.alignment=BoxContainer.ALIGNMENT_CENTER;exact.add_theme_constant_override("separation",18);add_child(exact)
 for direction in [-1,0,1]:
  if direction==0:
   target_label=ART.label("",30);target_label.custom_minimum_size=Vector2(150,62);target_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;target_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;exact.add_child(target_label)
  else:
   var b:=Button.new();b.text="−" if direction<0 else "+";b.custom_minimum_size=Vector2(90,62);ART.T.small(b);exact.add_child(b)
   b.pressed.connect(func(): model.sicbo.target=clampi(model.sicbo.target+direction,3,18);refresh())
 forecast=label_at("",Rect2(450,815,1020,76),28)
 confirm=button_at("押定 · 掷骰",Rect2(990,921,310,76),func(): model.sect.start_sicbo(model,model.sicbo.bet,model.sicbo.target))
 back=button_at("返回宗门",Rect2(620,921,310,76),func(): model.exit_side_activity())
 button_at("？",Rect2(1740,50,76,65),func(): model.show_help("sicbo"))
func _process(_delta): refresh()
func refresh():
 visible=model.activity_id=="sicbo"
 if not visible or model.sicbo==null: return
 var b=model.sicbo
 var ready: bool=b.state=="ready"
 var amount: int=model.sect.stipends[0] if not model.sect.stipends.is_empty() else 0
 stake.text="本期俸禄 %d 灵石 · 三骰定输赢"%amount if ready else "小师妹示范 · 豹子" if b.demo else "已下注 · "+b.bet
 for i in dice.size():
  dice[i].visible=not ready;dice[i].value=b.shown[i]
 for i in bets.size():
  bets[i].disabled=not ready or amount<=0
  bets[i].modulate=Color(1.15,1.13,.87) if b.bet_selected and b.bet==["大","小","單","雙","任意豹子","指定總點數"][i] else Color.WHITE
 exact.visible=ready and b.bet_selected and b.bet=="指定總點數";target_label.text=str(b.target)
 forecast.position.y=860 if exact.visible else 815
 if ready:
  var payout: int=model.sect.C.SICBO_TOTAL[b.target] if b.bet=="指定總點數" else model.sect.C.SICBO_PAYOUT.get(b.bet,2)
  forecast.text="本期俸禄已领完，下期再来。" if amount==0 else "本金 %d · 命中净赢 %d 灵石"%[amount,amount*(payout-1)] if b.bet_selected else "先选一注。豹子出现时，大小与单双均不获奖。"
 else: forecast.text="三枚玉骰逐一落定……"
 confirm.disabled=not ready or not b.bet_selected or amount==0;back.disabled=not ready
