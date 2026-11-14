@tool
extends TextureRect

func update_svg_colors(current_state: int) -> void:
	var border_color = ""
	var fill_color = ""
	
	match current_state:
		0: # Uncompleted (Black / Dark Grey)
			border_color = "#111111"
			fill_color = "#333333"
		1: # Completed (Gold / Bright Yellow)
			border_color = "#b8860b"
			fill_color = "#ffd700"
		2: # Completed, but needs recompletion (Greyish Gold / Muted)
			border_color = "#555040"
			fill_color = "#999070"
	
	# Load and parse SVG
	var file = FileAccess.open("res://star.svg", FileAccess.READ)
	if not file:
		return
		
	var svg_text = file.get_as_text()
	file.close()
	
	svg_text = svg_text.replace("var(--border)", border_color)
	svg_text = svg_text.replace("var(--fill)", fill_color)
	
	var image = Image.new()
	image.load_svg_from_string(svg_text)
	
	self.texture = ImageTexture.create_from_image(image)
