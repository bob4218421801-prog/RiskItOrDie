extends PanelContainer
## Activities use one overlay; the run model owns pause, inventory and transactions.
const E = preload("res://scripts/economy_config.gd")
var model: RefCounted
var rows: VBoxContainer
var status: Label
var wallet_badge: Control
var body: VBoxContainer
var close_button: Button
var alchemy_retry: Button
var fire_button: Button
var fire_collect: Button
var fire_extra: Button
var heat_bar: Control
var furnace_status: Label
const A = preload("res://scripts/ink_assets.gd")
var sect_destination := ""
var full_page: Control
var world_map: Control
var sicbo_page: Control
var race_choice := -1
var race_identity: RefCounted
var stake_panel: Control
var entry_button: Button
var service := 0
var view_key := ""
var mine_buttons: Array[Button] = []
func _ready() -> void:
 name = "SideActivityPanel"
 position = Vector2.ZERO
 size = Vector2(1920,1080)
 var box := StyleBoxFlat.new()
 box.bg_color = Color("101e2b")
 box.border_color = Color("76dfc2")
 box.set_border_width_all(2)
 add_theme_stylebox_override("panel",StyleBoxEmpty.new())
 var margin := MarginContainer.new()
 for edge in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+edge,210 if edge in ["left","right"] else 180 if edge=="top" else 125)
 add_child(margin)
 rows = VBoxContainer.new()
 rows.add_theme_constant_override("separation",15)
 margin.add_child(rows)
 var header := HBoxContainer.new()
 rows.add_child(header)
 status = text(header, "", 26)
 status.hide()
 wallet_badge=preload("res://scripts/wallet_badge.gd").new();wallet_badge.model=model;wallet_badge.custom_minimum_size=Vector2(370,74);header.add_child(wallet_badge)
 var wallet_spacer:=Control.new();wallet_spacer.size_flags_horizontal=Control.SIZE_EXPAND_FILL;header.add_child(wallet_spacer)
 button(header,"?",func(): model.show_help("practice" if model.activity_id == "alchemy" and model.alchemy.practice else model.activity_id)).custom_minimum_size.x = 66
 body = VBoxContainer.new()
 body.size_flags_vertical = Control.SIZE_EXPAND_FILL
 body.add_theme_constant_override("separation",12)
 var scroll := ScrollContainer.new()
 scroll.name = "ActivityScroll"
 scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
 scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
 rows.add_child(scroll)
 body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 scroll.add_child(body)
 var footer:=HBoxContainer.new();footer.alignment=BoxContainer.ALIGNMENT_CENTER;footer.add_theme_constant_override("separation",36);rows.add_child(footer)
 alchemy_retry=button(footer,"免费试炉",func():
  if model.alchemy.state=="ready": model.start_practice()
  else: model.alchemy=preload("res://scripts/alchemy_state.gd").new())
 alchemy_retry.custom_minimum_size.x=320
 close_button = button(footer,"返回修煉",func():
  if model.activity_id in ["alchemy","stone_gambling","materials"]: navigate("lobby")
  else: model.exit_side_activity())
 close_button.custom_minimum_size.x=320
 full_page = preload("res://scripts/ink_activity_page.gd").new();full_page.host = self;full_page.model = model;add_child(full_page)
 world_map=preload("res://scripts/world_map_page.gd").new();world_map.host=self;world_map.model=model;add_child(world_map)
 sicbo_page=preload("res://scripts/sicbo_page.gd").new();sicbo_page.model=model;add_child(sicbo_page)
 refresh()
func _draw():
 if model == null: return
 var bg := "workshop" if model.activity_id in ["alchemy","stone_gambling","lobby","materials","preparation"] else "landscape"
 var backdrop: Texture2D=preload("res://scripts/ink_assets.gd").texture(bg)
 if model.activity_id=="active_duel": backdrop=preload("res://assets/duel_backgrounds/wenjian.png")
 elif model.activity_id=="tournament" and model.tournament!=null and model.tournament.kind=="tianji": backdrop=preload("res://assets/duel_backgrounds/tianjidabi.png")
 var ratio: float=maxf(size.x/backdrop.get_width(),size.y/backdrop.get_height())
 var extent: Vector2=backdrop.get_size()*ratio
 draw_texture_rect(backdrop,Rect2((size-extent)*.5,extent),false)
 if model.activity_id in ["sword_race","mines"]: draw_style_box(preload("res://scripts/ink_theme.gd").box(),Rect2(65,65,1790,950))
 else: draw_style_box(preload("res://scripts/migration_art.gd").skin("frame"),Rect2(65,65,1790,950))
func text(parent: Node, value: String, pixels: int = 25) -> Label:
 var label := Label.new()
 label.text = value
 if pixels>=32: label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 if model.activity_id not in ["sword_race","mines"]: label.add_theme_color_override("font_color",Color("f0eadb"))
 label.add_theme_font_size_override("font_size",pixels)
 label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 parent.add_child(label)
 return label
func button(parent: Node, title: String, callback: Callable) -> Button:
 var b := Button.new()
 b.text = title
 b.custom_minimum_size.y = 66
 b.add_theme_font_size_override("font_size",25)
 if model.activity_id in ["sword_race","mines"]: preload("res://scripts/jade_theme.gd").apply_button(b)
 else:
  preload("res://scripts/reference_home_theme.gd").small(b);b.custom_minimum_size.x=clampf(b.get_theme_font("font").get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,25).x+75,230,560);b.size_flags_horizontal=Control.SIZE_SHRINK_CENTER
 b.pressed.connect(func():
  if not model.modal.is_empty() or model.result_delay > 0: return
  callback.call()
  model.save_session()
  model.sfx_event.emit("ui_confirm")
  refresh())
 parent.add_child(b)
 return b
func navigate(id: String) -> void:
 model.exit_side_activity()
 model.enter_side_activity(id)
func refresh() -> void:
 visible = model.state == "activity" and model.activity_id not in ["duel","blood","jade","sword_race","mines"]
 if not visible:
  view_key = ""
  sect_destination = ""
  return
 queue_redraw()
 sicbo_page.visible=model.activity_id=="sicbo"
 if sicbo_page.visible:
  rows.hide();world_map.hide();full_page.hide();sicbo_page.refresh();return
 world_map.visible=model.activity_id in ["sect","opportunities","lobby"] and sect_destination.is_empty()
 if world_map.visible:
  rows.hide();full_page.hide();world_map.refresh();return
 full_page.visible = model.activity_id == "sword_race"
 rows.visible = not full_page.visible
 if full_page.visible:
  if model.activity_id == "sword_race" and race_identity != model.race: race_identity = model.race;race_choice = -1
  full_page.refresh()
  return
 status.text="";status.hide()
 if model.activity_id == "sword_race" and race_identity != model.race:
  race_identity = model.race;race_choice = -1
 var substate := ""
 if model.activity_id == "tournament": substate = model.tournament.stage+str(model.tournament.index)+str(model.tournament.ceremony)+str(model.sect.card_choices)+str(model.sect.inventory)
 if model.activity_id == "duel": substate = model.duel.state+str(model.duel.serial)+str(model.duel.player)+str(model.duel.score)+model.duel.message
 if model.activity_id == "sword_race": substate = model.race.state
 if model.activity_id == "mines": substate = model.mines.state
 if model.activity_id == "stone_gambling": substate = model.stone.state+str(model.stone.depth)
 if model.activity_id == "alchemy": substate = model.alchemy.state if model.alchemy.state in ["ready","result"] else "active"
 if model.activity_id in ["sect","pavilion"]: substate = str(model.sect.inventory)+str(model.sect.stipends)+str(model.sect.affection)+str(model.sect.seen)+str(model.sect.card_choices)+str(model.sect.chat)+sect_destination
 if model.activity_id == "sicbo": substate = model.sicbo.state
 var key: String = model.activity_id+substate
 if substate in ["", "ready", "result"]: key += str(model.spirit_stones)+str(model.raw_stones)+str(model.materials)+str(model.fragments)+str(model.tickets)+str(model.pills)
 if key != view_key:
  view_key = key
  for child in body.get_children():
   body.remove_child(child)
   child.queue_free()
  mine_buttons.clear()
  build()
 alchemy_retry.visible=model.activity_id=="alchemy" and model.alchemy.state in ["ready","result"]
 if alchemy_retry.visible: alchemy_retry.text="免费试炉" if model.alchemy.state=="ready" else "再开一炉"
 close_button.text = "返回洞府" if model.activity_id in ["alchemy","stone_gambling","materials"] else ("返回宗門" if model.activity_id == "sicbo" else "返回修煉")
 close_button.disabled = (model.activity_id == "sicbo" and model.sicbo.state == "rolling") or (model.activity_id == "tournament" and model.tournament.stage != "final") or (model.activity_id == "duel" and model.duel.state != "result") or (model.activity_id == "alchemy" and model.alchemy.state not in ["ready","result"]) or substate in ["racing","mining"] or (model.activity_id == "stone_gambling" and model.stone.state not in ["ready","result"])
 if model.activity_id in ["sword_race","mines"] and is_instance_valid(entry_button) and substate == "ready":
  entry_button.text = ("拉桿啟程 · %d份" if model.activity_id == "sword_race" else "開始 · %d份") % (model.stake_free+model.stake_paid)
  entry_button.disabled = not model.valid_stake() or (model.activity_id == "sword_race" and race_choice < 0)
 if model.activity_id == "sword_race" and body.has_node("RaceForecast"):
  body.get_node("RaceForecast").text = "先選一柄飛劍" if race_choice < 0 else "勝出可得 %d 靈石 · %d份" % [int(E.ENTRY_COST*E.RACE_PAYOUT[race_choice])*(model.stake_free+model.stake_paid),model.stake_free+model.stake_paid]
 if model.activity_id == "sicbo" and body.has_node("DiceRow"):
  for i in range(3):
   body.get_node("DiceRow").get_child(i).value = model.sicbo.shown[i]
 if model.activity_id == "alchemy" and substate == "active":
  var a: RefCounted = model.alchemy
  heat_bar.queue_redraw()
  furnace_status.text = E.PILL_NAMES[a.recipe]+(" · 再煉一火 · " if a.extra else " · ")+a.stage_text()
  fire_button.visible = a.state != "choice"
  fire_button.disabled = a.state not in ["idle","heating"]
  fire_button.text = "鬆手降火" if a.holding else "按住升火"
  fire_collect.visible = a.state == "choice"
  fire_extra.visible = a.state == "choice" and not a.extra_used
 if model.activity_id == "mines":
  for i in range(mine_buttons.size()):
   mine_buttons[i].disabled = substate != "mining" or i in model.mines.revealed
   var revealed: bool = i in model.mines.revealed
   var mineral := 12 if i in model.mines.dangers else (11 if model.mines.crystals.get(i,"") == "rare" else 10)
   mine_buttons[i].text = ""
   mine_buttons[i].get_node("MineralArt").texture = A.relic(6) if revealed and mineral == 12 else A.piece(mineral if revealed else 9)
   mine_buttons[i].tooltip_text=""
  if body.has_node("MineCashout"):
   body.get_node("MineCashout").modulate = Color(1,1.0-minf(.35,model.mines.reward/7000.0),.65)
  if body.has_node("MineReward"): body.get_node("MineReward").text = "目前未收取收益 %d 靈石 · %s\n靈石尚未入袋，可隨時收取離開。" % [model.mines.reward*(model.entry_shares if not model.mines.paid_out else 1),["尚算安穩","略有兇險","吉凶難料","險象環生"][mini(3,model.mines.revealed.size()/4)]]
func build() -> void:
 match model.activity_id:
  "sect","sicbo","pavilion": preload("res://scripts/sect_view.gd").build(self)
  "duel": build_duel()
  "active_duel": build_board()
  "tournament": build_tournament()
  "opportunities":
   text(body,"機緣 · 外出歷練",36)
   for key in E.TICKETS:
    var id: String = key
    var unlocked: bool = model.activity_unlocked(id)
    var cost_text := " · 可加注 %d 靈石／份" % model.entry_cost(id) if model.realm >= 10 else " · 使用免費券"
    var b := button(body,("【新】" if model.new_features.has(id) else "")+"%s · 免費券 %d 張%s%s" % [E.NAMES[id],model.tickets[id],cost_text,"" if unlocked else "（築基解鎖）"],func(): navigate(id))
    b.disabled = not unlocked or not model.can_pay_entry(id)
   text(body,"靈舟：隨時收取，墜毀全失。\n飛劍：選一劍競速，勝者得獎。\n探礦：逐格探索，及時帶回未收取收益。",24)
  "materials":
   text(body,"材料库 · 仅展示持有材料",34)
   var grid:=GridContainer.new();grid.columns=5;grid.size_flags_horizontal=SIZE_SHRINK_CENTER;grid.add_theme_constant_override("h_separation",18);grid.add_theme_constant_override("v_separation",24);body.add_child(grid)
   var count:=0
   for i in range(E.MATERIAL_NAMES.size()):
    if model.materials[i]<=0: continue
    count+=1;item_card(grid,E.MATERIAL_NAMES[i],load("res://assets/ui_v5/material_%d.png"%i),"持有 %s"%str(model.materials[i]),"查看",func(): model.modal={"kind":"notice","title":E.MATERIAL_NAMES[i],"text":"炼丹材料，持有 %d。完整配方可在炼丹坊查看。"%model.materials[i]},false,Vector2(280,405))
   if count==0:
    var empty:=centered_column(body,880);empty.custom_minimum_size.y=360;empty.alignment=BoxContainer.ALIGNMENT_CENTER
    text(empty,"材料库尚空",32)
    text(empty,"解石所得的材料会收在这里。",26).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  "lobby":
   text(body,"洞府 · 資源與結丹準備",36)
   for id in ["stone_gambling","alchemy","preparation","materials"]:
    var feature: String = id
    button(body,("【新】" if model.new_features.has(id) else "")+{"stone_gambling":"解石坊","alchemy":"煉丹","preparation":"結丹準備","materials":"材料庫"}[id],func(): navigate(feature))
   var array_button := button(body,"聚靈陣 · %d 靈石 / %d 次 +20%% · 剩餘 %d 次" % [E.ARRAY_COST,E.ARRAY_ATTEMPTS,model.array_attempts],func(): model.buy_array(); view_key = "")
   array_button.disabled = model.array_attempts > 0 or model.spirit_stones < E.ARRAY_COST
  "stone_gambling": build_stone()
  "alchemy": build_alchemy()
  "preparation": build_preparation()
  "sword_race":
   if model.race.state == "ready":
    text(body,"預估收益 · 選一柄飛劍",36).name = "RaceForecast"
    var cabinet := HBoxContainer.new();cabinet.add_theme_constant_override("separation",36);body.add_child(cabinet)
    var choices := VBoxContainer.new();choices.size_flags_horizontal = Control.SIZE_EXPAND_FILL;cabinet.add_child(choices)
    for i in range(E.RACE_NAMES.size()):
     var choice := i
     var row := HBoxContainer.new();choices.add_child(row)
     var art := A.sprite(A.sword(i));art.custom_minimum_size = Vector2(400,90);row.add_child(art)
     var label := text(row,E.RACE_NAMES[i]+"  ×%.2f" % E.RACE_PAYOUT[i],28);label.size_flags_horizontal = Control.SIZE_EXPAND_FILL;label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
     button(row,"已選定" if race_choice == i else "選擇",func(): race_choice = choice;view_key = "").custom_minimum_size.x = 150
    var start := VBoxContainer.new();start.custom_minimum_size.x = 660;cabinet.add_child(start)
    var lever := A.sprite(A.lever());lever.custom_minimum_size = Vector2(270,220);start.add_child(lever)
    entry_button = button(start,"拉桿啟程",func(): model.start_race(race_choice))
    lever.gui_input.connect(func(event):
     if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not entry_button.disabled: entry_button.pressed.emit())
    lever.mouse_filter = Control.MOUSE_FILTER_STOP
    add_stake(start)
   else:
    for i in range(E.RACE_NAMES.size()):
     text(body,("▶ " if model.race.selected == i else "")+E.RACE_NAMES[i])
     var lane = preload("res://scripts/sword_lane.gd").new()
     lane.name = "SwordLane%d" % i
     lane.race = model.race
     lane.index = i
     body.add_child(lane)
  "mines":
   text(body,"靈礦探寶 · 一步一探，見好就收",36)
   if model.mines.state == "ready":
    add_stake()
    entry_button = button(body,"開始",func(): model.start_mines())
   else:
    var grid := GridContainer.new()
    grid.columns = 5
    grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    body.add_child(grid)
    for i in range(25):
     var cell := i
     var b := button(grid,"◇",func(): model.reveal_mine(cell))
     b.custom_minimum_size = Vector2(150,86)
     for mode in ["normal","disabled"]: b.add_theme_stylebox_override(mode,StyleBoxEmpty.new())
     var art := A.sprite(A.piece(9));art.name = "MineralArt";b.add_child(art);art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
     b.tooltip_text=""
     mine_buttons.append(b)
    text(body,"",28).name = "MineReward"
    if model.mines.state == "mining": button(body,"收取獎勵",func(): model.collect_mines()).name = "MineCashout"
    else: text(body,"煞氣爆發，本次歸零" if model.mines.state == "failed" else "靈晶入袋",30)

func inventory_line() -> String:
 var parts: Array[String] = []
 for i in range(5): parts.append("%s ×%d" % [E.MATERIAL_NAMES[i],model.materials[i]])
 return "  /  ".join(parts)
func build_stone() -> void:
 text(body,"解石坊"+(" · "+E.RAW_NAMES[model.stone.tier] if model.stone.state != "ready" else ""),32)
 if model.stone.state == "ready":
  var grid:=GridContainer.new();grid.columns=5;grid.size_flags_horizontal=SIZE_SHRINK_CENTER;grid.add_theme_constant_override("h_separation",18);body.add_child(grid)
  for i in range(4):
   var tier:=i
   item_card(grid,E.RAW_NAMES[i],load("res://assets/ui_v6/raw_stone_middle.png") if i==1 else load("res://assets/ui_v5/material_%d.png"%i),"持有 %d 块\n自行解石，不收服务费"%model.raw_stones[i],"选择原石",func(): model.open_stone(tier,0),model.raw_stones[i]<=0,Vector2(350,390))
 elif model.stone.state in ["scratching","choice"]:
  text(body,"%s · %s · %s" % [["外皮","見玉","取芯"][model.stone.depth],model.stone.clue,["石皮尚穩","裂紋漸深","芯脈脆弱，寶物與崩裂並存"][model.stone.depth]],28)
  var surface = preload("res://scripts/scratch_surface.gd").new()
  surface.model = model
  body.add_child(surface)
  if model.stone.state == "scratching": text(body,"按住拖曳，磨去石皮；反覆磨同一處不會增加揭露。")
  else:
   if model.stone.depth > 0:
    var reward: Dictionary = model.stone.rewards[model.stone.depth]
    text(body,"已見：%s ×%d" % [E.MATERIAL_NAMES[reward.material],reward.quantity])
   button(body,"就此解石 / 收石",func(): model.collect_stone())
   if model.stone.depth < 2: button(body,"再磨一層 · 可能損失已見材料",func(): model.stone.deeper())
 else:
  var r: Dictionary = model.stone.result
  text(body,("石裂 · " if r.failed else "收石 · ")+("護符保住前層 · " if r.protected else "")+("%s ×%d" % [E.MATERIAL_NAMES[r.material],r.quantity] if r.material >= 0 else "未得材料")+" · 碎片 +%d" % r.fragments,30)
  button(body,"再選一塊原石",func(): model.stone = preload("res://scripts/stone_state.gd").new())
 if model.stone.state in ["ready","result"]:
  text(body,"石髓碎片 %d · 可兌換指定材料" % model.fragments,23).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  var exchanges := HBoxContainer.new();exchanges.alignment=BoxContainer.ALIGNMENT_CENTER;exchanges.add_theme_constant_override("separation",24)
  body.add_child(exchanges)
  for i in range(5):
   var material := i
   var b := button(exchanges,"%s\n%d 碎片" % [E.MATERIAL_NAMES[i],E.PITY_COST[i]],func(): model.exchange_fragments(material); view_key = "")
   b.custom_minimum_size.y=90
   b.disabled = model.fragments < E.PITY_COST[i]


func recipe_summary(index: int) -> String:
 var parts: Array[String]=[]
 for i in range(5):
  if E.RECIPES[index][i]>0: parts.append("%s × %d"%[E.MATERIAL_NAMES[i],E.RECIPES[index][i]])
 return "\n".join(parts)+"\n费用 %d 灵石"%E.RECIPE_COST[index]
func recipe_description(index: int) -> String:
 var parts: Array[String] = []
 for i in range(5):
  if E.RECIPES[index][i] > 0: parts.append("%s 需%d／持有%d" % [E.MATERIAL_NAMES[i],E.RECIPES[index][i],model.materials[i]])
 return "\n".join(parts)+"\n%d 靈石" % E.RECIPE_COST[index]
func build_alchemy() -> void:
 text(body,"初習丹道 · 免費試爐" if model.alchemy.practice else "煉丹爐 · 一縷丹火，凝藥成丹",36)
 var a: RefCounted = model.alchemy
 if a.state == "ready":

  
  var grid:=GridContainer.new();grid.columns=5;grid.add_theme_constant_override("h_separation",18);body.add_child(grid)
  for i in range(5):
   var recipe:=i
   item_card(grid,E.PILL_NAMES[i],load("res://assets/ui_v5/pill_%d.png"%i),recipe_summary(i),"选择丹方",func():
    model.modal={"kind":"recipe_select","title":E.PILL_NAMES[recipe],"text":recipe_description(recipe),"recipe":recipe},false,Vector2(285,450))
 elif a.state == "result":
  text(body,"試爐完成 · 已熟悉火候" if a.practice else ("丹成 · " + ("上品 " if a.quality == 1 else "普通 ")+E.PILL_NAMES[a.recipe]) if a.result == "success" else "爐毀丹失 · 本爐材料已耗盡",34).name = "FurnaceReward"

 else:
  var furnace = preload("res://scripts/furnace_view.gd").new()
  furnace.model = model
  body.add_child(furnace)
  furnace_status = text(body,"",27)
  furnace_status.name = "AlchemyLabels"
  heat_bar = preload("res://scripts/heat_view.gd").new()
  heat_bar.model = model
  body.add_child(heat_bar)
  fire_button = Button.new()
  fire_button.custom_minimum_size.y = 80
  fire_button.add_theme_font_size_override("font_size",28)
  fire_button.button_down.connect(func(): model.begin_fire())
  fire_button.button_up.connect(func(): model.release_fire())
  body.add_child(fire_button)
  fire_collect = button(body,"開爐取丹",func(): model.collect_pill())
  fire_extra = button(body,"再煉一火 · 爭上品，失手就炸爐",func(): a.extra_fire())
func build_preparation() -> void:
 var p: Dictionary=model.preparation()
 text(body,"结丹准备",38)
 text(body,"五味丹药 · 已备齐 %d / 5"%p.count,30).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 var sections:=HBoxContainer.new();sections.alignment=BoxContainer.ALIGNMENT_CENTER;sections.add_theme_constant_override("separation",64);body.add_child(sections)
 var pills:=centered_column(sections,620)
 text(pills,"丹药储备",32)
 var grid:=GridContainer.new();grid.columns=3;grid.add_theme_constant_override("h_separation",16);grid.add_theme_constant_override("v_separation",8);pills.add_child(grid)
 var entries: Array=["丹药","持有","上品"]
 for i in range(5): entries.append_array([("✓ " if model.pills[i]>0 else "◇ ")+E.PILL_NAMES[i],str(model.pills[i]),str(model.upper_pills[i])])
 for i in entries.size():
  var cell:=text(grid,entries[i],26);cell.custom_minimum_size=Vector2([180,200,200][i%3],44);cell.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT if i%3==0 else HORIZONTAL_ALIGNMENT_RIGHT
 var treasure:=centered_column(sections,620)
 text(treasure,"护道宝物",32)
 var owned:=0
 for i in range(3):
  if model.treasures[i]>0: text(treasure,"%s × %d"%[model.D.TREASURES[i],model.treasures[i]],26);owned+=1
 for collection in [model.blood_items,model.keepsakes]:
  for key in collection:
   if collection[key]>0: text(treasure,"%s × %d"%[key,collection[key]],26);owned+=1
 if owned==0:
  var empty:=text(treasure,"尚未获得护道宝物\n历练所得将在这里列出。",26);empty.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;empty.custom_minimum_size.y=180;empty.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 var gap:=Control.new();gap.custom_minimum_size.y=16;body.add_child(gap)
 text(body,p.status+" · 丹材先备着，结丹还需等待契机。",26).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER

func seals(hand: Array, hidden: bool):
 var row := HBoxContainer.new()
 row.add_theme_constant_override("separation",14)
 body.add_child(row)
 for i in range(hand.size()):
  var panel := PanelContainer.new()
  panel.custom_minimum_size = Vector2(112,68)
  var style := StyleBoxFlat.new()
  style.bg_color = Color("223644") if hidden and i == 1 else Color("254f50")
  style.border_color = Color("c4b183")
  style.set_border_width_all(2)
  style.set_corner_radius_all(8)
  panel.add_theme_stylebox_override("panel",style)
  row.add_child(panel)
  var mark := text(panel,"藏鋒 · ?" if hidden and i == 1 else "劍印 · %d" % hand[i],25)
  mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
func build_duel() -> void:
 var d: RefCounted = model.duel
 text(body,"%s · %s  【%s】" % [model.D.NAMES[d.archetype],model.D.SECTS[d.archetype],model.D.ARCHETYPES[d.archetype]],36)
 text(body,model.D.STYLES[d.archetype],24)
 text(body,"先取三籌 · %d : %d" % [d.score[0],d.score[1]],34)
 if d.state == "arrival":
  text(body,"一封劍帖送至。先看彩頭與代價，再決定是否接戰。",27)
  text(body,model.duel_stakes(d.archetype),25)
  button(body,"接下劍帖",func(): model.duel_action("accept"))
  button(body,"婉拒此戰 · 修為 -%d" % mini(model.cultivation,int(ceil(model.requirement()*model.D.REFUSAL[d.archetype]))),func(): model.duel_action("refuse"))
  button(body,"避戰遁走 · %d 靈石" % model.D.ESCAPE[d.archetype],func(): model.duel_action("escape"))
 else:
  seals(d.opponent_hand,not d.revealed)
  text(body,"對手劍勢："+(str(d.opponent) if d.revealed else "藏鋒未露"),30)
  seals(d.player_hand,false)
  text(body,"你的劍勢：%d%s" % [d.player," · 劍勢圓滿 · 二十一" if d.player == 21 else (" · 劍氣迫人" if d.player >= 18 else "")],36)
  if d.state == "playing":
   button(body,"再出一劍",func(): model.duel_action("draw"))
   button(body,"收劍守勢",func(): model.duel_action("stand"))
  elif d.state == "round_result": button(body,"整劍再戰",func(): model.duel_action("next"))
 text(body,d.message,28)
func centered_column(parent: Node, width: float=1040) -> VBoxContainer:
 var column:=VBoxContainer.new();column.custom_minimum_size.x=width;column.size_flags_horizontal=SIZE_SHRINK_CENTER;column.add_theme_constant_override("separation",24);parent.add_child(column);return column
func build_board():
 text(body,"問劍榜 · 尋訪諸宗",38)
 text(body,"再修煉 %d 次，便有新一批劍帖。每人每批只戰一次。" % maxi(0,model.D.BOARD_INTERVAL-(model.attempts-model.board_attempt)),24).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 var list:=centered_column(body,1120)
 for i in range(model.board.size()):
  var index := i
  var kind: int = model.board[i].archetype
  var row:=HBoxContainer.new();row.add_theme_constant_override("separation",48);list.add_child(row)
  var copy:=VBoxContainer.new();copy.custom_minimum_size.x=820;copy.size_flags_horizontal=SIZE_EXPAND_FILL;copy.add_theme_constant_override("separation",12);row.add_child(copy)
  var npc: int=model.board[i].get("npc_id",-1)
  var entry_data: Dictionary=model.NPC.NPCS[npc] if npc>=0 else {"name":model.D.NAMES[kind],"sect":model.D.SECTS[kind],"style":model.D.ARCHETYPES[kind]}
  text(copy,"%s · %s  【%s】" % [entry_data.sect,entry_data.name,entry_data.style],29)
  text(copy,model.duel_stakes(kind),23)
  var entry:=button(row,"已交鋒" if model.board[i].used else "遞上劍帖",func(): model.challenge_opponent(index));entry.size_flags_vertical=SIZE_SHRINK_CENTER
  entry.disabled=model.board[i].used

func build_tournament():
 var event: RefCounted = model.tournament
 if event.stage=="between":
  var space:=Control.new();space.custom_minimum_size.y=48;space.size_flags_vertical=SIZE_EXPAND_FILL;body.add_child(space)
 var heading = text(body,"天元曆 %d · %s" % [event.year,event.title()],44)
 heading.add_theme_color_override("font_color",Color("e5c88c") if event.kind == "tianji" else Color("dfebe0"))
 if event.kind == "tianji": text(body,"天機閣主持 · 各宗天驕齊聚",27)
 if event.stage == "between":
  var content:=VBoxContainer.new();content.custom_minimum_size.x=880;content.size_flags_horizontal=SIZE_SHRINK_CENTER;content.add_theme_constant_override("separation",24);body.add_child(content)
  text(content,"已戰 %d / %d 場 · %d 勝 %d 負" % [event.index,event.total_matches(),event.wins,event.losses],30).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  var gap:=Control.new();gap.custom_minimum_size.y=8;content.add_child(gap)
  var label:=text(content,"下一位对手",23);label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.add_theme_color_override("font_color",Color("bbc9bb"))
  text(content,"%s · %s" % [event.names()[event.index],event.sects()[event.index]],36).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  var rules:=text(content,"禁用神通与神通符 · 战毕揭榜领奖",24);rules.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;rules.add_theme_color_override("font_color",Color("bbc9bb"))
  var enter:=button(content,"赴下一戰" if event.index > 0 else "登臺 · 第一戰",func(): model.tournament_next());preload("res://scripts/reference_home_theme.gd").primary(enter);enter.custom_minimum_size=Vector2(408,96)
  var space:=Control.new();space.custom_minimum_size.y=48;space.size_flags_vertical=SIZE_EXPAND_FILL;body.add_child(space)
 elif event.stage == "ceremony":
  var banner := text(body,["眾劍歸鞘，滿座寂然……",("五戰皆捷" if event.kind == "tianji" else "三戰皆捷"),event.champion()][mini(2,event.ceremony)],64)
  banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  banner.add_theme_color_override("font_color",Color("806238"))
  text(body,"各宗觀禮者起身相賀，你的名字正寫入天機金榜之首。" if event.kind == "tianji" else "大師姐於另一側賽程全勝奪魁。你三戰全勝，位列亞軍。",30).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  var glow := PanelContainer.new();glow.custom_minimum_size.y=130;glow.add_theme_stylebox_override("panel",preload("res://scripts/migration_art.gd").skin("plaque",25));body.add_child(glow)
  text(glow,"五战皆捷" if event.kind=="tianji" else "三战皆捷",48).add_theme_color_override("font_color",Color("355348"))
 else:
  text(body,event.board_title()+" · 最终榜",40)
  var podium:=HBoxContainer.new();podium.alignment=BoxContainer.ALIGNMENT_CENTER;podium.add_theme_constant_override("separation",28);body.add_child(podium)
  for rank in [2,1,3]:
   for row in event.board:
    if row.rank==rank: ranking_card(podium,row,true)
  var reward:=PanelContainer.new();reward.add_theme_stylebox_override("panel",preload("res://scripts/migration_art.gd").skin("plaque",30));body.add_child(reward)
  var reward_label=text(reward,"你的名次：%s\n%s"%[("第 %d 名"%event.rank if event.rank>0 else "榜外"),event.reward_text],28);reward_label.add_theme_color_override("font_color",Color("294b40"));reward_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  if event.kind=="sect": text(body,"大师姐 · 本届魁首",28).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;preload("res://scripts/sect_view.gd").cards(self)
  var others:=GridContainer.new();others.columns=3;others.add_theme_constant_override("h_separation",20);others.add_theme_constant_override("v_separation",12);body.add_child(others)
  for row in event.board:
   if row.rank>3 or row.rank==0: ranking_card(others,row,false)
func ranking_card(parent: Node, row: Dictionary, podium: bool):
 var art=preload("res://scripts/migration_art.gd")
 var p:=PanelContainer.new();p.custom_minimum_size=Vector2(460,255 if row.rank==1 and podium else (225 if podium else 100));p.size_flags_vertical=Control.SIZE_SHRINK_END;p.add_theme_stylebox_override("panel",art.skin("slot" if podium else "plaque",28));parent.add_child(p)
 var v:=VBoxContainer.new();v.add_theme_constant_override("separation",10);p.add_child(v)
 var title: String={1:"魁首",2:"榜眼",3:"探花"}.get(row.rank,"第 %d 名"%row.rank if row.rank>0 else "榜外")
 var l=art.label(title,40 if row.rank==1 else 30,false);l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;v.add_child(l)
 var name_label=art.label("【你】" if row.player else row.name,32 if podium else 25,false);name_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;v.add_child(name_label)
 var sect_label=art.label(row.sect,23,false);sect_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;v.add_child(sect_label)

func add_stake(parent: Node = null):
 stake_panel = preload("res://scripts/stake_view.gd").new();stake_panel.model = model;(body if parent == null else parent).add_child(stake_panel)

func item_card(parent: Node, title: String, icon: Texture2D, detail: String, action: String, callback: Callable, disabled: bool=false, dimensions: Vector2=Vector2(300,420)):
 var art=preload("res://scripts/migration_art.gd")
 var panel:=PanelContainer.new();panel.custom_minimum_size=dimensions;panel.add_theme_stylebox_override("panel",art.skin("slot",28));parent.add_child(panel)
 var rows:=VBoxContainer.new();rows.add_theme_constant_override("separation",14);panel.add_child(rows)
 var picture=art.picture(icon,Vector2(dimensions.x-60,115));rows.add_child(picture)
 var heading=art.label(title,28,false);heading.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;rows.add_child(heading)
 var description=art.label(detail,21,false);description.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER if not detail.contains("\n") else HORIZONTAL_ALIGNMENT_LEFT;description.custom_minimum_size=Vector2(dimensions.x-60,105);description.size_flags_vertical=SIZE_EXPAND_FILL;rows.add_child(description)
 var b:=Button.new();b.text=action;b.custom_minimum_size=Vector2(210,60);b.size_flags_horizontal=SIZE_SHRINK_CENTER;art.T.small(b);b.disabled=disabled;rows.add_child(b);b.pressed.connect(func():
  if model.modal.is_empty(): callback.call();model.save_session();view_key="";refresh())
