shader_type spatial;

instance uniform bool stereographic;

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

