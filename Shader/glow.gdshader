shader_type canvas_item;
render_mode blend_add; // Use additive blending for the glow effect

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_power: hint_range(0.0, 8.0, 0.1) = 2.0;
uniform float glow_radius: hint_range(0.0, 10.0, 1.0) = 1.0;

void fragment() {
    vec4 current_color = texture(TEXTURE, UV);
    vec4 glow = vec4(0.0);
    float count = 0.0;
    
    // Sample surrounding pixels to create a blur/glow effect
    for (float x = -glow_radius; x <= glow_radius; x += 1.0) {
        for (float y = -glow_radius; y <= glow_radius; y += 1.0) {
            vec2 offset = vec2(x, y) * TEXTURE_PIXEL_SIZE;
            // Only add the glow color if the pixel is not fully transparent
            if (texture(TEXTURE, UV + offset).a > 0.0) {
                glow += texture(TEXTURE, UV + offset) * glow_color;
                count += 1.0;
            }
        }
    }
    
    // Average the glow color
    glow /= count;
    glow.a = current_color.a; // Maintain original alpha
    
    // Blend the original color with the glow color
    COLOR = mix(current_color, glow * glow_power, glow.a);
}
