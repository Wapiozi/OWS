extern vec4[50] lights;
extern vec2 camPos;
vec4 nul = vec4(0, 0, 0, 0);
vec4 ful = vec4(1, 1, 1, 1);

float len(vec2 coords) {
	float outp = sqrt(coords.x*coords.x + coords.y*coords.y);
	return outp;
}

bool areCrossing(vec4 line1, vec4 line2) {
	vec4 proj1 = vec4(line1.xz, line1.yw);
	vec4 proj2 = vec4(line2.xz, line2.yw);
	
	if ((proj2.x > proj1.x) && (proj2.x < proj1.y)) return false;
	if ((proj2.y > proj1.x) && (proj2.y < proj1.y)) return false;
	if ((proj2.z > proj1.z) && (proj2.z < proj1.w)) return false;
	if ((proj2.w > proj1.z) && (proj2.w < proj1.w)) return false;
	return true;
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
	vec4 col = Texel(texture, texture_coords);
	
	float dist = 0.0;
	
	for (int i = 0; i < 50; i++) {
		dist = max(dist, abs( min( len(screen_coords+camPos - lights[i].xy)/lights[i].w, 1) - 1));
	}
	
	if (col == ful) {
		return vec4((color.rgb*max(min(pow(dist, 10)*1000, 1), 0.005)), 1.0);
	}
	
	col.rgb = col.rgb*max(min(pow(dist, 10)*1000, 1), 0.005);
	
	return col;
}
