class_name BaseLevel
extends Node2D

@onready var lasso: Lasso = $Lasso
@onready var restart_menu: Control = $CanvasLayer/restart_menu
@onready var victory_menu: Control = $CanvasLayer/victory_menu

var selected_blocks := {}


func _ready() -> void:
	SaveManager.apply_save()
	SaveManager.max_level = maxi(SaveManager.max_level, SaveManager.level_number())
	PauseHandler.enabled = true
	get_tree().paused = false

	if SaveManager.restore_player_pos:
		SaveManager.restore_player_pos = false
		var player := get_node_or_null("Player")
		if player:
			player.global_position = SaveManager.home_player_pos

	lasso.loop_closed.connect(_on_lasso_closed)
	lasso.loop_deleted.connect(_on_lasso_deleted)
	lasso.loop_accepted.connect(_on_lasso_accepted)
	lasso.loop_moved.connect(_on_lasso_moved)


func _process(_delta: float) -> void:
	if not SaveManager.lasso_on:
		return

	if SaveManager.carried.is_empty() and Input.is_action_just_pressed("level_select"):
		_on_lasso_deleted()
		SaveManager.open_level_select_from_level()
		return

	if SaveManager.carried.is_empty():
		return
	var mouse_pos := get_global_mouse_position()
	for item in SaveManager.carried:
		item["block"].global_position = mouse_pos + item["offset"]
	if Input.is_action_just_pressed("paste"):
		_place_carried()


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

func _on_lasso_accepted() -> void:
	if SaveManager.visiting():
		if selected_blocks.is_empty():
			return
		_take_selected()
		SaveManager.return_home()
	else:
		_clear_selection()

func _take_selected() -> void:
	var center := Vector2.ZERO
	for block in selected_blocks:
		center += block.global_position
	center /= selected_blocks.size()

	for block in selected_blocks:
		if not block.has_meta("origin"):
			block.set_meta("origin", scene_file_path)
			block.set_meta("origin_name", str(get_path_to(block)))

		SaveManager.carried.append({"block": block, "offset": block.global_position - center})
		if not block.is_in_group("spawned"):
			SaveManager.mark_removed(str(get_path_to(block)))
		remove_child(block)
		SaveManager.add_child(block)
		_set_highlight(block, 0.0)
	selected_blocks.clear()

	SaveManager.mark_recomplete(SaveManager.level_number())
	SaveManager.refresh_spawned()

func _place_carried() -> void:
	for item in SaveManager.carried:
		var block: Node2D = item["block"]
		var pos := block.global_position
		SaveManager.remove_child(block)
		add_child(block, true)
		block.global_position = pos
		block.add_to_group("spawned")
	SaveManager.carried.clear()
	SaveManager.save_game()


func _on_spike_body_entered(_body: Node2D) -> void:
	PauseHandler.enabled = false
	restart_menu.visible = true
	get_tree().paused = true


func _on_flag_body_entered(_body: Node2D) -> void:
	SaveManager.complete_level()
	victory_menu.visible = true
	get_tree().paused = true
