extends Node

const SAVE_PATH := "user://save.json"
const LEVEL_SELECT := "res://UI/level_select.tscn"

var levels: Dictionary = {}
var completed: Array = []
var last_level: String = ""
var max_level: int = 1

var lasso_on: bool = false
var carried: Array = []

var home_level: String = ""
var home_player_pos := Vector2.ZERO
var restore_player_pos: bool = false


func _ready() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(data) == TYPE_DICTIONARY:
		levels = data.get("levels", {})
		completed = data.get("completed", [])
		last_level = data.get("last_level", "")
		max_level = int(data.get("max_level", 1))


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func level_number() -> int:
	return get_tree().current_scene.scene_file_path.get_file().to_int()

func visiting() -> bool:
	return home_level != ""


func home_level_number() -> int:
	return home_level.get_file().to_int()

func open_level_select_from_level() -> void:
	if not visiting():
		var level := get_tree().current_scene
		var player := level.get_node_or_null("Player")
		if player:
			home_player_pos = player.global_position
		save_game()
		home_level = level.scene_file_path
	get_tree().change_scene_to_file(LEVEL_SELECT)

func return_home() -> void:
	var target := home_level
	home_level = ""
	if target != "":
		restore_player_pos = true
		get_tree().change_scene_to_file(target)

func cancel_visit() -> void:
	home_level = ""
	restore_player_pos = false
	if carried.is_empty():
		lasso_on = false

func mark_removed(path: String) -> void:
	var key := get_tree().current_scene.scene_file_path
	var entry: Dictionary = levels.get(key, {})
	var removed: Array = entry.get("removed", [])
	removed.append(path)
	entry["removed"] = removed
	levels[key] = entry

func _spawned_list(level: Node) -> Array:
	var list := []
	for node in get_tree().get_nodes_in_group("spawned"):
		if level.is_ancestor_of(node):
			list.append([node.scene_file_path, node.global_position.x, node.global_position.y, node.size.x, node.size.y])
	return list

func refresh_spawned() -> void:
	var level := get_tree().current_scene
	var entry: Dictionary = levels.get(level.scene_file_path, {})
	entry["spawned"] = _spawned_list(level)
	levels[level.scene_file_path] = entry


func complete_level() -> void:
	var n := level_number()
	if not completed.has(n):
		completed.append(n)
	max_level = maxi(max_level, n + 1)
	save_game()


func save_game() -> void:
	var level := get_tree().current_scene
	var nodes := get_tree().get_nodes_in_group("persist")
	if nodes.is_empty():
		nodes = get_tree().get_nodes_in_group("platform")

	var objects := {}
	for node in nodes:
		if not level.is_ancestor_of(node) or node.is_in_group("spawned"):
			continue
		objects[str(level.get_path_to(node))] = [node.global_position.x, node.global_position.y]

	var entry: Dictionary = levels.get(level.scene_file_path, {})
	entry["objects"] = objects
	entry["spawned"] = _spawned_list(level)
	levels[level.scene_file_path] = entry
	last_level = level.scene_file_path

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"levels": levels,
		"completed": completed,
		"last_level": last_level,
		"max_level": max_level,
	}))
	file.close()


func apply_save() -> void:
	var level := get_tree().current_scene
	var saved: Dictionary = levels.get(level.scene_file_path, {})

	var objects: Dictionary = saved.get("objects", {})
	for path in objects:
		var node := level.get_node_or_null(NodePath(path))
		if node:
			node.global_position = Vector2(objects[path][0], objects[path][1])

	for path in saved.get("removed", []):
		var node := level.get_node_or_null(NodePath(path))
		if node:
			node.queue_free()

	for s in saved.get("spawned", []):
		if s.size() < 5:
			continue
		var block: Node2D = load(s[0]).instantiate()
		block.size = Vector2(s[3], s[4])
		block.add_to_group("spawned")
		level.add_child(block, true)
		block.global_position = Vector2(s[1], s[2])


func play_level(nummer: int) -> void:
	var path := "res://levels/level_%02d.tscn" % nummer
	if ResourceLoader.exists(path):
		get_tree().change_scene_to_file(path)


func continue_game() -> void:
	if last_level != "":
		get_tree().change_scene_to_file(last_level)


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
	last_level = ""
	play_level(1)
