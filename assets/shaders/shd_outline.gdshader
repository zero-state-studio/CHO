// Contorno a scafo invertito, a spessore costante sullo schermo: la mesh gonfiata
// lungo le normali in spazio clip, vista solo dal retro. Resta visibile a ogni zoom.
shader_type spatial;
render_mode unshaded, cull_front;

uniform vec4 outline_color : source_color = vec4(0.08, 0.07, 0.1, 1.0);
// Spessore del contorno, in pixel.
uniform float outline_pixels : hint_range(0.0, 8.0) = 2.5;

void vertex() {
	vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 view_normal = normalize(MODELVIEW_NORMAL_MATRIX * NORMAL);
	vec2 clip_normal = (PROJECTION_MATRIX * vec4(view_normal, 0.0)).xy;
	if (length(clip_normal) > 0.0001) {
		clip_position.xy += normalize(clip_normal) / VIEWPORT_SIZE * outline_pixels * 2.0 * clip_position.w;
	}
	POSITION = clip_position;
}

void fragment() {
	ALBEDO = outline_color.rgb;
}
