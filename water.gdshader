shader_type spatial;
render_mode unshaded, cull_disabled;
// also stolen from a different project and modified

float random(vec2 uv) {
    return mod(float(int(uv.x * 9137152.495) ^ int(uv.y * 3138278.634)), 89.) / 89.;
}

void vertex() {
	VERTEX.y = sin(TIME + random(UV) * TAU) * 0.4;
}

void fragment() {
	ALBEDO = vec3(0., 0., 1.);
	ALPHA = 0.4;
}