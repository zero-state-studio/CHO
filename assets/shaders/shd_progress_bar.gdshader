// Barra di avanzamento 3D: un quad sempre rivolto alla telecamera, disegnato sopra
// la scena. La parte piena va da sinistra fino a "progress".
shader_type spatial;
render_mode unshaded, cull_disabled, depth_test_disabled, shadows_disabled;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 fill_color : source_color = vec4(0.3, 0.85, 0.4, 1.0);
uniform vec4 back_color : source_color = vec4(0.12, 0.12, 0.16, 0.85);
uniform vec4 border_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// Spessore del bordo, in frazione dell'altezza.
uniform float border : hint_range(0.0, 0.5) = 0.15;

void vertex() {
	// Billboard: mantiene posizione e scala del nodo, orientato come la telecamera.
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			INV_VIEW_MATRIX[0] * length(MODEL_MATRIX[0].xyz),
			INV_VIEW_MATRIX[1] * length(MODEL_MATRIX[1].xyz),
			INV_VIEW_MATRIX[2] * length(MODEL_MATRIX[2].xyz),
			MODEL_MATRIX[3]);
}

void fragment() {
	float aspect = 4.0;
	vec2 edge = vec2(border / aspect, border);
	bool is_border = UV.x < edge.x || UV.x > 1.0 - edge.x || UV.y < edge.y || UV.y > 1.0 - edge.y;
	vec4 color = UV.x <= progress ? fill_color : back_color;
	color = is_border ? border_color : color;
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
