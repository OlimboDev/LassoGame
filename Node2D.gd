class_name BaseLevel
extends Node2D

@export var lasso: Lasso

func _ready() -> void:
	lasso.loop_closed.connect(_on_lasso_closed)
	lasso.loop_deleted.connect(_on_lasso_deleted)

func _on_lasso_closed() -> void:
	var line = lasso.get_node_or_null("Line2D")
	if not line or line.get_point_count() < 3:
		return

	var lasso_points: PackedVector2Array = []
	for point in line.points:
		lasso_points.append(line.to_global(point))

	for child in get_children():
		if child == lasso:
			continue

		# Process only platforms that have a CollisionShape2D
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
					var nine_patch = child.get_node_or_null("NinePatchRect")
					if nine_patch and nine_patch.material:
						var mat = nine_patch.material.duplicate()
						nine_patch.material = mat
						mat.set_shader_parameter("strength", 0.7)

func _on_lasso_deleted() -> void:
	for child in get_children():
		if child == lasso:
			continue

		if child.name.begins_with("Platform"):
			var nine_patch = child.get_node_or_null("NinePatchRect")
			if nine_patch and nine_patch.material:
				nine_patch.material.set_shader_parameter("strength", 0.0)
