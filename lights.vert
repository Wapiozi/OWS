extern vec4[100] lights;
extern vec4[100] colors;
extern vec4[300] triangles;
extern vec2[300] pdegs;
extern vec2 camPos;

vec4 position( mat4 transform_projection, vec4 vertex_position ) {
	vec4 Position = transform_projection * vertex_position;     //output position with projection


	return Position;
}
