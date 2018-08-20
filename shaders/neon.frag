#ifdef GL_ES
precision mediump float;
#endif

extern vec4 tarColor;
extern float fill;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
    vec4 col = Texel(texture, texture_coords);

    //vec4 tmCol = tarCol + col.a;

    if (texture_coords.x <= fill) {
        col.rgb = col.rgb*0.8*pow(col.a, 2) + tarColor.rgb;
    } else {
        col.rgb = col.rgb*0.8*pow(col.a, 2);
    }

    return col;
}
