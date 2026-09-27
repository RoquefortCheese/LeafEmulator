shader_type spatial;

void fragment() {
	vec2 point = (INV_VIEW_MATRIX * vec4(VERTEX, 1.)).xz;
	bool lightsquare = bool(int(floor(point.x) + floor(point.y)) % 2);
	ALBEDO.rgb = vec3(lightsquare ? 1. : 0.875);
}