shader_type spatial;

#include "projection_shader.gdshaderinc"
#include "plate_shader.gdshaderinc"

uniform bool show_plates;
uniform bool stereographic;

varying vec4 cust1;
varying vec4 cust2;


void vertex() {
	// Called for every vertex the material is visible on.
	// rgb = plate colour
	plate_col = CUSTOM0;
	// r = altitude, g = temperature,
	cust1 = CUSTOM1;
	
	
	if (show_plates) {
		COLOR.rgb = toggle_plate_view();
	}
	
	if (stereographic) {
		VERTEX = stereo_project(VERTEX,VERTEX_ID);
		//COLOR.a = stereo_colour(VERTEX_ID);
		NORMAL = vec3(0.0,1.0,0.0);
	}
}

void fragment() {
	// Called for every pixel the material is visible on.
	if (show_plates) {
		ALBEDO = COLOR.rgb;
		ALPHA = COLOR.a;
	}

}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
