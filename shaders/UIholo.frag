extern float time;
extern vec4 tarColor;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
    vec4 col = Texel(texture, texture_coords);

    col = col * tarColor * max(cos(pow(screen_coords.y, 2)/2 + time*40), sin(screen_coords.y/2 + time*40));

    return col;
}
