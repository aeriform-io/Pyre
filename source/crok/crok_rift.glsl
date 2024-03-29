uniform sampler2D front;
uniform float adsk_result_w, adsk_result_h;
uniform float kappa1, kappa2, kappa3, kappa4, scaleFactor, separation;
uniform vec2 leftCenter, rightCenter;

vec4 kappa = vec4(kappa1, kappa2, kappa3, kappa4);

//vec4 kappa = vec4(1.0,1.7,0.7,15.0);
//const float scaleFactor = 0.9;
//const vec2 leftCenter = vec2(0.25, 0.5);
//const vec2 rightCenter = vec2(0.75, 0.5);
//const float separation = -0.05;

// Scales input texture coordinates for distortion.
vec2 hmdWarp(vec2 LensCenter, vec2 texCoord, vec2 Scale, vec2 ScaleIn) {
	vec2 theta = (texCoord - LensCenter) * ScaleIn;
	float rSq = theta.x * theta.x + theta.y * theta.y;
	vec2 rvector = theta * (kappa.x + kappa.y * rSq + kappa.z * rSq * rSq + kappa.w * rSq * rSq * rSq);
	vec2 tc = LensCenter + Scale * rvector;
	return tc;
}

bool validate(vec2 tc, int left_eye) {
	//keep within bounds of texture
	if ((left_eye == 1 && (tc.x < 0.0 || tc.x > 0.5)) || (left_eye == 0 && (tc.x < 0.5 || tc.x > 1.0)) || tc.y < 0.0 || tc.y > 1.0) {
		return false;
	}
	return true;
}

void main() {
	vec2 screen = vec2(adsk_result_w, adsk_result_h);
	 
	float as = float(screen.x / 2.0) / float(screen.y);
	vec2 Scale = vec2(0.5, as);
	vec2 ScaleIn = vec2(2.0 * scaleFactor, 2.0 / as * scaleFactor);
	 
	vec2 texCoord = gl_FragCoord.xy/screen;
	vec2 texCoordSeparated = texCoord;
	vec2 tc = vec2(0);
	vec4 color = vec4(0);
	
	if (texCoord.x < 0.5) {
		texCoordSeparated.x += separation;
		tc = hmdWarp(leftCenter, texCoordSeparated, Scale, ScaleIn );
		color = texture2D(front, tc);
		if (!validate(tc, 1))
			color = vec4(0);
	} else {
		texCoordSeparated.x -= separation;
		tc = hmdWarp(rightCenter, texCoordSeparated, Scale, ScaleIn);
		color = texture2D(front, tc);
		if (!validate(tc, 0))
			color = vec4(0);
	}
	gl_FragColor = color;
}
