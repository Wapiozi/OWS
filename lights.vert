extern vec4[50] lights;
extern vec2 camPos;

vec4 position( mat4 transform_projection, vec4 vertex_position ) {
	vec4 Position = transform_projection * vertex_position;     //output position with projection


	return Position;
}
