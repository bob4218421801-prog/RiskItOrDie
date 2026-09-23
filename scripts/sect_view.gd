extends RefCounted
static func build(v):
 var m = v.model;var s = m.sect
 match m.activity_id:
  "sect":
   v.text(v.body,"宗門",38)
   if not s.returned.is_empty(): v.text(v.body,s.returned,23)
   if v.sect_destination.is_empty():
    var map = preload("res://scripts/sect_map.gd").new();map.model = m;v.body.add_child(map)
    map.destination_selected.connect(func(place): v.sect_destination = place;v.view_key = "";v.refresh())
    cards(v)
    return
   v.button(v.body,"返回宗門地圖",func(): v.sect_destination = "";v.view_key = "")
   var people := HBoxContainer.new();v.body.add_child(people)
   for npc in ["師父","小師妹","大師姐"]:
    if npc != v.sect_destination: continue
    if npc == "小師妹" and not s.junior_met: continue
    if npc == "大師姐" and not s.senior_met: continue
    var person: String = npc
    var col := VBoxContainer.new();col.size_flags_horizontal = Control.SIZE_EXPAND_FILL;people.add_child(col)
    v.text(col,npc+(" · "+s.stage() if npc == "小師妹" else ""),29)
    var important: bool = (npc == "小師妹" and ((s.affection >= s.C.AFFECTION_STAGES[1] and not s.seen.has("junior_close")) or (s.affection >= s.C.AFFECTION_STAGES[2] and not s.seen.has("junior_gift")))) or (npc == "大師姐" and m.realm > s.senior_realm_seen and m.realm in s.C.SENIOR_REALM)
    if s.present(npc,m.attempts) or important:
     v.button(col,"聊聊"+(" · 有話想說" if important or (npc == "小師妹" and not s.reaction.is_empty()) else ""),func(): s.talk(m,person))
     if npc == "小師妹":
      v.button(col,"演命玉骨",func(): s.start_jade(m))
      if s.duel_taught: v.button(col,"問劍切磋",func(): s.start_junior_spar(m))
     if npc == "大師姐": v.button(col,"找她切磋",func(): s.start_senior(m))
    else:
     v.text(col,s.away_reason.get(npc,"外出歷練"),24)
     v.text(col,"她一早便出了山門，桌上還放著沒收好的玉骨。" if npc == "小師妹" else ("劍坪無人，只留下幾道尚未散去的劍痕。" if npc == "大師姐" else "師父正在閉關，過幾次修煉再來。"),22)
   if v.sect_destination != "俸祿堂":
    cards(v)
    return
   v.body.add_child(HSeparator.new())
   v.text(v.body,"宗門俸祿 · 待領 %d 期" % s.stipends.size(),29)
   if not s.stipends.is_empty():
    v.text(v.body,"本期 %d 靈石" % s.stipends[0],25)
    var row := VBoxContainer.new();row.add_theme_constant_override("separation",14);v.body.add_child(row)
    v.button(row,"安穩領取\n直接收下本期 %d 靈石" % s.stipends[0],func(): s.stipend(m,false)).custom_minimum_size.y = 105
    v.button(row,"去骰桌試試手氣\n拿本期俸祿玩一局骰寶",func(): s.stipend(m,true)).custom_minimum_size.y = 105
   else: v.text(v.body,"下一期還有 %.1f 年" % maxf(0,s.stipend_cursor+s.C.STIPEND_YEARS-m.age),23)
   v.text(v.body,"每兩年一期，最多留三期。",22)
   cards(v)
  "pavilion":
   v.text(v.body,"天機閣 · 秘術與禁物",38)
   v.text(v.body,"天機券 %d · 可兌換罕見秘術與禁物" % s.inventory.get("天機券",0),26).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
   var list=v.centered_column(v.body,1120)
   for key in s.C.RELICS:
    var item: String=key
    var row:=HBoxContainer.new();row.add_theme_constant_override("separation",48);list.add_child(row)
    var copy:=VBoxContainer.new();copy.custom_minimum_size.x=700;copy.size_flags_horizontal=Control.SIZE_EXPAND_FILL;copy.add_theme_constant_override("separation",8);row.add_child(copy)
    v.text(copy,key,30)
    v.text(copy,s.C.RELIC_HELP[key],24)
    var b=v.button(row,"兌換 · %d天機券　持有 %d" % [s.C.RELICS[key],s.inventory.get(key,0)],func(): s.buy(m,item));b.size_flags_vertical=Control.SIZE_SHRINK_CENTER
    b.disabled=s.inventory.get("天機券",0)<s.C.RELICS[key]
   v.text(v.body,"金丹神通體驗券 %d · 留待結丹後使用" % s.inventory.get("金丹神通體驗券",0),23).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  "sicbo":
   v.text(v.body,"宗門骰寶",38)
   var b = m.sicbo
   if b.state == "ready":
    v.text(v.body,"選一注，擲三骰。豹子出現，大小與單雙全輸。",26)
    if s.stipends.is_empty(): v.text(v.body,"俸祿已領完，下期再來。",27);return
    v.text(v.body,"本期俸祿 %d 靈石" % s.stipends[0],27)
    var row := HBoxContainer.new();v.body.add_child(row)
    for name in ["大","小","單","雙","任意豹子","指定總點數"]:
     var bet: String = name
     var choice = v.button(row,("✓ " if b.bet_selected and b.bet == name else "")+name,func(): b.bet = bet;b.bet_selected = true;v.view_key = "")
     choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    if b.bet_selected and b.bet == "指定總點數":
     v.text(v.body,"指定總點數 · 我要押：",28)
     var exact := HBoxContainer.new();v.body.add_child(exact)
     v.button(exact,"◀",func(): b.target = maxi(3,b.target-1);v.view_key = "").custom_minimum_size.x = 96
     var total_label = v.text(exact,str(b.target),36);total_label.custom_minimum_size.x = 120;total_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
     v.button(exact,"▶",func(): b.target = mini(18,b.target+1);v.view_key = "").custom_minimum_size.x = 96
     v.text(v.body,"三骰總點數可選 3～18",23)
    if b.bet_selected:
     var multiplier: int = s.C.SICBO_TOTAL[b.target] if b.bet == "指定總點數" else s.C.SICBO_PAYOUT[b.bet]
     v.text(v.body,"下注：%d 靈石\n若命中，預計淨贏：%d 靈石" % [s.stipends[0],s.stipends[0]*(multiplier-1)],29)
     v.button(v.body,"押定 · 擲骰",func(): s.start_sicbo(m,b.bet,b.target))
    else: v.text(v.body,"先選一注，再擲骰。",26)
   else:
    v.text(v.body,"小師妹押了豹子" if b.demo else "你的選擇："+b.bet,29)
    var row := HBoxContainer.new();row.name = "DiceRow";row.custom_minimum_size.y = 240;v.body.add_child(row)
    for i in range(3):
     var die = preload("res://scripts/sicbo_die.gd").new();die.order = i;row.add_child(die)
    v.text(v.body,"三枚玉骰逐一落定……",27)
static func cards(v):
 var s = v.model.sect
 if s.card_choices > 0:
  v.text(v.body,"大比獎勵 · 還可選 %d 張" % s.card_choices,27)
  var row := HBoxContainer.new();v.body.add_child(row)
  for key in s.C.CARDS:
   var item: String = key
   v.button(row,key,func(): s.choose_card(v.model,item))
