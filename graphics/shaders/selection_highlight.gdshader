shader_type canvas_item;
uniform vec4 highlight_color : source_color = vec4(0.094, 0.827, 0.773, 1.0);
uniform float strength : hint_range(0.0, 1.0) = 0.35;
void fragment() {
    vec4 base = texture(TEXTURE, UV);
    float pulse = 0.75 + sin(TIME * 3.0) * 0.25;
    COLOR = vec4(mix(base.rgb, highlight_color.rgb, strength * pulse), base.a);
}
