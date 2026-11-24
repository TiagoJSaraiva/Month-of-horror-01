// Gota de chuva: um traço de pé virado para a câmera. Some dentro do abrigo (o interior da
// cabine), para nunca chover lá dentro, sem depender da colisão das partículas.
shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled;

uniform vec4 drop_color : source_color = vec4(0.7, 0.75, 0.8, 0.35);
// Cantos, no espaço do mundo, da caixa onde não chove.
uniform vec3 shelter_min = vec3(-1.45, 1.0, -6.05);
uniform vec3 shelter_max = vec3(1.45, 3.4, -2.35);

varying vec3 world_position;


void vertex() {
	// Billboard com o eixo Y fixo: a gota fica de pé e gira só para encarar a câmera.
	vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz));
	vec3 forward = normalize(cross(right, vec3(0.0, 1.0, 0.0)));
	mat4 billboard = mat4(
		vec4(right, 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(forward, 0.0), MODEL_MATRIX[3]
	);
	MODELVIEW_MATRIX = VIEW_MATRIX * billboard;
	world_position = (billboard * vec4(VERTEX, 1.0)).xyz;
}


void fragment() {
	bool sheltered = all(greaterThan(world_position, shelter_min))
		&& all(lessThan(world_position, shelter_max));
	if (sheltered) {
		discard;
	}
	ALBEDO = drop_color.rgb;
	ALPHA = drop_color.a;
}
