@tool
extends TextureRect

# border color, fill color
const STATE_COLORS: Dictionary = {
	0: ["#111111", "#333333"],  # Uncompleted
	1: ["#b8860b", "#ffd700"],  # Completed
	2: ["#555040", "#999070"],  # Needs to be completed again
}


func update_svg_colors(current_state: int) -> void:
	var svg_text: String = FileAccess.get_file_as_string("res://star.svg")
	if svg_text == "":
		return

	var colors: Array = STATE_COLORS[current_state]
	svg_text = svg_text.replace("var(--border)", colors[0])
	svg_text = svg_text.replace("var(--fill)", colors[1])

	var image: Image = Image.new()
	image.load_svg_from_string(svg_text)
	texture = ImageTexture.create_from_image(image)
