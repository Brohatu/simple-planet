shader_type spatial;

instance uniform bool show_plates;
instance uniform bool show_temp;
instance uniform float max_temp;
instance uniform float min_temp;

instance uniform bool show_altitude;
instance uniform float max_alt;
instance uniform float min_alt;
instance uniform float sea_level;
uniform sampler3D surface_noise;



varying vec4 plate_col;
varying vec4 cust1;
varying float sampler_val;


#define RED vec3(1, 0, 0)
#define GREEN vec3(0, 1, 0)
#define BLUE vec3(0, 0, 1)
#define BLACK vec3(0.0)
#define WHITE vec3(1.0)

#define MAX_ALT vec3(0.0,1.0,0.0)
#define MIN_ALT vec3(0.0,0.0,1.0)
#define NEUTRAL_ALT vec3(0.0,0.05,0.05)

#define SAND vec3(0.761,0.698,0.502)
#define MOUNTAIN vec3(0.353)
#define FOREST vec3(0.133,0.545,0.133) / 2.0
#define DEEP_OCEAN vec3(0.0,0.0,0.1)
#define SHALLOWS vec3(0.0,0.05,0.25)


void vertex() {
	// Called for every vertex the material is visible on.
	// rgb = plate colour
	plate_col = CUSTOM0;
	// r = altitude, g = temperature, b = empty
	cust1 = CUSTOM1;

	//VERTEX = VERTEX * sqrt(cust1.r + 1.0);
	//sampler_val = texture(surface_noise,VERTEX).r * 5.0;
}



void fragment() {
	float alt = cust1.r;
	float temp = cust1.g;
	// Called for every pixel the material is visible on.
	if (show_plates) {
		ALBEDO = plate_col.rgb;
	}

	else if (show_temp) {
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

	// Altitude view. Sea level is grey, mountains turn green, trenches turn blue
	else if(show_altitude) {
		//ALBEDO = vec3(1.0) * (cust1.r)/10.0 + 0.5;

		if (alt > 0.0) {
			ALBEDO = mix(NEUTRAL_ALT,MAX_ALT,alt/max_alt);
		}
		else if (alt < 0.0){
			ALBEDO = mix(NEUTRAL_ALT,MIN_ALT,alt/min_alt);
		}
		else {
			ALBEDO = vec3(NEUTRAL_ALT);
		}
	}

	// Standard geographical view
	else {
		if (alt < sea_level) {
			ALBEDO = mix(SHALLOWS,DEEP_OCEAN,alt/min_alt);
			ALBEDO = DEEP_OCEAN;
		}
		else if (alt > sea_level) {
			//ALBEDO = FOREST;
			//ALBEDO += MOUNTAIN * alt/max_alt;
			ALBEDO = mix(vec3(0.1),MOUNTAIN,alt/max_alt);
		}




		//ALBEDO = BLACK;
		//if (cust1.r > min_alt) {
			//ALBEDO = DEEP_OCEAN;
			////ALBEDO = mix(BLACK, DEEP_OCEAN, alt + min_alt);
		//}
		//if (cust1.r > (min_alt * 0.7)) {
			////ALBEDO = mix(DEEP_OCEAN, BLUE, alt + (min_alt * 0.8));
		//}
		//if (cust1.r > (min_alt * 0.4)) {
			////ALBEDO = vec3(0.9,0.9,1.0);
			////ALBEDO = mix(BLUE, SHALLOWS, alt + (min_alt * 0.4));
		//}
		//if (cust1.r > (min_alt * 0.1)) {
			////ALBEDO = SHALLOWS;
			////ALBEDO = mix(SHALLOWS, SAND, alt + (min_alt * 0.1));
		//}
		//if (cust1.r > (max_alt * 0.0)) {
			//ALBEDO = SAND;
			////ALBEDO = mix(SAND, GREEN, alt - (max_alt * 0.1));
		//}
		//if (cust1.r > (max_alt * 0.4)) {
			//ALBEDO = FOREST;
			////ALBEDO = mix(GREEN, FOREST, alt - (max_alt * 0.4));
		//}
		//if (cust1.r > max_alt * 0.6) {
			////ALBEDO = mix(FOREST, MOUNTAIN, alt - (max_alt * 0.6));
		//}
		//if (cust1.r > max_alt * 0.8) {
			//// 0.0 -> 1.0 = 4.0 -> max_alt
			////ALBEDO = mix(MOUNTAIN, WHITE, alt - (max_alt * 0.8));
		//}
		////ALBEDO = mix(DEEP_OCEAN, MOUNTAIN, alt/(max_alt - min_alt));

	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}