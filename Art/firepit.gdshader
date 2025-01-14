shader_type canvas_item;

// Modified from the Lava Shader found at https://godotshaders.com/shader/lava-shader/

uniform float speed = 0.03;
uniform sampler2D noise: repeat_enable, filter_linear;

float rnd(vec2 x) {
	return texture(noise, x * .01).x;
}

vec2 rnd2(vec2 x) {
	return texture(noise, x * 0.01).xy;
}

vec2 gradn(vec2 p) {
	float ep = .09;
	float gradx = rnd(vec2(p.x + ep, p.y)) - rnd(vec2(p.x - ep, p.y));
	float grady = rnd(vec2(p.x, p.y + ep)) - rnd(vec2(p.x, p.y - ep));
	return vec2(gradx, grady);
}

mat2 makem2(float theta) {
	float c = cos(theta);
	float s = sin(theta);
	return mat2(vec2(c, -s), vec2(s, c));
}

float flow_mess(vec2 p) {
	float z = 2.;
	float rz = 0.;
	vec2 bp = p;
	float t = TIME * speed;
	vec2 pp = p;
	
	for(float i = 1.; i < 3.; ++i) {
		p += t * .6;
		pp += 0.01;
		bp += t * 1.9;
		//vec2 gr = gradn(i * p * .34 + t * 1.);
		vec2 gr = gradn(p * i * .34  + t * 1.);
		gr *= makem2(t * 6. - (.05 * p.x + 0.03 * p.y) * 40.);
		p += gr * .5;
		rz += (sin(rnd(p) * t * 7.) *.5 + .5) / z;
		pp = mix(bp, pp, .77);
		z *= 1.4;
		p *= 2.;
		bp *= 1.9;
	}
	return rz;
}

vec2 gen_circle_t(vec2 p, float i)
{
	float tt = TIME * speed + i;
	vec2 px = vec2(10.0 * (1. + cos(tt)), 10. * (1. + sin(tt)));
	return rnd2(px + p);
}

float flow(vec2 p) {
	float z = 2.;
	float rz = 0.;
	vec2 bp = p;
	//float t = TIME * speed;
	
	for(float i = 1.; i < 10.; ++i) {
		vec2 t = gen_circle_t(p, i);
		p += t * .6;
		bp += t * 1.9;
		vec2 gr = gradn(i * p * .34 + t * 1.);
		gr *= makem2(t.x * 6. - (.05 * p.x + 0.05 * p.y) * 40.);
		p += gr * .5;
		rz += (sin(rnd(p) * 7.) *.5 + .5) / z;
		p = mix(bp, p, .77);
		z *= 1.4;
		p *= 2.;
		bp *= 1.9;
	}
	return rz;
}

varying vec2 vertex_world;

void vertex() {
	vertex_world = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 resolution = 1. / SCREEN_PIXEL_SIZE;
	vec2 fragCoord = vertex_world.xy;
	fragCoord = vec2(fragCoord.x, resolution.y - fragCoord.y);
	vec2 p = fragCoord / resolution - 0.5;
	
	p.x *= resolution.x / resolution.y;
	p *= 3.0;
	
	float rz = flow(p);
	vec3 col = vec3(.2, .07, .01) / rz;
	col = pow(col, vec3(1.4));
	
	COLOR = vec4(col, 1.0);
}
