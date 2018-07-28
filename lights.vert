extern vec4[200] lights;
extern vec4[200] triangles;
extern vec2[200] pdegs;
extern vec2 camPos;

vec4 position( mat4 transform_projection, vec4 vertex_position ) {
	vec4 Position = transform_projection * vertex_position;     //output position with projection


	return Position;
}
