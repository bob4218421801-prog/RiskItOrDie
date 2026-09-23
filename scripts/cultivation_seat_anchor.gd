extends Marker2D
## Calibration in background UV space, shared by the seated actor and all VFX.
@export var background_uv := Vector2(0.482421875, 0.808159722)
@export var seated_root_uv := Vector2(0.5, 0.82)
@export var dantian_uv := Vector2(0.5, 0.62)
@export var reference_draw_size := Vector2(360,360)
var draw_size := Vector2(360,360)
func place_in(frame: Rect2) -> void:
 position = frame.position + frame.size * background_uv
 draw_size = reference_draw_size * (frame.size.x / 1920.0)
func actor_rect(offset: Vector2 = Vector2.ZERO) -> Rect2:
 return Rect2(position - seated_root_uv * draw_size + offset,draw_size)
func dantian_position(offset: Vector2 = Vector2.ZERO) -> Vector2:
 return position + (dantian_uv-seated_root_uv)*draw_size + offset
func contact_position() -> Vector2:
 return position
