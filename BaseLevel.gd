class_name BaseLevel
extends Node2D

@onready var lasso: Lasso = $Lasso
@onready var restart_menu: Control = $CanvasLayer/restart_menu

var selected_blocks := {}


func _ready() -> void:
	SaveManager.apply_save()
	PauseHandler.enabled = true
	get_tree().paused = false

	lasso.loop_closed.connect(_on_lasso_closed)
	lasso.loop_deleted.connect(_on_lasso_deleted)
	lasso.loop_accepted.connect(_clear_selection)
	lasso.loop_moved.connect(_on_lasso_moved)


func _get_platforms() -> Array:
	return get_children().filter(func(child): return child.name.begins_with("Platform"))


func _set_highlight(platform: Node, strength: float) -> void:
	var nine_patch = platform.get_node_or_null("NinePatchRect")
	if nine_patch and nine_patch.material:
		nine_patch.material.set_shader_parameter("strength", strength)


func _is_inside(platform: Node, polygon: PackedVector2Array) -> bool:
	var collision_shape = platform.get_node_or_null("CollisionShape2D")
	if not collision_shape or not (collision_shape.shape is RectangleShape2D):
		return false

	var rect := Rect2(collision_shape.global_position - collision_shape.shape.size / 2.0, collision_shape.shape.size)
	var corners := [
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y),
	]
	return corners.all(func(corner): return Geometry2D.is_point_in_polygon(corner, polygon))


func _on_lasso_closed() -> void:
	var polygon := lasso.get_polygon()
	for platform in _get_platforms():
		if _is_inside(platform, polygon):
			selected_blocks[platform] = platform.global_position
			var nine_patch = platform.get_node_or_null("NinePatchRect")
			if nine_patch and nine_patch.material:
				nine_patch.material = nine_patch.material.duplicate()
			_set_highlight(platform, 0.7)


func _on_lasso_moved(offset: Vector2) -> void:
	for block in selected_blocks:
		block.global_position += offset


func _on_lasso_deleted() -> void:
	for block in selected_blocks:
		block.global_position = selected_blocks[block]
	_clear_selection()


func _clear_selection() -> void:
	selected_blocks.clear()
	for platform in _get_platforms():
		_set_highlight(platform, 0.0)


func _on_spike_body_entered(_body: Node2D) -> void:
	PauseHandler.enabled = false
	restart_menu.visible = true
	get_tree().paused = true


func _on_flag_body_entered(_body: Node2D) -> void:
	SaveManager.save_game()
