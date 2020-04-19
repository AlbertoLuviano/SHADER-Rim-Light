shader_type spatial;
render_mode cull_back;

uniform sampler2D normalMap : hint_normal;
uniform float normalStrength : hint_range(0.0, 1.0);
uniform vec2 normalTiling = vec2(1.0, 1.0);
uniform vec2 normalOffset = vec2(0.0, 0.0);
uniform float rimWidth : hint_range(0.0, 1.0) = 0.5;

void fragment(){
vec2 uvModifier = (texture(normalMap, (UV * normalTiling) + (normalOffset * TIME)).xy * normalStrength) - normalStrength * 0.5;
vec3 color = texture(SCREEN_TEXTURE, SCREEN_UV + uvModifier).rgb;
ROUGHNESS = rimWidth; //Play with this value
RIM = 1.0;
ALBEDO = color;
}