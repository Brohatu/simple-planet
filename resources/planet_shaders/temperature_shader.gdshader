shader_type spatial;

instance uniform bool show_temp;
instance uniform float max_temp;
instance uniform float min_temp;

#define RED vec3(1, 0, 0)
#define GREEN vec3(0, 1, 0)
#define BLUE vec3(0, 0, 1)
#define BLACK vec3(0.0)
#define WHITE vec3(1.0)

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
		// Called for every pixel the material is visible on.
	float temp = cust1.g;
	
	
	if (show_temp) {
		vec3 heat_max = RED;
		vec3 heat_mid = GREEN;
		vec3 heat_min = BLUE;
		
		/* To scale temperature correctly:
			1) Normalise the range of values
			2) If the temperature is higher than the mid-point, subtract 0.5
			3) Multiply the result by 2
		*/
		//temp = (temp + 35.0) / 70.0;
		//if (temp > 0.5) {
			//ALBEDO = mix(heat_mid, heat_max, (temp - 0.5) * 2.0);
		//}
		//if (temp < 0.5) {
			//ALBEDO = mix(heat_min, heat_mid, temp * 2.0);
		//}
		if (temp < 0.0) {
			// WHITE = 0, BLUE = -20
			ALBEDO = mix(WHITE,BLUE,(-temp/20.0));
		}
		if (temp > 0.0 ) {
			// WHITE = 0, GREEN = 20
			ALBEDO = mix(WHITE,GREEN,(temp/20.0));
		}
		if (temp > 20.0) {
			// GREEN = 20, RED = 30
			ALBEDO = mix(GREEN,RED, (temp-20.0)/10.0);
		}
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
