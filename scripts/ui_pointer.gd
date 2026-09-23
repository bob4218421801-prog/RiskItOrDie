extends Node
const CURSORS=[preload("res://assets/ui_v6/cursor_0.png"),preload("res://assets/ui_v6/cursor_1.png"),preload("res://assets/ui_v6/cursor_2.png"),preload("res://assets/ui_v6/cursor_3.png")]
var previous:=-1
func _ready():
 process_mode=Node.PROCESS_MODE_ALWAYS
 get_tree().node_added.connect(func(node):
  if node is Control: node.tooltip_text=""
  if node is Button: decorate.call_deferred(node))
func _process(_delta):
 var hovered=get_viewport().gui_get_hovered_control()
 var button: BaseButton
 while hovered!=null:
  if hovered is BaseButton: button=hovered;break
  hovered=hovered.get_parent() as Control
 var state:=0
 if button!=null: state=3 if button.disabled else 2 if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) else 1
 if state==previous:return
 previous=state
 for shape in [Input.CURSOR_ARROW,Input.CURSOR_POINTING_HAND,Input.CURSOR_FORBIDDEN]: Input.set_custom_mouse_cursor(CURSORS[state],shape,Vector2(3,3))
func _exit_tree():
 for shape in [Input.CURSOR_ARROW,Input.CURSOR_POINTING_HAND,Input.CURSOR_FORBIDDEN]: Input.set_custom_mouse_cursor(null,shape)

func decorate(button: Button) -> void:
 if not is_instance_valid(button):return
 if button.get_script()==null:button.set_script(preload("res://scripts/art_hit_button.gd"))
 if button.has_method("setup_feedback"):button.setup_feedback()
