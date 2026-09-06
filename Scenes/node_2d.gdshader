shader_type canvas_item;

uniform vec2 player_screen_pos;
uniform vec2 firefly_screen_pos;
uniform float player_radius : hint_range(0.0, 1000.0) = 150.0;
uniform float firefly_radius : hint_range(0.0, 1000.0) = 80.0;
uniform float edge_softness : hint_range(0.0, 200.0) = 40.0;
uniform vec4 fog_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec2 pixel_pos = FRAGCOORD.xy;

	float dist_player = distance(pixel_pos, player_screen_pos);
	float dist_firefly = distance(pixel_pos, firefly_screen_pos);

	// 0 = fully visible (inside radius), 1 = fully fogged
	float player_vis = smoothstep(player_radius - edge_softness, player_radius, dist_player);
	float firefly_vis = smoothstep(firefly_radius - edge_softness, firefly_radius, dist_firefly);

	// Combine: visible if inside EITHER radius
	float fog_alpha = min(player_vis, firefly_vis);

	COLOR = vec4(fog_color.rgb, fog_color.a * fog_alpha);
}