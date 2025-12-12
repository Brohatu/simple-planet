shader_type spatial;

uniform bool altitude_view = false;
uniform float altitude_modifier = 1.0;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	if (altitude_view) {
		// Raw altitude value scales from -1.0 to 1.0.
		// Final value scales from 0.0 to X.
		// Use scale modifier to adjust final value appropriately.
		
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
