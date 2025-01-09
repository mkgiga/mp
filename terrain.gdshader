shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform vec4 highlight_color : source_color = vec4(1.0, 0.0, 0.0, 0.5); // Red with 50% alpha
uniform float highlight_radius : hint_range(0.1, 10.0) = 1.0; // Radius of the highlight
uniform vec3 highlight_center; // Center of the highlight (in world space)

void fragment() {
    // ... your original code (if needed) ...

    // Visualize highlight_center (map to a color range)
    ALBEDO = vec3((highlight_center + vec3(5.0)) / vec3(10.0)); // Assuming highlight_center components are within -5 to +5 range, adjust as needed
}