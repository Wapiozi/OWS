extern vec4[200] lights;
extern vec2 camPos;
vec4 nul = vec4(0, 0, 0, 0);
vec4 ful = vec4(1, 1, 1, 1);

float len(vec2 coords) {
	float outp = sqrt(coords.x*coords.x + coords.y*coords.y);
	return outp;
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
	vec4 col = Texel(texture, texture_coords);
	
	float dist = 1000.0;
	float bestdist = dist;
	float illum = 0.0;
	float gamma = 1.1;
	
	for (int i = 0; i < 200; i++) {
		dist = len(screen_coords+camPos - lights[i].xy);
		float atten = 1.0/(0.0 + 0.5*dist + 0.001*pow(dist, 2));
		illum = illum + lights[i].w*atten;
	}
	
	if (color != ful) {
		return vec4((color.rgb), 1.0);
	}
	
	if (illum > 1.0) {
		illum = pow(illum, 0.3);
	}
	
	col.rgb = col.rgb*illum;
	//col.rgb = pow(col.rgb, 1.0/vec3(gamma));   --gamma correction
	
	return col;
}
