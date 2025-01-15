shader_type canvas_item;

uniform float radius: hint_range(1.0, 10.0, 1.0) = 1.0;
uniform float stride: hint_range(0.1, 10.0, 0.1) = 1.0;
uniform float power: hint_range(0.1, 10.0, 0.1) = 2.0;
uniform float cycle_time: hint_range(0.1, 10.0, 0.1) = 2.0;
uniform vec4 color = vec4(0.4, 0.4, 0.01, 1.0);

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	bool c = pixel.a > 0.0;

	for (float x = -radius; c && x <= radius; x += 1.0)
	{
		for (float y = -radius; c && y <= radius; y += 1.0)
		{
			vec2 offset = vec2(x, y) * stride * TEXTURE_PIXEL_SIZE;
			if (texture(TEXTURE, UV + offset).a == 0.0)
			{
				float v = TIME / cycle_time;
				float t = (v - floor(v)) - 0.5;
				vec4 alt = vec4(color.xyz, pixel.a);
				COLOR = mix(pixel, alt, abs(t) * 2.0);
				c = false;
			}
		}
	}
	
	if (c)
	{
		COLOR = pixel;
	}
}
