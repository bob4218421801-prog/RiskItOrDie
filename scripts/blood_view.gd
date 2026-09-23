extends Control
var relics: VBoxContainer
var point_choice: OptionButton
var model: RefCounted
var dialogue_panel: PanelContainer
var info: Label
var omen: Label
var omen_plate: Panel
var message: Label
var counter: Label
var left_bone: Control
var right_bone: Control
var roll_button: Button
var accept_button: Button
var reverse_left: Button
var reverse_right: Button
const JADE_SCENE=preload("res://assets/ui_v4/jade_scene.png")
const DEMONIC_SCENE=preload("res://assets/ui_v4/demonic_scene.png")
var time := 0.0
var theme_key:=""
var info_plate: Panel
var danger_plate: Panel
func _ready():
 name = "BloodFateArena"
 position = Vector2(90,70)
 size = Vector2(1740,930)
 mouse_filter = Control.MOUSE_FILTER_STOP
 var heading=label_at("魔道劫殺 · 血煞命局",Vector2(250,20),Vector2(1240,65),42);heading.name="ArenaTitle"
 var wallet_badge=preload("res://scripts/wallet_badge.gd").new();wallet_badge.model=model;wallet_badge.position=Vector2(1310,140);wallet_badge.size=Vector2(340,70);add_child(wallet_badge)
 info = label_at("",Vector2(485,133),Vector2(770,105),25)
 omen_plate=Panel.new();omen_plate.mouse_filter=MOUSE_FILTER_IGNORE;omen_plate.add_theme_stylebox_override("panel",preload("res://scripts/migration_art.gd").skin("dark_info",12));add_child(omen_plate)
 omen = label_at("",Vector2(500,345),Vector2(740,70),46)
 message = label_at("",Vector2(350,610),Vector2(1040,64),27)
 counter = label_at("",Vector2(350,682),Vector2(1040,45),23)
 dialogue_panel = preload("res://scripts/dialogue_panel.gd").new()
 dialogue_panel.position = Vector2(290,565);dialogue_panel.size.x = 1130;add_child(dialogue_panel)
 left_bone = preload("res://scripts/blood_bone.gd").new()
 right_bone = preload("res://scripts/blood_bone.gd").new()
 add_child(left_bone);add_child(right_bone)
 roll_button = button("定命",Vector2(695,775),Vector2(350,70),func(): model.blood_action("roll"))
 accept_button = button("認命",Vector2(670,850),Vector2(400,65),func(): model.blood_action("accept"))
 reverse_left = button("逆命 · 重擲左骨",Vector2(390,775),Vector2(430,70),func(): model.blood_action("reverse",0))
 reverse_right = button("逆命 · 重擲右骨",Vector2(920,775),Vector2(430,70),func(): model.blood_action("reverse",1))
 button("?",Vector2(1620,35),Vector2(65,65),func(): model.show_help("jade" if model.activity_id == "jade" else "blood"))
 info_plate=Panel.new();info_plate.position=Vector2(420,98);info_plate.size=Vector2(900,155);info_plate.mouse_filter=MOUSE_FILTER_IGNORE;add_child(info_plate);move_child(info_plate,0)
 danger_plate=Panel.new();danger_plate.position=Vector2(280,580);danger_plate.size=Vector2(1180,165);danger_plate.mouse_filter=MOUSE_FILTER_IGNORE;add_child(danger_plate);move_child(danger_plate,0)
 relics = VBoxContainer.new();relics.position = Vector2(1350,250);relics.size = Vector2(355,460);add_child(relics)
 relics.hide()
 for i in range(2):
  var side := i
  var target := button("",Vector2(560+i*420,478),Vector2(205,235),func(): model.choose_bone_target(side))
  target.name = "BoneTarget"+str(i)
 var cancel := button("取消選擇",Vector2(670,850),Vector2(400,65),func(): model.cancel_bone_target())
 cancel.name = "CancelBoneTarget"
 refresh()
func label_at(value: String, pos: Vector2, dimensions: Vector2, font_size: int) -> Label:
 var label := Label.new()
 label.text = value
 label.position = pos
 label.size = dimensions
 label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 label.add_theme_font_size_override("font_size",font_size)
 label.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(label)
 return label
func button(value: String, pos: Vector2, dimensions: Vector2, callback: Callable) -> Button:
 var b := Button.new()
 b.text = value
 b.position = pos
 b.size = dimensions
 b.add_theme_font_size_override("font_size",27)
 b.pressed.connect(func():
  if model.modal.is_empty(): callback.call())
 add_child(b)
 return b
func refresh():
 visible = model.activity_id in ["blood","jade"] and model.blood != null
 if not visible: return
 var b: RefCounted = model.blood
 var mode: String="jade" if b.practice else "demonic"
 if mode!=theme_key:
  theme_key=mode
  var art=preload("res://scripts/migration_art.gd")
  info_plate.add_theme_stylebox_override("panel",art.skin("plaque" if b.practice else "dark_info",18))
  danger_plate.add_theme_stylebox_override("panel",art.skin("dark_dialogue",18))
  for node in get_children():
   if node is Button:
    art.T.small(node)
    if not b.practice:
     for state in ["normal","hover","pressed","disabled","focus"]:
      var skin=art.skin("dark_button",15);skin.modulate_color=Color(1.2,1.12,1.12) if state=="hover" else Color.WHITE;node.add_theme_stylebox_override(state,skin)
   if node is Label:
    node.add_theme_color_override("font_color",Color("294d43") if b.practice else Color("f1dbc0"));node.add_theme_color_override("font_shadow_color",Color(0,0,0,.6));node.add_theme_constant_override("shadow_offset_y",1)
 danger_plate.visible=not b.practice
 omen.position.y=345 if b.practice else 535
 omen.size.y=70 if b.practice else 58
 omen.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 omen_plate.visible=not b.practice;omen_plate.position=Vector2(645,528);omen_plate.size=Vector2(450,70)
 omen.add_theme_font_size_override("font_size",46 if b.practice else 36)
 get_node("ArenaTitle").text = "演命玉骨 · 小師妹" if b.practice else model.sect.blood_title+" · "+model.sect.blood_name
 info.text = "定命 · 7、11 破阵 ｜ 2、3、12 锁命\n其余点数成为生门" if b.point == 0 else "【生門：%d】再擲出 %d → 破陣\n【七煞：7】先擲出 7 → 敗" % [b.point,b.point]
 relics.visible = false
 for i in range(2):
  var target: Button = get_node("BoneTarget"+str(i))
  target.position.y=478 if b.practice else 273
  target.visible = model.bone_target_pending
  target.text = "選這枚命骨"
 get_node("CancelBoneTarget").visible = model.bone_target_pending
 theme = preload("res://scripts/narrative_style.gd").theme() if theme == null and b.practice else theme
 omen.add_theme_color_override("font_outline_color",Color("122c32") if b.practice else Color("201410"))
 omen.add_theme_constant_override("outline_size",6 if b.practice else 0)
 omen.text = "命數：%d" % b.total if b.total > 0 else "命數未定"
 if b.phase == "seven": omen.text = "七煞臨身" if b.point > 0 else "凶煞鎖命"
 omen.modulate.a = lerpf(.3,1.0,1-b.left/b.duration) if b.phase == "seven" else 1.0
 omen.add_theme_color_override("font_color",(Color("fff0cb") if b.practice else Color("f0d2b4")) if b.total != 7 else (Color("fff0cb") if b.practice else Color("f7a08d")))
 message.text = "" if b.state == "result" else (b.message if b.practice else ("命骨停穩……" if b.phase in ["quiet","pause"] else b.message))
 if not b.preview.is_empty(): message.text = "偷天符 · 下一擲 %d、%d" % b.preview
 counter.text = "本局逆命已用" if b.reverse_used else "每局可逆命一次 · 费用 %d 灵石" % b.B.REVERSE_COST
 counter.visible = not b.practice
 message.visible = not b.practice
 dialogue_panel.visible = false # Unified CharacterDialogue owns NPC pages
 if dialogue_panel.visible: dialogue_panel.show_text("小師妹",b.message.trim_prefix("小師妹："))
 roll_button.visible = b.state == "ready"
 roll_button.text = "定命 · 擲下命骨" if b.point == 0 else "再擲命骨"
 if b.practice: roll_button.text = "擲下命骨" if b.rolls == 0 else "再擲命骨"
 reverse_left.visible = b.can_reverse()
 reverse_right.visible = b.can_reverse()
 var poor: bool = model.spirit_stones < b.B.REVERSE_COST
 reverse_left.disabled = poor
 reverse_right.disabled = poor
 reverse_left.text = "逆命 · 重擲左骨 [%d]%s" % [b.dice[0]," · 靈石不足" if poor else ""]
 reverse_right.text = "逆命 · 重擲右骨 [%d]%s" % [b.dice[1]," · 靈石不足" if poor else ""]
 accept_button.visible = b.state == "choice"
 accept_button.text = "認命" if b.total == 7 else "再擲命骨"
 if b.awaiting_judgement: accept_button.text = "就此定命"
 if model.bone_target_pending:
  roll_button.hide();accept_button.hide();reverse_left.hide();reverse_right.hide();message.show();message.text = "選一枚命骨逆命。"
 left_bone.jade = b.practice;right_bone.jade = b.practice
 animate_bone(left_bone,0)
 animate_bone(right_bone,1)
 queue_redraw()
func animate_bone(node: Control, index: int):
 var b: RefCounted = model.blood
 node.position = Vector2(660+index*420,610 if b.practice else 405)
 node.scale=Vector2.ONE
 node.rotation = 0
 node.number = b.visible_dice[index]
 if b.state != "rolling" or (b.reroll_side >= 0 and b.reroll_side != index): return
 var progress: float = clampf(1-b.left/maxf(.01,b.duration),0,1)
 var lift: float=95 if b.practice else 15
 if not b.practice: node.scale=Vector2.ONE*.78
 if b.phase == "rise": node.position.y -= lift*sin(progress*PI*.5)
 elif b.phase == "spin":
  node.position.y -= lift+sin(progress*PI)*(16 if b.practice else 3)
  node.rotation = progress*TAU*(1 if index == 0 else -1)
 elif b.phase == "fall": node.position.y -= lift*(1-progress*progress)
func _process(delta):
 time += delta
 if visible: refresh()
func _draw():
 if not visible: return
 draw_texture_rect(JADE_SCENE if model.blood.practice else DEMONIC_SCENE,Rect2(Vector2(-90,-70),Vector2(1920,1080)),false)
