extern vec4[200] lights;
extern vec4[200] triangles;
extern vec2 camPos;
vec4 nul = vec4(0, 0, 0, 0);
vec4 ful = vec4(1, 1, 1, 1);

float len(vec2 coords) {
	float outp = sqrt(coords.x*coords.x + coords.y*coords.y);
	return outp;
}

bool inTriang(vec4 trpoint, vec4 light, vec2 point) {
	if ((((trpoint.x-point.x)*(trpoint.w-trpoint.y)-(trpoint.z-trpoint.x)*(trpoint.y-point.y)) >= 0) 
		&& (((trpoint.z-point.x)*(light.y-trpoint.w)-(light.x-trpoint.z)*(trpoint.w-point.y)) >= 0) 
		&& (((light.x-point.x)*(trpoint.y-light.y)-(trpoint.x-light.x)*(light.y-point.y)) >= 0)) {
		return true;
	}
	return false;
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
	vec4 col = Texel(texture, texture_coords);
	
	float dist = 1000.0;
	float bestdist = dist;
	float illum = 0.0;
	float gamma = 1.1;
	float atten = 0.0;
	int nex = 0;
	int j = 0;
	int prev = 0;
	
	
	while (lights[j].w > 0.0) {
		for (int i = prev; i <= int(lights[j].z); i++) {
			if (inTriang(triangles[i], lights[j], screen_coords+camPos)) {
				dist = len(screen_coords+camPos - lights[j].xy);
				atten = 1.0/(0.0 + 0.5*dist + 0.001*pow(dist, 2));
				illum = illum + lights[j].w*atten;
				break;
			}
		}
		prev = int(lights[j].z+1);
		j++;
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
