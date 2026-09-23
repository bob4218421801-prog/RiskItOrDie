extends PanelContainer
const POLICY = preload("res://scripts/audio_policy.gd")
var manager: Node
var choices: Dictionary = {}
var status: Label
var preview_left := 0.0
func _ready():
 name = "SFXReviewRoom"
 position = Vector2(70,35)
 size = Vector2(1780,1005)
 var style := StyleBoxFlat.new()
 style.bg_color = Color("132632")
 style.border_color = Color("b8a576")
 style.set_border_width_all(2)
 style.content_margin_left = 18
 style.content_margin_right = 18
 style.content_margin_top = 12
 style.content_margin_bottom = 12
 add_theme_stylebox_override("panel",style)
 var rows := VBoxContainer.new()
 add_child(rows)
 status = Label.new()
 status.add_theme_font_size_override("font_size",27)
 status.text = "SFX 評審室 · 試聽與勾選不會更改遊戲音效"
 rows.add_child(status)
 var commands := HBoxContainer.new()
 rows.add_child(commands)
 add_button(commands,"複製我的選擇",copy_choices)
 add_button(commands,"停止試聽",func(): manager.generated.stop_preview())
 add_button(commands,"返回遊戲",close_room)
 var hint := Label.new()
 hint.text = "舊音效預設 ORIGINAL。新音效未選維持現況。只複製你勾選過的項目，之後貼給 Codex 採用。"
 hint.add_theme_font_size_override("font_size",23)
 rows.add_child(hint)
 var scroll := ScrollContainer.new()
 scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
 rows.add_child(scroll)
 var list := VBoxContainer.new()
 list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 scroll.add_child(list)
 var events: Array = manager.generated.catalog.duplicate()
 for key in POLICY.ALIASES: events.append({"event":key})
 for entry in events:
  var event: String = entry.event
  var line := HBoxContainer.new()
  list.add_child(line)
  var label := Label.new()
  label.text = event_title(event)+"  ·  "+event
  label.custom_minimum_size.x = 720
  label.add_theme_font_size_override("font_size",21)
  line.add_child(label)
  var group := ButtonGroup.new()
  for candidate in ["A","B","C"]:
   var letter: String = candidate
   add_button(line,candidate+" ▶",func(): audition(event,letter))
   var radio := CheckBox.new()
   radio.text = candidate
   radio.add_theme_font_size_override("font_size",22)
   radio.button_group = group
   radio.custom_minimum_size = Vector2(70,60)
   line.add_child(radio)
   radio.pressed.connect(func(): choices[event] = letter)
  if event in POLICY.ORIGINALS:
   add_button(line,"原音 ▶",func(): audition(event,"ORIGINAL"))
   var original := CheckBox.new()
   original.text = "ORIGINAL"
   original.add_theme_font_size_override("font_size",22)
   original.button_group = group
   original.button_pressed = true
   line.add_child(original)
   original.pressed.connect(func(): choices[event] = "ORIGINAL")
 add_button(rows,"複製我的選擇",copy_choices)
 hide()
func add_button(parent: Node, title: String, callback: Callable):
 var b := Button.new()
 b.text = title
 b.custom_minimum_size = Vector2(100,60)
 b.add_theme_font_size_override("font_size",22)
 b.pressed.connect(callback)
 parent.add_child(b)
func open_room():
 if not OS.is_debug_build(): return
 manager.handle_event("stop_all")
 manager.generated.preview.bus = "Master"
 manager.generated.preview.volume_db = -10
 show()
func close_room():
 manager.generated.stop_preview()
 manager.generated.preview.bus = "SFX"
 hide()
func audition(event: String, candidate: String):
 if not OS.is_debug_build(): return
 var preview: AudioStreamPlayer = manager.generated.preview
 preview.stop()
 preview.bus = "Master"
 preview.stream = manager.streams.get(event) if candidate == "ORIGINAL" else manager.generated.read_stream(manager.generated.latest(event,candidate))
 if preview.stream == null:
  status.text = "此事件沒有可用音檔："+event
  return
 preview.play()
 preview_left = minf(4.0,preview.stream.get_length()+.1)
 status.text = "正在試聽："+event_title(event)+" / "+candidate+" · 尚未更改遊戲 mapping"
func selection_text() -> String:
 var lines: Array[String] = ["SFX_SELECTIONS"]
 var keys := choices.keys()
 keys.sort()
 for key in keys: lines.append(str(key)+"="+str(choices[key]))
 return "\n".join(lines)
func copy_choices():
 DisplayServer.clipboard_set(selection_text())
 status.text = "已複製 %d 項選擇；貼給 Codex 後再更新正式音效。" % choices.size()
func _process(delta):
 if not visible: return
 preview_left -= delta
 if preview_left <= 0: manager.generated.stop_preview()
func event_title(event: String) -> String:
 var named := {"duel_double":"孤注一劍","blood_arrival":"魔道劫殺","blood_bone":"命骨落地","blood_seven":"七煞臨身","blood_gate":"生門重現","blood_reverse":"逆命","boat_launch":"靈舟起飛","boat_flight_loop":"靈舟高速飛行","boat_crash":"靈舟墜毀","boat_cashout":"靈舟收取","duel_draw":"問劍出劍","duel_21":"劍勢圓滿","duel_natural21":"天命一劍","foundation_charge":"引台承壓","foundation_impact":"道台重砸","foundation_complete":"道基穩固","foundation_collapse":"道台崩碎","foundation_rebirth":"築基破而後立","alchemy_reforge":"煉丹再淬","alchemy_low_loop":"文火爐聲","alchemy_medium_loop":"丹火爐聲","alchemy_high_loop":"猛火爐壓","furnace_explosion":"煉丹炸爐","tournament_champion":"大比魁首"}
 named.merge({"cultivation_charge": "修煉蓄氣", "cultivation_good_release": "修煉穩妥收功", "cultivation_risky_release": "修煉冒險收功", "cultivation_extreme_release": "修煉極限收功", "cultivation_failure": "走火入魔", "cultivation_rebirth": "修煉破而後立", "realm_breakthrough": "境界突破", "foundation_fall": "道台落下", "foundation_crack": "道台裂痕", "boat_danger": "靈舟危險", "sword_race_start": "飛劍開賽", "sword_race_flyby": "飛劍掠過", "sword_race_overtake": "飛劍超越", "sword_race_finish": "飛劍抵達", "sword_race_win": "飛劍勝出", "sword_race_lose": "飛劍惜敗", "mines_reveal": "靈礦開掘", "mines_ordinary": "普通晶石", "mines_rare": "稀有晶石", "mines_danger": "礦脈危險", "mines_failure": "礦脈崩塌", "mines_cashout": "晶石收取", "stone_scratch_loop": "磨除石皮", "stone_reveal": "石皮揭露", "stone_crack": "原石裂紋", "stone_rare_reveal": "稀有芯脈", "stone_shatter": "原石碎裂", "stone_protection": "護石符生效", "stone_collect": "原石結算", "alchemy_unstable": "爐壓警告", "alchemy_open": "普通丹成", "alchemy_upper": "上品丹成", "duel_arrival": "劍修登門", "duel_pressure": "劍勢壓迫", "duel_round_win": "問劍回合勝", "duel_round_lose": "問劍回合負", "duel_bust": "劍勢崩潰", "duel_match_win": "問劍全場勝", "duel_match_lose": "問劍全場負", "duel_treasure": "護道寶物", "ui_confirm": "操作確認", "ui_cancel": "操作返回", "feature_unlock": "功能解鎖", "opportunity_notice": "機緣出現", "ticket_obtained": "獲得機緣票", "shop_purchase": "商店購買", "result_confirm": "結果確認"})
 if named.has(event): return named[event]
 return event.replace("cultivation_","修煉 · ").replace("rebirth_","破而後立 · ").replace("mines_","靈礦 · ").replace("mine_","靈礦 · ").replace("stone_","解石 · ").replace("duel_","問劍 · ").replace("alchemy_","煉丹 · ").replace("sword_race_","飛劍競速 · ")
