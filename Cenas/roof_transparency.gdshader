shader_type canvas_item;

uniform vec2 player_position = vec2(0.0);
uniform float radius : hint_range(0.0, 1000.0) = 90.0;
uniform float softness : hint_range(0.0, 500.0) = 50.0;
uniform float min_alpha : hint_range(0.0, 1.0) = 0.35;
uniform float effect_strength : hint_range(0.0, 1.0) = 0.0;

uniform bool use_collision_mask = false;
uniform sampler2D collision_mask : filter_nearest, repeat_disable;
uniform vec2 mask_origin_tiles = vec2(0.0);
uniform vec2 mask_size_tiles = vec2(1.0, 1.0);
uniform vec2 tile_size_local = vec2(16.0, 16.0);

varying vec2 world_pos;
varying vec2 local_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	local_pos = VERTEX;
}

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	float dist = distance(world_pos, player_position);
	float outside = smoothstep(radius - softness, radius, dist);
	float alpha_factor = mix(min_alpha, 1.0, outside);
	alpha_factor = mix(1.0, alpha_factor, effect_strength);

	if (use_collision_mask) {
		vec2 tile_coord = local_pos / tile_size_local;
		vec2 mask_uv = (tile_coord - mask_origin_tiles) / mask_size_tiles;
		if (mask_uv.x >= 0.0 && mask_uv.x < 1.0 && mask_uv.y >= 0.0 && mask_uv.y < 1.0) {
			float has_collision = texture(collision_mask, mask_uv).r;
			if (has_collision > 0.5) {
				alpha_factor = 1.0;
			}
		}
	}

	col.a *= alpha_factor;
	COLOR = col;
}
