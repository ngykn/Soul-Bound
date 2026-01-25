shader_type canvas_item;


uniform bool enabled = true;
// Uniform to control the level of desaturation (0.0 = original, 1.0 = grayscale)
uniform float desaturation_amount : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	 vec4 color = texture(TEXTURE, UV);
	if (!enabled){
		COLOR = color;
	} else {
	// Get the original color of the pixel
   
    
    // Calculate the luminance (perceived brightness) of the color
    // This is a common way to get a grayscale value that accounts for human perception
    float luminance = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    
    // Mix the original color with the grayscale luminance value based on the uniform
    // mix(a, b, t) is a linear interpolation: (a * (1.0 - t)) + (b * t)
    vec3 muted_color = mix(color.rgb, vec3(luminance), desaturation_amount);
    
    // Set the final pixel color, preserving the original alpha (transparency)
    COLOR.rgb = muted_color;
    COLOR.a = color.a;
}

	}
