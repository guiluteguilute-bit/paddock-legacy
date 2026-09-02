shader_type canvas_item;

uniform vec4 primary_color : source_color = vec4(0.094, 0.827, 0.773, 1.0);
uniform vec4 secondary_color : source_color = vec4(0.239, 0.486, 1.0, 1.0);
uniform vec4 accent_color : source_color = vec4(1.0, 0.710, 0.278, 1.0);
uniform sampler2D pattern_mask : filter_linear, repeat_enable;
uniform float pattern_strength : hint_range(0.0, 1.0) = 0.75;

void fragment() {
    vec4 source = texture(TEXTURE, UV);
    float mask = texture(pattern_mask, UV).a * pattern_strength;
    vec3 livery = mix(primary_color.rgb, secondary_color.rgb, mask);
    float highlight = smoothstep(0.72, 1.0, source.r) * (1.0 - smoothstep(0.25, 0.7, source.g));
    livery = mix(livery, accent_color.rgb, highlight);
    COLOR = vec4(livery * source.rgb, source.a);
}
