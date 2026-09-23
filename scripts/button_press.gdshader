shader_type canvas_item;
uniform vec2 control_center;
uniform float press_scale=1.0;
void vertex(){VERTEX=(VERTEX-control_center)*press_scale+control_center;}
