shader_type canvas_item;
render_mode blend_add;

uniform vec4 laser_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float width = 1.0;

void fragment() {
	float dist = abs(UV.y - 0.5);
	float fade = smoothstep(0.0, width, dist);
	COLOR = vec4(laser_color.rgb, 1.0 - fade);
}
