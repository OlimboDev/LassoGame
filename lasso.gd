extends Node2D

var selected: bool = false
@onready var current_line = $Line2D
var previous_mouse_pos: Vector2 = Vector2.ZERO

const MIN_POINT_DISTANCE: float = 5.0

func _ready() -> void:
	current_line.closed = true

func _process(_delta: float) -> void:
	var current_mouse_pos = get_global_mouse_position()
	if !selected:
		if Input.is_action_just_pressed("mouseClick"):
			add_child(current_line)

		elif Input.is_action_pressed("mouseClick"):
			var count = current_line.get_point_count()
			if count == 0 or current_line.get_point_position(count - 1).distance_to(current_mouse_pos) >= MIN_POINT_DISTANCE:
				current_line.add_point(current_mouse_pos)
		elif Input.is_action_just_released("mouseClick"):
			selected = true
			current_line.default_color = Color.BLUE
	else:
		if Input.is_action_just_pressed("mouseClick"):
			previous_mouse_pos = current_mouse_pos
		if Input.is_action_pressed("mouseClick"):
			var move_offset = current_mouse_pos - previous_mouse_pos
			previous_mouse_pos = current_mouse_pos

			for i in range(current_line.get_point_count()):
				var point = current_line.get_point_position(i)
				current_line.set_point_position(i, point + move_offset)

	if Input.is_action_just_pressed("ui_cancel"):
		current_line.clear_points()
		current_line.closed = true
		selected = false
