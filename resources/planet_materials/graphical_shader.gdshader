shader_type spatial;

instance uniform bool stereographic;
instance uniform bool altitude_view;


vec3 stereo_project(vec3 v) {
	vec3 result;
	float vx = v.x/(1.0 + v.y);
	float vz = v.z/(1.0 + v.y);
	float vy = v.y * 0.0;
	result = vec3(vx,vy,vz);
	return result;
}


void vertex() {
	// Called for every vertex the material is visible on.
	if (stereographic) {
		VERTEX = stereo_project(VERTEX);
		NORMAL = vec3(0.0,1.0,0.0);
	}
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = COLOR.rgb;
	//ALPHA = COLOR.a;

}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
