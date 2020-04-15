shader_type spatial;
render_mode unshaded, cull_back;

uniform float rimWidth : hint_range(1.0, 3.0) = 2.0;
uniform vec4 rimColor : hint_color;
uniform vec4 outerRimColor : hint_color;
uniform sampler2D normalMap : hint_normal;
uniform float normalStrength : hint_range(0.0, 1.0);
uniform vec2 normalTiling = vec2(1.0, 1.0);
uniform vec2 normalOffset = vec2(0.0, 0.0);
//uniform float beerFactor : hint_range(3.5, 10.0) = 6.0;
//uniform sampler2D imageTexture;

void fragment(){
	vec2 uvModifier = (texture(normalMap, (UV * normalTiling) + (normalOffset * TIME)).xy * normalStrength) - normalStrength * 0.5;
	vec3 color = texture(SCREEN_TEXTURE, SCREEN_UV + uvModifier).rgb;

	float rim = 1.0 - abs(dot(VIEW, NORMAL));
	float outerRim = pow(rim, 4.0);
	rim = pow(rim, rimWidth);
	color = color + rim * rimColor.rgb;
	color = color + outerRim * outerRimColor.rgb;
	ALBEDO = color;

////	appparently, depth texture and screen texture don't like each other :(
////	Geometry intersection
//	float depth = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r;
//	depth = depth * 2.0 - 1.0;
//	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
//	depth += VERTEX.z;
//	depth = exp(-depth * beerFactor);
//	rim += depth;
//	if (rim > 1.0) {
//		discard;
//	}
//	ALBEDO = texture(imageTexture, UV).rgb + 
//		vec3(rim * rimColor.r, rim * rimColor.g, rim * rimColor.b) + 
//		vec3(outerRim * outerRimColor.r, outerRim * outerRimColor.g, outerRim * outerRimColor.b);
////	ALPHA *= rim;
}