extern vec4[50] lights;
extern vec2 camPos;
vec4 nul = vec4(0, 0, 0, 0);

float len(vec2 coords) {
	float outp = sqrt(coords.x*coords.x + coords.y*coords.y);
	return outp;
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
	vec4 col = Texel(texture, texture_coords);
	
	float dist = 0.0;
	
	for (int i = 0; i < 50; i++) {
		dist = max(dist, abs( min( len(screen_coords+camPos - lights[i].xy)/lights[i].w, 1) - 1));
	}
	
	col.xyz = col.xyz*min(pow(dist, 10)*1000, 1);
	
	return col;
}
