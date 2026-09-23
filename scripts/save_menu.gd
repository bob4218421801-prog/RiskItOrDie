extends CanvasLayer
const ART=preload("res://scripts/migration_art.gd")
const STORE=preload("res://scripts/session_store.gd")
const ARCHIVE=preload("res://scripts/save_archive.gd")
var host: Control
var surface: Control
var message: Label
var continuation: Button
var confirmation:=""
var startup:=false
func _ready():
 layer=90;process_mode=Node.PROCESS_MODE_ALWAYS
 surface=Control.new();surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);surface.mouse_filter=Control.MOUSE_FILTER_STOP;add_child(surface)
 var center:=CenterContainer.new();center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);surface.add_child(center)
 var panel:=PanelContainer.new();panel.custom_minimum_size=Vector2(760,820);panel.add_theme_stylebox_override("panel",ART.skin("frame",112));center.add_child(panel)
 var column:=VBoxContainer.new();column.add_theme_constant_override("separation",16);panel.add_child(column)
 var title:=ART.label("修行存档",38);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;column.add_child(title)
 message=ART.label("",22);message.custom_minimum_size=Vector2(530,100);message.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;column.add_child(message)
 continuation=action(column,"继续游戏",close)
 action(column,"保存",func(): capture_settings();continuation.disabled=not STORE.save_run(host.run,host.run.persistence_path);message.text=ARCHIVE.status.get(host.run.persistence_path,"保存失败"))
 action(column,"读取存档",func():
  if confirmation!="load": confirmation="load";message.text="读取将替换当前进度。再次点击读取确认。";return
  if STORE.load_run(host.run,host.run.persistence_path): apply_settings();invalidate_views();host.sync_ui();confirmation="";close()
  else: message.text=ARCHIVE.status.get(host.run.persistence_path,"读取失败"))
 action(column,"新游戏 / 重置存档",func():
  if confirmation!="new": confirmation="new";message.text="再次点击确认开始新游戏。旧存档将归档保留。";return
  if not ARCHIVE.reset(host.run.persistence_path): message.text="旧存档归档失败，未重置。";return
  host.reset_run();STORE.fill(host.run,STORE.encode(host.run.get_script().new()).fields,false);invalidate_views();capture_settings();STORE.save_run(host.run,host.run.persistence_path);close())
 action(column,"修复存档（保留原文件）",func():
  if not ARCHIVE.blocked.get(host.run.persistence_path,false): message.text="当前存档无需修复。";return
  if confirmation!="repair": confirmation="repair";message.text="将归档损坏文件，并保存当前恢复的进度。再次点击确认。";return
  if ARCHIVE.reset(host.run.persistence_path): capture_settings();STORE.save_run(host.run,host.run.persistence_path);message.text="已保存恢复的进度；原文件已归档。";continuation.disabled=false)
 surface.hide()
 apply_settings()
func action(parent: Node, title: String, callback: Callable) -> Button:
 var b:=Button.new();b.text=title;b.custom_minimum_size=Vector2(480,64);b.size_flags_horizontal=Control.SIZE_SHRINK_CENTER;ART.T.small(b);parent.add_child(b);b.pressed.connect(callback);return b
func capture_settings():
 host.run.settings_data={"language":get_node("/root/UiLocale").tag,"sound_enabled":host.sound_enabled,"master_volume":AudioServer.get_bus_volume_linear(0)}
func apply_settings():
 var data: Dictionary=host.run.settings_data
 host.sound_enabled=data.get("sound_enabled",true);AudioServer.set_bus_volume_linear(0,clampf(data.get("master_volume",1.0),0,1));get_node("/root/UiLocale").set_language(data.get("language","zh-Hans"))
func open(initial: bool=false):
 startup=initial;confirmation="";surface.show();get_tree().paused=true
 continuation.disabled=initial and not ARCHIVE.read(host.run.persistence_path).ok and not ARCHIVE.read(host.run.persistence_path+".bak").ok
 message.text=ARCHIVE.status.get(host.run.persistence_path,"保存真实修行进度、物品、剧情和设置。")
 if host.run.state=="holding": host.run.focus_paused=true
func close():
 surface.hide();get_tree().paused=false;host.sync_ui()
func invalidate_views():
 host.seen_history=-1;host.seen_serial=-1;host.home.forecast_stamp="";host.inventory_drawer.stamp="";host.activity_view.view_key="";host.character_dialogue.dismissed.clear()
