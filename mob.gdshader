shader_type canvas_item;

uniform bool hit_blink = false;
uniform vec4 tint_color : source_color = vec4(1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    tex_color.rgb *= tint_color.rgb;

    if (hit_blink) {
        // Blink white while preserving alpha
        COLOR = mix(tex_color, vec4(1.0, 1.0, 1.0, tex_color.a), 0.7);
    } else {
        COLOR = tex_color;
    }
}
