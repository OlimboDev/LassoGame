class_name Lasso
extends Node2D

signal loop_closed
signal loop_deleted
signal loop_accepted
signal loop_moved(offset: Vector2)

const MIN_POINT_DISTANCE: float = 5.0

@onready var current_line: Line2D = $Line2D

var selected: bool = false
var dragging: bool = false
var previous_mouse_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	current_line.closed = true


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("cancel"):
		_reset()
		loop_deleted.emit()
	elif selected and Input.is_action_just_pressed("paste"):
		_reset()
		loop_accepted.emit()
	elif selected:
		_drag_loop()
	else:
		_draw_loop()


func get_polygon() -> PackedVector2Array:
	return current_line.global_transform * current_line.points


func _reset() -> void:
	current_line.clear_points()
	selected = false
	dragging = false
	global_position = Vector2.ZERO


func _draw_loop() -> void:
	if Input.is_action_just_pressed("mouseClick"):
		current_line.clear_points()
		current_line.default_color = Color.WHITE

	elif Input.is_action_pressed("mouseClick"):
		var mouse_pos := current_line.get_local_mouse_position()
		var count := current_line.get_point_count()
		if count == 0 or current_line.get_point_position(count - 1).distance_to(mouse_pos) >= MIN_POINT_DISTANCE:
			current_line.add_point(mouse_pos)

	elif Input.is_action_just_released("mouseClick") and current_line.get_point_count() > 2:
		selected = true
		current_line.default_color = Color.BLUE
		loop_closed.emit()


func _drag_loop() -> void:
	var mouse_pos := get_global_mouse_position()

	if Input.is_action_just_pressed("mouseClick"):
		previous_mouse_pos = mouse_pos
		dragging = Geometry2D.is_point_in_polygon(mouse_pos, get_polygon())

	if Input.is_action_just_released("mouseClick"):
		dragging = false

	if dragging:
		var offset := mouse_pos - previous_mouse_pos
		global_position += offset
		previous_mouse_pos = mouse_pos
		loop_moved.emit(offset)
