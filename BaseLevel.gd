class_name BaseLevel
extends Node2D

@onready var lasso: Lasso = $Lasso
@onready var pause_menu: Control = $CanvasLayer/PauseMenu
@onready var restart_menu: Control = $CanvasLayer/restart_menu

var selected_blocks: Array[Node2D] = []
var original_positions: Dictionary = {}


func _ready() -> void:
	SaveManager.apply_save()
	PauseHandler.enabled = true
	get_tree().paused = false
	lasso.loop_closed.connect(_on_lasso_closed)
	lasso.loop_deleted.connect(_on_lasso_deleted)
	lasso.loop_moved.connect(_on_lasso_moved)
	lasso.loop_accepted.connect(_on_lasso_accepted)

func _on_lasso_moved(offset: Vector2) -> void:
	for block in selected_blocks:
		block.global_position += offset

func _on_lasso_closed() -> void:
	var line = lasso.get_node_or_null("Line2D")
	if not line or line.get_point_count() < 3:
		return

	# Vorige selectie leegmaken
	selected_blocks.clear()
	original_positions.clear()

	var lasso_points: PackedVector2Array = []
	for point in line.points:
		lasso_points.append(line.to_global(point))

	for child in get_children():
		if child == lasso:
			continue

		if child.name.begins_with("Platform"):
			var collision_shape = child.get_node_or_null("CollisionShape2D")
			if not collision_shape or not collision_shape.shape:
				continue

			var shape = collision_shape.shape
			if shape is RectangleShape2D:
				var half_size = shape.size / 2.0
				var center = collision_shape.global_position

				var corners = [
					center + Vector2(-half_size.x, -half_size.y),
					center + Vector2( half_size.x, -half_size.y),
					center + Vector2( half_size.x,  half_size.y),
					center + Vector2(-half_size.x,  half_size.y)
				]

				var completely_inside = true
				for corner in corners:
					if not Geometry2D.is_point_in_polygon(corner, lasso_points):
						completely_inside = false
						break

				if completely_inside:
					selected_blocks.append(child)
					original_positions[child] = child.global_position

					var nine_patch = child.get_node_or_null("NinePatchRect")
					if nine_patch and nine_patch.material:
						var mat = nine_patch.material.duplicate()
						nine_patch.material = mat
						mat.set_shader_parameter("strength", 0.7)

func _on_lasso_accepted() -> void:
	selected_blocks.clear()
	original_positions.clear()
	_reset_highlight()

func _on_lasso_deleted() -> void:
	for block in selected_blocks:
		if is_instance_valid(block) and original_positions.has(block):
			block.global_position = original_positions[block]

	selected_blocks.clear()
	original_positions.clear()

	for child in get_children():
		if child == lasso:
			continue

		if child.name.begins_with("Platform"):
			var nine_patch = child.get_node_or_null("NinePatchRect")
			if nine_patch and nine_patch.material:
				nine_patch.material.set_shader_parameter("strength", 0.0)

func _reset_highlight() -> void:
	for child in get_children():
		if child == lasso:
			continue

		if child.name.begins_with("Platform"):
			var nine_patch = child.get_node_or_null("NinePatchRect")
			if nine_patch and nine_patch.material:
				nine_patch.material.set_shader_parameter("strength", 0.0)


func _on_spike_body_entered(body: Node2D) -> void:
	PauseHandler.enabled = false
	restart_menu.visible = true
	pause_menu.is_respawning = true
	get_tree().paused = true
	await get_tree().process_frame
	pause_menu.is_respawning = false
	


func _on_flag_body_entered(body: Node2D) -> void:
	SaveManager.save_game()
