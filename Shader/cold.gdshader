shader_type canvas_item;

uniform bool enabled = true;

uniform float cold_strength : hint_range(0.0, 1.0) = 0.7; 
uniform float desaturate_strength : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
	if (!enabled){
		COLOR = tex_color;
	} else {
    // --- Desaturate slightly ---
    float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 desaturated = mix(tex_color.rgb, vec3(gray), desaturate_strength);

    // --- Add cold (blue) tint ---
    vec3 cold_tint = vec3(0.6, 0.8, 1.2); // boosted blue
    vec3 cold_color = desaturated * cold_tint;

    // Blend original and cold version
    vec3 final_color = mix(tex_color.rgb, cold_color, cold_strength);

    COLOR = vec4(final_color, tex_color.a);
	}
}