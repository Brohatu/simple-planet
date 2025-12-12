

vec3 stereo_project(vec3 v, int vi) {
	//if (v == vec3())
	vec3 result;
	float vx = v.x/(1.0 + v.y);
	float vz = v.z/(1.0 + v.y);
	float vy = 0.0;
	
	result = vec3(vx,vy,vz);
	return result;
}

float stereo_colour(int vi) {
	if (vi <= 15359) {
		return 0.0;
	}
	else {
		return 1.0;
	}
}
