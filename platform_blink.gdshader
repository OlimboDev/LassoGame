shader_type canvas_item;

uniform vec4 blink_color : source_color = vec4(0.1, 1.0, 0.2, 1.0);
uniform float speed = 4.0;
uniform float strength = 0.7;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	float pulse = (sin(TIME * speed) + 1.0) / 2.0;

	tex.rgb = mix(tex.rgb, blink_color.rgb, pulse * strength);

	COLOR = tex;
}