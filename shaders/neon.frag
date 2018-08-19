extern vec4 tarColor;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
    vec4 col = Texel(texture, texture_coords);

    //vec4 tmCol = tarCol + col.a;

    col.rgb = col.rgb*0.8*pow(col.a, 2) + tarColor.rgb;

    return col;
}
