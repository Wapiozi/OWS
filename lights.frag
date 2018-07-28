extern vec4[200] lights;  //lightSources
extern vec4[200] triangles;  //p1, p2 from triangles
extern vec2[200] pdegs;  //p1deg, p2deg from triangles
extern vec2 camPos;
vec4 nul = vec4(0, 0, 0, 0);
vec4 ful = vec4(1, 1, 1, 1);
vec2 vect = vec2(0, 0);
float degr = 0;

bool inTriang(vec4 trpoint, vec4 light, vec2 point) {
	if ((((trpoint.x-point.x)*(trpoint.w-trpoint.y)-(trpoint.z-trpoint.x)*(trpoint.y-point.y)) >= 0)
		&& (((trpoint.z-point.x)*(light.y-trpoint.w)-(light.x-trpoint.z)*(trpoint.w-point.y)) >= 0)
		&& (((light.x-point.x)*(trpoint.y-light.y)-(trpoint.x-light.x)*(light.y-point.y)) >= 0)) {
		return true;
	}
	return false;
}

float getDegr(vec2 point1, vec2 point2) {
	vect = point2-point1;
	degr = 0;

	//if (vect.x == 0) vect.x = 0.00000001;
	//if (vect.y == 0) vect.y = 0.00000001;

	if ((vect.x < 0) && (vect.y >= 0)) {
		vect.y = -vect.y;
		degr = degrees(atan(vect.x/vect.y)) + 90;
	}
	else if ((vect.x < 0) && (vect.y < 0)) {
		vect = -vect;
		degr = degrees(atan(vect.y/vect.x)) + 180;
	}
	else if ((vect.x >= 0) && (vect.y < 0)) {
		vect.x = -vect.x;
		degr = degrees(atan(vect.x/vect.y)) + 270;
	}
	else if ((vect.x >= 0) && (vect.y >= 0)) {
		degr = degrees(atan(vect.y/vect.x));
	}
//	degr = acos(dot(normalize(vec2(1, 0)), normalize(vect)));
	return degr;
}

bool rayIsBetw(vec2 triang, float angle) {

	if (triang.y - triang.x < 0) {
		if ((degr >= triang.x) || (degr < triang.y)) return true;
		return false;
	}
	else {
		if ((degr >= triang.x) && (degr < triang.y)) return true;
		return false;
	}
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
	vec4 col = Texel(texture, texture_coords);

	float dist = 1000.0;
	float bestdist = dist;
	float illum = 0.0;
	float gamma = 1.1;
	float atten = 0.0;
	float angle = 0.0;
	vec2 curPos = screen_coords+camPos;
	vec4 curLight = lights[0];
	int nex = 0;
	int j = 0;
	int i = 0;
	int prev = 0;
	bool isLightened = true;


	for (j = 0; j < 50; j++) {
		if (lights[j].w > 0.0) {
			curLight = lights[j];
			isLightened = true;
			angle = getDegr(curLight.xy, curPos);

			for (i = prev; i <= int(curLight.z); i++) {
				if (rayIsBetw(pdegs[i], angle)) {
					if (!inTriang(triangles[i], curLight, curPos)) {
						isLightened = false;
	//					return vec4(0, 0, 0, 1);
						break;
					}
				}
			}
			if (isLightened) {
				dist = distance(curPos, curLight.xy);
				atten = 1.0/(0.0 + 0.5*dist + 0.001*pow(dist, 2));
				illum = illum + lights[j].w*atten;
			}

			prev = int(curLight.z+1);
		}
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
