extends Node

const SAVE_PATH: String = "user://save.json"
const LEVEL_SELECT: String = "res://UI/level_select.tscn"

const SPAWNED_SCENE_PATH: int = 0
const SPAWNED_X: int = 1
const SPAWNED_Y: int = 2
const SPAWNED_WIDTH: int = 3
const SPAWNED_HEIGHT: int = 4
const SPAWNED_ORIGIN_LEVEL: int = 5
const SPAWNED_ORIGIN_NODE: int = 6
const SPAWNED_BASIC_SIZE: int = 5
const SPAWNED_FULL_SIZE: int = 7

var levels: Dictionary = {}
var completed: Array = []
var recomplete: Array = []
var last_level: String = ""
var max_level: int = 1

var lasso_on: bool = false
var carried: Array = []

var home_level: String = ""
var home_player_pos: Vector2 = Vector2.ZERO
var restore_player_pos: bool = false


func _ready() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(data) == TYPE_DICTIONARY:
		levels = data.get("levels", {})
		completed = data.get("completed", [])
		recomplete = data.get("recomplete", [])
		last_level = data.get("last_level", "")
		max_level = int(data.get("max_level", 1))


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func level_number() -> int:
	return get_tree().current_scene.scene_file_path.get_file().to_int()

func level_state(level_id: int) -> int:
	if _has_level(recomplete, level_id):
		return 2
	if _has_level(completed, level_id):
		return 1
	return 0


func mark_recomplete(level_id: int) -> void:
	if not _has_level(recomplete, level_id):
		recomplete.append(level_id)


func complete_level() -> void:
	var current_level: int = level_number()
	if not _has_level(completed, current_level):
		completed.append(current_level)
	recomplete = _without_level(recomplete, current_level)
	max_level = maxi(max_level, current_level + 1)
	save_game()

func _has_level(list: Array, level_id: int) -> bool:
	return list.any(func(entry): return int(entry) == level_id)

func _without_level(list: Array, level_id: int) -> Array:
	return list.filter(func(entry): return int(entry) != level_id)

func visiting() -> bool:
	return home_level != ""

func home_level_number() -> int:
	return home_level.get_file().to_int()

func open_level_select_from_level() -> void:
	if not visiting():
		var level: Node = get_tree().current_scene
		var player: Node2D = level.get_node_or_null("Player")
		if player:
			home_player_pos = player.global_position
		save_game()
		home_level = level.scene_file_path
	get_tree().change_scene_to_file(LEVEL_SELECT)


func return_home() -> void:
	var target_level: String = home_level
	home_level = ""
	if target_level != "":
		restore_player_pos = true
		get_tree().change_scene_to_file(target_level)


func cancel_visit() -> void:
	home_level = ""
	restore_player_pos = false
	if carried.is_empty():
		lasso_on = false

func mark_removed(node_path: String) -> void:
	var level_path: String = get_tree().current_scene.scene_file_path
	var entry: Dictionary = levels.get(level_path, {})
	var removed: Array = entry.get("removed", [])
	removed.append(node_path)
	entry["removed"] = removed
	levels[level_path] = entry


func refresh_spawned() -> void:
	var level: Node = get_tree().current_scene
	var entry: Dictionary = levels.get(level.scene_file_path, {})
	entry["spawned"] = _spawned_list(level)
	levels[level.scene_file_path] = entry

func _spawned_list(level: Node) -> Array:
	var list: Array = []
	for node in get_tree().get_nodes_in_group("spawned"):
		if level.is_ancestor_of(node):
			list.append([
				node.scene_file_path,
				node.global_position.x, node.global_position.y,
				node.size.x, node.size.y,
				node.get_meta("origin", ""), node.get_meta("origin_name", ""),
			])
	return list

func reset_level(level_id: int) -> void:
	var level_path: String = "res://levels/level_%02d.tscn" % level_id

	_free_carried_blocks_from(level_path)
	_remove_spawned_blocks_from(level_path)
	_return_blocks_spawned_in(level_path)

	levels.erase(level_path)
	recomplete = _without_level(recomplete, level_id)
	completed = _without_level(completed, level_id)
	_write_file()

func _free_carried_blocks_from(level_path: String) -> void:
	for index in range(carried.size() - 1, -1, -1):
		var block: Node = carried[index]["block"]
		if block.get_meta("origin", "") == level_path:
			block.queue_free()
			carried.remove_at(index)

func _remove_spawned_blocks_from(level_path: String) -> void:
	for other_path in levels:
		if other_path == level_path:
			continue

		var entry: Dictionary = levels[other_path]
		var spawned: Array = entry.get("spawned", [])
		var kept: Array = spawned.filter(func(block_data):
			var has_origin: bool = block_data.size() >= SPAWNED_FULL_SIZE
			return not (has_origin and block_data[SPAWNED_ORIGIN_LEVEL] == level_path)
		)

		if kept.size() != spawned.size():
			entry["spawned"] = kept
			mark_recomplete(other_path.get_file().to_int())

func _return_blocks_spawned_in(level_path: String) -> void:
	var entry: Dictionary = levels.get(level_path, {})
	for block_data in entry.get("spawned", []):
		if block_data.size() < SPAWNED_FULL_SIZE:
			continue

		var origin_level: String = block_data[SPAWNED_ORIGIN_LEVEL]
		if origin_level != "" and origin_level != level_path:
			_return_block(origin_level, block_data[SPAWNED_ORIGIN_NODE])


func _return_block(origin_level: String, origin_node: String) -> void:
	var entry: Dictionary = levels.get(origin_level, {})

	var removed: Array = entry.get("removed", [])
	removed.erase(origin_node)
	entry["removed"] = removed

	var objects: Dictionary = entry.get("objects", {})
	objects.erase(origin_node)
	entry["objects"] = objects

	levels[origin_level] = entry

func save_game() -> void:
	var level: Node = get_tree().current_scene

	var nodes: Array = get_tree().get_nodes_in_group("persist")
	if nodes.is_empty():
		nodes = get_tree().get_nodes_in_group("platform")

	var objects: Dictionary = {}
	for node in nodes:
		if not level.is_ancestor_of(node) or node.is_in_group("spawned"):
			continue
		objects[str(level.get_path_to(node))] = [node.global_position.x, node.global_position.y]

	var entry: Dictionary = levels.get(level.scene_file_path, {})
	entry["objects"] = objects
	entry["spawned"] = _spawned_list(level)
	levels[level.scene_file_path] = entry
	last_level = level.scene_file_path
	_write_file()


func _write_file() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"levels": levels,
		"completed": completed,
		"recomplete": recomplete,
		"last_level": last_level,
		"max_level": max_level,
	}))
	file.close()

func apply_save() -> void:
	var level: Node = get_tree().current_scene
	var saved: Dictionary = levels.get(level.scene_file_path, {})

	_restore_moved_objects(level, saved)
	_delete_removed_objects(level, saved)
	_create_spawned_blocks(level, saved)


func _restore_moved_objects(level: Node, saved: Dictionary) -> void:
	var objects: Dictionary = saved.get("objects", {})
	for node_path in objects:
		var node: Node2D = level.get_node_or_null(NodePath(node_path))
		if node:
			node.global_position = Vector2(objects[node_path][0], objects[node_path][1])


func _delete_removed_objects(level: Node, saved: Dictionary) -> void:
	for node_path in saved.get("removed", []):
		var node: Node = level.get_node_or_null(NodePath(node_path))
		if node:
			node.queue_free()


func _create_spawned_blocks(level: Node, saved: Dictionary) -> void:
	for block_data in saved.get("spawned", []):
		if block_data.size() < SPAWNED_BASIC_SIZE:
			continue

		var block: Node2D = load(block_data[SPAWNED_SCENE_PATH]).instantiate()
		block.size = Vector2(block_data[SPAWNED_WIDTH], block_data[SPAWNED_HEIGHT])
		if block_data.size() >= SPAWNED_FULL_SIZE:
			block.set_meta("origin", block_data[SPAWNED_ORIGIN_LEVEL])
			block.set_meta("origin_name", block_data[SPAWNED_ORIGIN_NODE])
		block.add_to_group("spawned")
		level.add_child(block, true)
		block.global_position = Vector2(block_data[SPAWNED_X], block_data[SPAWNED_Y])

func play_level(level_id: int) -> void:
	var path: String = "res://levels/level_%02d.tscn" % level_id
	if ResourceLoader.exists(path):
		get_tree().change_scene_to_file(path)

func is_current_level_completed() -> bool:
	return level_state(level_number()) > 0

func new_game() -> void:
	for item in carried:
		item["block"].queue_free()
	carried.clear()
	lasso_on = false
	home_level = ""
	restore_player_pos = false
	max_level = 1
	levels.clear()
	completed.clear()
	recomplete.clear()
	last_level = ""
	play_level(1)
