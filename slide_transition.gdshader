shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform bool is_y = false;
uniform bool reverse = false;

void fragment() {
	if(!is_y){
		if(UV.x > progress){
			if(!reverse){
				discard;
			}
		}
		else if(reverse){
			discard;
		}
	}
	else{
		if(UV.y > progress){
			if(!reverse){
				discard;
			}
		}
		else if(reverse){
			discard;
		}
	}
}
