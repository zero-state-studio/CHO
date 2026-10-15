// Toon shading a bande per i personaggi gommosi (renderer Compatibility).
// Il colore arriva dai vertici (sRGB); il canale alfa del colore è la lucentezza:
// 0 = gomma opaca, 1 = giacca lucida. Il contorno è un secondo passaggio (next_pass).
shader_type spatial;
render_mode cull_back;

// Numero di bande di luce.
uniform int bands : hint_range(2, 4) = 3;
// Luminosità minima della luce diretta nella parte in ombra.
uniform float shadow_floor : hint_range(0.0, 1.0) = 0.25;
// Dimensione del riflesso lucido (più vicino a 1 = più piccolo).
uniform float gloss_size : hint_range(0.5, 1.0) = 0.93;
uniform float gloss_strength : hint_range(0.0, 2.0) = 0.7;

varying float gloss;

vec3 srgb_to_linear(vec3 color) {
	return mix(pow((color + vec3(0.055)) * (1.0 / 1.055), vec3(2.4)), color * (1.0 / 12.92),
			lessThan(color, vec3(0.04045)));
}

void vertex() {
	gloss = COLOR.a;
}

void fragment() {
	ALBEDO = srgb_to_linear(COLOR.rgb);
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;
}

void light() {
	float lit = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION;
	float stepped = ceil(lit * float(bands)) / float(bands);
	DIFFUSE_LIGHT += mix(shadow_floor, 1.0, stepped) * LIGHT_COLOR / PI;
	vec3 half_vector = normalize(VIEW + LIGHT);
	float highlight = step(gloss_size, dot(NORMAL, half_vector)) * ATTENUATION;
	SPECULAR_LIGHT += highlight * gloss * gloss_strength * LIGHT_COLOR / PI;
}
