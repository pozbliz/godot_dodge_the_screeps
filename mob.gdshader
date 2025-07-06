shader_type canvas_item;

uniform bool hit_blink = false;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    if (hit_blink) {
        // Tint the texture white while preserving transparency and shape
        COLOR = mix(tex_color, vec4(1.0, 1.0, 1.0, tex_color.a), 0.7);
    } else {
        COLOR = tex_color;
    }
}
