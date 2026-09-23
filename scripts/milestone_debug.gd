extends PanelContainer
var model: RefCounted
var status: Label
var active_label: Label
var audio_manager: Node
var review_room: Control
func _ready():
 name = "DeveloperTestHub"
 position = Vector2(70,35)
 size = Vector2(1780,1005)
 var box := StyleBoxFlat.new()
 box.bg_color = Color("17222c")
 add_theme_stylebox_override("panel",box)
 var rows := VBoxContainer.new()
 add_child(rows)
 status = label(rows,"")
 active_label = label(rows,"")
 var commands := HBoxContainer.new()
 rows.add_child(commands)
 action(commands,"Clear All Overrides",func(): model.clear_overrides())
 action(commands,"Reset Current Test",func(): model.reset_current_test())
 action(commands,"Reset Run",func(): model.reset())
 action(commands,"返回測試 F10",func(): hide())
 var scroll := ScrollContainer.new()
 scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
 rows.add_child(scroll)
 var groups := VBoxContainer.new()
 groups.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 scroll.add_child(groups)
 var play := row(groups,"直接實際遊玩")
 action(play,"直接測試問劍",func(): model.debug_quick_play("duel"); hide())
 action(play,"直接測試煉丹",func(): model.debug_quick_play("alchemy"); hide())
 action(play,"直接測試築基台",func(): model.debug_quick_play("foundation"); hide())
 action(play,"直接測試宗門大比",func(): model.debug_quick_play("tournament"); hide())
 action(play,"直接測試魔道劫殺",func(): model.debug_quick_play("blood"); hide())
 action(play,"SFX 評審室",func(): hide(); review_room.open_room())
 var master_tests := row(groups,"師父對話")
 for entry in [["普通聊天","daily"],["走火入魔後","failure"],["破而後立後","rebirth"],["剛築基","foundation"],["大比後","festival"],["結丹準備","late"],["連續點師父","repeat"]]:
  var context: String = entry[1]
  action(master_tests,entry[0],func(): model.debug_master(context);hide())
 var sect_tests := row(groups,"宗門與歷練")
 var story_tests := row(groups,"築基劇情與對話測試")
 for entry in [["小師妹五局教學","junior"],["大師姐五局初戰","senior"],["習得神識探查","probe"],["宗門 0–3","result0"],["宗門 1–2","result1"],["宗門 2–1","result2"],["宗門 3–0","result3"],["首次亞軍劇情","runner"],["大師姐奪魁","champion"],["日常對話池","pool"],["情境對話","context"]]:
  var story_id: String = entry[1]
  action(story_tests,entry[0],func(): model.debug_story(story_id);hide())
 for entry in [["測試開場劇情","opening"],["測試小師妹初遇","junior"],["測試小師妹好感事件","affection"],["測試大師姐初戰","senior"],["測試築基七層再戰大師姐","senior7"],["測試宗門俸祿","stipend"],["測試骰寶首次豹子事件","sicbo"],["測試宗門大比","sect_festival"],["測試天機大比","tianji"],["測試天機閣","pavilion"],["測試魔道劫殺","blood"],["測試機緣多份下注","multi"]]:
  var id: String = entry[1]
  action(sect_tests,entry[0],func(): model.debug_sect(id);hide())
 var entries := row(groups,"直接進入（重置目前測試；清除 overrides）")
 for id in ["qi","foundation","foundation_realm","opportunities","lobby","flying_boat","sword_race","mines","stone_gambling"]:
  var key: String = id
  action(entries,id,func(): model.debug_enter(key))
 var realms := row(groups,"築基小境界／自動測試")
 for i in range(10,20):
  var index: int = i
  action(realms,model.C.REALMS[i],func(): model.reset_current_test(); model.debug_milestone("realm",index))
 action(realms,"自動 ON",func(): model.set_auto(true))
 action(realms,"自動 OFF",func(): model.set_auto(false))
 action(realms,"自動十次",func(): model.debug_milestone("auto_sequence"))
 var resources := row(groups,"資源／庫存")
 for amount in [100,1000,10000]:
  var value: int = amount
  action(resources,"靈石 +%d" % amount,func(): model.spirit_stones += value)
 action(resources,"各票 +1",func():
  for id in model.tickets: model.tickets[id] += 1)
 action(resources,"各原石 +3",func():
  for i in range(4): model.raw_stones[i] += 3)
 action(resources,"各材料 +20",func(): model.debug_milestone("materials"))
 action(resources,"碎片 +200",func(): model.fragments += 200)
 action(resources,"各丹 +1",func():
  for i in range(5): model.pills[i] += 1)
 action(resources,"各寶物 +1",func():
  for i in range(3): model.treasures[i] += 1)
 forces(groups,"修煉 · 下一次結果","cultivation.result",{"普通成功":"normal","富貴險求":"risky","極限成功":"extreme","走火入魔":"failure","破而後立":"rebirth"})
 var foundation := row(groups,"築基 · 下一次再築一品")
 for i in range(1,10):
  var grade: int = i
  action(foundation,"%d品成功" % i,func(): model.overrides.arm("foundation.result","grade%d" % grade))
 forces(groups,"築基崩塌","foundation.result",{"小崩":"small","大崩":"large","全崩":"full","破而後立":"rebirth"})
 forces(groups,"賭石 · 待對應層揭露後消耗；護符／催靈需選服務","stone.result",{"普通":"common","紫脈晶":"purple","金丹玉髓":"gold","天元晶心":"core","二層裂":"stage2","三層毀":"stage3","護符成功":"protected","護符失敗":"protection_failure","催靈稀有":"greed"})
 var stone := row(groups,"賭石結算測試（先開石）")
 action(stone,"就此收石",func(): model.debug_stone_settle(false))
 action(stone,"磨至取芯再收",func(): model.debug_stone_settle(true))
 forces(groups,"靈礦 · 下一格","mines.tile",{"安全":"safe","普通晶":"ordinary","稀有晶":"rare","煞氣":"danger","高獎後失敗":"high_failure"})
 var mine := row(groups,"靈礦即時結算")
 action(mine,"收取",func(): model.collect_mines())
 forces(groups,"靈舟 · 下一次推進","boat.next",{"早墜":"early","高倍墜毀":"high","安全前進一次":"safe","收取":"cashout"})
 var winners := {}
 for i in range(5): winners[model.E.RACE_NAMES[i]] = i
 winners["所選飛劍落敗"] = 5
 forces(groups,"飛劍 · 下一場勝者","race.winner",winners)
 label(groups,"舊音效已鎖回 ORIGINAL；新音色可在 SFX 評審室勾選並複製答題卡。")
 visible = false
func label(parent: Node, value: String) -> Label:
 var l := Label.new()
 l.text = value
 l.add_theme_font_size_override("font_size",22)
 l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 parent.add_child(l)
 return l
func row(parent: Node, title: String) -> GridContainer:
 label(parent,title)
 var r := GridContainer.new()
 r.columns = 5
 parent.add_child(r)
 return r
func action(parent: Node, title: String, callback: Callable):
 var b := Button.new()
 b.text = title
 b.custom_minimum_size = Vector2(330,55)
 b.add_theme_font_size_override("font_size",21)
 b.pressed.connect(func():
  if OS.is_debug_build():
   if title not in ["Clear All Overrides","返回測試 F10","SFX 評審室"]: model.begin_developer_test()
   callback.call()
  refresh())
 parent.add_child(b)
func forces(parent: Node, title: String, key: String, values: Dictionary):
 var r := row(parent,title)
 for text in values:
  var value: Variant = values[text]
  action(r,text,func(): model.overrides.arm(key,value))
func refresh():
 if not visible: return
 status.text = "F10 Developer Test Hub · 開啟時世界與活動暫停\n%s · 修為 %d/%d · 年齡 %.1f / 壽元 %.1f · 道基 %d品\nAuto %s · World PAUSED · 活動 %s · 靈石 %d\n票 %s · 原石 %s · 材料 %s · 碎片 %d · 丹 %s · 寶物 %s\n問劍 %d / %d（待觸發 %s）" % [model.C.REALMS[model.realm],model.cultivation,model.requirement(),model.age,model.lifespan,model.foundation_grade,"PAUSED" if model.auto_before_activity or model.auto_enabled else "OFF",model.activity_id,model.spirit_stones,str(model.tickets),str(model.raw_stones),str(model.materials),model.fragments,str(model.pills),str(model.treasures),model.duel_counter,model.duel_threshold,str(model.duel_due)]
 if audio_manager != null: status.text += "\n音效："+audio_manager.generated.diagnostic
 if model.developer_test_session: status.text += "\n測試中：不覆寫正式存檔；重新啟動恢復測試前進度。Reset Run 則開始並保存新一世。"
 active_label.text = "ACTIVE DEBUG OVERRIDES · 僅下一個相關操作\n"+ (str(model.overrides.active) if not model.overrides.active.is_empty() else "無")
