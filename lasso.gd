class_name Lasso
extends Node2D

signal loop_closed
signal loop_deleted
signal loop_accepted
signal loop_moved(offset: Vector2)

var selected: bool = false
var dragging: bool = false
@onready var current_line: Line2D = $Line2D
var previous_mouse_pos: Vector2 = Vector2.ZERO

const MIN_POINT_DISTANCE: float = 5.0

func _ready() -> void:
	current_line.closed = true

func _process(_delta: float) -> void:
	var current_mouse_pos = get_global_mouse_position()

	if not selected:
		if Input.is_action_just_pressed("mouseClick"):
			current_line.clear_points()
			current_line.default_color = Color.WHITE

		elif Input.is_action_pressed("mouseClick"):
			var count = current_line.get_point_count()
			var local_mouse_pos = current_line.to_local(current_mouse_pos)
			if count == 0 or current_line.get_point_position(count - 1).distance_to(local_mouse_pos) >= MIN_POINT_DISTANCE:
				current_line.add_point(local_mouse_pos)

		elif Input.is_action_just_released("mouseClick"):
			if current_line.get_point_count() > 2:
				selected = true
				current_line.default_color = Color.BLUE
				loop_closed.emit()

	else:
		if Input.is_action_just_pressed("mouseClick"):
			previous_mouse_pos = current_mouse_pos
			dragging = _is_inside_loop(current_mouse_pos)

		if dragging and Input.is_action_pressed("mouseClick"):
			var move_offset = current_mouse_pos - previous_mouse_pos
			global_position += move_offset
			previous_mouse_pos = current_mouse_pos
			loop_moved.emit(move_offset)

		if Input.is_action_just_released("mouseClick"):
			dragging = false

	if Input.is_action_just_pressed("cancel"):
		current_line.clear_points()
		selected = false
		dragging = false
		global_position = Vector2.ZERO
		loop_deleted.emit()
		
	if selected and Input.is_action_just_pressed("paste"):
		current_line.clear_points()
		selected = false
		dragging = false
		global_position = Vector2.ZERO
		loop_accepted.emit()

func _is_inside_loop(global_point: Vector2) -> bool:
	var poly: PackedVector2Array = []
	for polys in current_line.points:
		poly.append(current_line.to_global(polys))
	return Geometry2D.is_point_in_polygon(global_point, poly)
