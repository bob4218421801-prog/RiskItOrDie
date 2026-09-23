extends Control
## Notifications survive mouse-down and expire after two completed attempts.
signal notification_sound
signal ui_confirm
var model: RefCounted
var toast: PanelContainer
var notice: Label
var toast_active:=false
var toast_pending:=false
var toast_elapsed:=0.0
var queue: Array[Dictionary]=[]
var current: Dictionary={}
var seen_run:=-1
var blocked:=false
var active: Dictionary={}
var last_message:=""
var fading:=false
var fade_clock:=0.0
func _ready():
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);mouse_filter=MOUSE_FILTER_IGNORE;z_index=15
 toast=PanelContainer.new();toast.position=Vector2(410,130);toast.size=Vector2(790,100);toast.mouse_filter=MOUSE_FILTER_IGNORE;add_child(toast)
 var skin:=StyleBoxTexture.new();skin.texture=load("res://assets/ui_v4/plaque.png");skin.content_margin_left=90;skin.content_margin_right=90;skin.content_margin_top=55;skin.content_margin_bottom=35;toast.add_theme_stylebox_override("panel",skin)
 notice=Label.new();notice.add_theme_font_size_override("font_size",25);notice.add_theme_color_override("font_color",Color("253f38"));notice.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;notice.mouse_filter=MOUSE_FILTER_IGNORE;toast.add_child(notice);toast.hide()
func sync(debug_open: bool):
 blocked=debug_open
 if seen_run!=model.run_serial: seen_run=model.run_serial;active.clear();last_message=""
 for event in model.take_notifications():
  active[event.kind]={"expires":model.attempts+2,"count":event.count};fading=false;toast_elapsed=0.0;notification_sound.emit()
 var message: String=model.sect.reaction
 if message.is_empty(): last_message=""
 if model.sect.C.ENABLE_JUNIOR_REMINDERS and model.sect.junior_met and not message.is_empty() and message!=last_message:
  active["sect"]={"expires":model.attempts+2,"count":0};last_message=message;fading=false;toast_elapsed=0
 if not model.sect.C.ENABLE_JUNIOR_REMINDERS: active.erase("sect")
 for key in active.keys():
  if model.attempts>=active[key].expires: active.erase(key)
 if active.is_empty() and toast_active: fading=true;fade_clock=0
 var lines: PackedStringArray=[]
 for key in active:
  if key=="sect": lines.append("【宗门传讯】小师妹有话想对你说。")
  else: lines.append({"flying_boat":"【机缘】灵舟经过，可免费登船。","sword_race":"【机缘】飞剑开赛，可免费观赛。","mines":"【机缘】灵矿开放，可免费开采。"}.get(key,"【机缘】新的机缘已经到来。"))
 if not lines.is_empty(): notice.text="\n".join(lines)
 toast_active=not active.is_empty();toast_pending=false
 toast.visible=(toast_active or fading) and model.activity_id.is_empty() and model.state in ["idle","holding","presenting"] and model.modal.is_empty() and not blocked
func advance(delta: float):
 if not toast.visible: return
 if fading:
  fade_clock+=delta;toast.modulate.a=maxf(0,1-fade_clock/.35)
  if fade_clock>=.35: fading=false;toast.hide()
 else: toast_elapsed+=delta;toast.modulate.a=minf(1,toast_elapsed/.25)
func dismiss_toast():
 active.clear();toast_active=false;toast.hide()
