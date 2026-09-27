shader_type canvas_item;
uniform sampler2D screen: hint_screen_texture;

void fragment() {
	vec3 sample = texture(screen, UV).rgb;
	if (sample.b == 0.) {
		float scaling = (sample.r - 0.6) / (1. - 0.6);
		sample *= 1. / sample.r;
		sample += (vec3(1) - sample) * pow(scaling, 4.) * 0.6;
	}
	COLOR.rgb = sample;
}