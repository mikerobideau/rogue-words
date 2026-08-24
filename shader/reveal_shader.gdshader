shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 1.0;
uniform vec2 origin = vec2(0.0, 0.5);     // UV point where growth begins
uniform vec2 direction = vec2(1.0, 0.0);  // growth direction in UV space
uniform float softness = 0.06;            // soft growing edge

void fragment() {
	float d = dot(UV - origin, normalize(direction));
	float reveal = 1.0 - smoothstep(progress - softness, progress, d);
	COLOR.a *= reveal;
}