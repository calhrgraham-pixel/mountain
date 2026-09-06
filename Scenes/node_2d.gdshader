shader_type canvas_item;

uniform vec2 player_screen_pos;
uniform vec2 firefly_screen_pos;
uniform float player_radius : hint_range(0.0, 1000.0) = 150.0;
uniform float firefly_radius : hint_range(0.0, 1000.0) = 80.0;
uniform float edge_softness : hint_range(0.0, 200.0) = 60.0;
uniform vec4 fog_color : source_color = vec4(0.05, 0.08, 0.12, 0.92);
uniform float noise_scale : hint_range(0.001, 0.05) = 0.008;
uniform float noise_strength : hint_range(0.0, 100.0) = 40.0;
uniform float scroll_speed : hint_range(0.0, 1.0) = 0.05;

// Simple value noise (no texture needed)
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Layered noise for a more organic, billowy look
float fbm(vec2 p) {
	float total = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 4; i++) {
		total += noise(p) * amp;
		p *= 2.0;
		amp *= 0.5;
	}
	return total;
}

void fragment() {
	vec2 pixel_pos = FRAGCOORD.xy;

	// Drifting noise offset for the fog "swirl"
	vec2 drift = vec2(TIME * scroll_speed * 20.0, TIME * scroll_speed * 10.0);
	float n = fbm(pixel_pos * noise_scale + drift);

	// Distort the distance check with noise so circle edges look wispy, not perfectly round
	vec2 player_offset = (pixel_pos - player_screen_pos);
	vec2 firefly_offset = (pixel_pos - firefly_screen_pos);

	float dist_player = length(player_offset) + (n - 0.5) * noise_strength;
	float dist_firefly = length(firefly_offset) + (n - 0.5) * noise_strength;

	float player_vis = smoothstep(player_radius - edge_softness, player_radius, dist_player);
	float firefly_vis = smoothstep(firefly_radius - edge_softness, firefly_radius, dist_firefly);

	float fog_alpha = min(player_vis, firefly_vis);

	// Vary fog density slightly with noise even in the "fully fogged" zone, for texture
	float density_variation = 0.85 + n * 0.3;

	COLOR = vec4(fog_color.rgb, fog_color.a * fog_alpha * density_variation);
}