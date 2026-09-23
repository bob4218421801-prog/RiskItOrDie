extends Button
# Hit silhouette is independent of visual animation and disabled modulation.
var hit_mask: BitMap
func set_hit_texture(texture: Texture2D) -> void:
 hit_mask=BitMap.new()
 hit_mask.create_from_image_alpha(texture.get_image(),0.12)
func _has_point(point: Vector2) -> bool:
 if not Rect2(Vector2.ZERO,size).has_point(point): return false
 if hit_mask==null: return true
 var dimensions:=hit_mask.get_size()
 var pixel:=Vector2i(point/size*Vector2(dimensions))
 return hit_mask.get_bitv(pixel)
func _get_tooltip(_at_position: Vector2) -> String:
 return ""

var visual_scale:=1.0
var press_tween: Tween
var feedback_ready:=false
func setup_feedback() -> void:
 if feedback_ready:return
 feedback_ready=true
 tooltip_text=""
 var press_material:=ShaderMaterial.new();press_material.shader=preload("res://scripts/button_press.gdshader");material=press_material
 press_material.set_shader_parameter("press_scale",1.0)
 press_material.set_shader_parameter("control_center",size*.5)
 resized.connect(func(): press_material.set_shader_parameter("control_center",size*.5))
 button_down.connect(func(): animate_press(.97,.07))
 button_up.connect(func(): animate_press(1.0,.14))
 mouse_exited.connect(func(): animate_press(1.0,.14))
func animate_press(target: float, seconds: float) -> void:
 if press_tween!=null and press_tween.is_valid():press_tween.kill()
 press_tween=create_tween();press_tween.tween_method(func(value: float): visual_scale=value;material.set_shader_parameter("press_scale",value),visual_scale,target,seconds).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
func _ready(): setup_feedback()
