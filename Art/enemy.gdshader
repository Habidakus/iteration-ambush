shader_type canvas_item;

uniform float radius: hint_range(1.0, 10.0, 1.0) = 1.0;
uniform float stride: hint_range(0.1, 10.0, 0.1) = 1.0;
uniform float power: hint_range(0.1, 10.0, 0.1) = 2.0;
uniform float cycle_time: hint_range(0.1, 10.0, 0.1) = 2.0;
uniform vec4 color = vec4(0.4, 0.4, 0.01, 1.0);

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	if (pixel.a == 0.0)
	{
		COLOR = pixel;
	}
	else
	{
		float count = 0.0;
		vec4 glow = vec4(0.0);
		for (float x = -radius; x <= radius; x += 1.0)
		{
			for (float y = -radius; y <= radius; y += 1.0)
			{
				count += 1.0;
				vec2 offset = vec2(x, y) * stride * TEXTURE_PIXEL_SIZE;
				glow += texture(TEXTURE, UV + offset);
			}
		}
		glow = power * glow / count;
		float v = TIME / cycle_time;
		float t = (v - floor(v)) - 0.5;
		
		COLOR = mix(pixel, color, abs(t) * 2.0);
	}
}