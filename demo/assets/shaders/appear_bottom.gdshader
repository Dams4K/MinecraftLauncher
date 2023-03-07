shader_type canvas_item;

uniform float y_pos = 0.0;

void vertex() {
	VERTEX.y += y_pos;
}