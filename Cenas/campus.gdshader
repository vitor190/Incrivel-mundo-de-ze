shader_type canvas_item;

void fragment() {
    vec2 center = vec2(0.5);
    float dist = distance(UV, center);

    // corta fora do círculo
    if (dist > 0.5) {
        discard;
    }

    // cria borda
    float border_inner = 0.49
	;
    float border_outer = 0.5;

    if (dist > border_inner) {
        COLOR.rgb = vec3(0.0); // preto
    }
}