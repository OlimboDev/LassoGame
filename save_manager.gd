extends Node

const SAVE_PATH := "user://save.json"
const LEVEL_SELECT := "res://UI/level_select.tscn"

var levels: Dictionary = {}
var completed: Array = []
var recomplete: Array = []
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
		recomplete = data.get("recomplete", [])
		last_level = data.get("last_level", "")
		max_level = int(data.get("max_level", 1))


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func level_number() -> int:
	return get_tree().current_scene.scene_file_path.get_file().to_int()

func level_state(n: int) -> int:
	if _has_level(recomplete, n):
		return 2
	if _has_level(completed, n):
		return 1
	return 0

func _has_level(list: Array, n: int) -> bool:
	return list.any(func(c): return int(c) == n)


func _without_level(list: Array, n: int) -> Array:
	return list.filter(func(c): return int(c) != n)


func mark_recomplete(n: int) -> void:
	if not _has_level(recomplete, n):
		recomplete.append(n)


func complete_level() -> void:
	var n := level_number()
	if not _has_level(completed, n):
		completed.append(n)
	recomplete = _without_level(recomplete, n)
	max_level = maxi(max_level, n + 1)
	save_game()

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
			list.append([
				node.scene_file_path,
				node.global_position.x, node.global_position.y,
				node.size.x, node.size.y,
				node.get_meta("origin", ""), node.get_meta("origin_name", ""),
			])
	return list

func refresh_spawned() -> void:
	var level := get_tree().current_scene
	var entry: Dictionary = levels.get(level.scene_file_path, {})
	entry["spawned"] = _spawned_list(level)
	levels[level.scene_file_path] = entry

func reset_level(n: int) -> void:
	var key := "res://levels/level_%02d.tscn" % n

	for i in range(carried.size() - 1, -1, -1):
		var block: Node = carried[i]["block"]
		if block.get_meta("origin", "") == key:
			block.queue_free()
			carried.remove_at(i)

	for other_key in levels:
		if other_key == key:
			continue
		var entry: Dictionary = levels[other_key]
		var spawned: Array = entry.get("spawned", [])
		var kept := spawned.filter(func(s): return not (s.size() >= 7 and s[5] == key))
		if kept.size() != spawned.size():
			entry["spawned"] = kept
			mark_recomplete(other_key.get_file().to_int())

	var own: Dictionary = levels.get(key, {})
	for s in own.get("spawned", []):
		if s.size() >= 7 and s[5] != "" and s[5] != key:
			_return_block(s[5], s[6])

	levels.erase(key)
	recomplete = _without_level(recomplete, n)
	completed = _without_level(completed, n)
	_write_file()

func _return_block(origin_key: String, origin_name: String) -> void:
	var entry: Dictionary = levels.get(origin_key, {})
	var removed: Array = entry.get("removed", [])
	removed.erase(origin_name)
	entry["removed"] = removed
	var objects: Dictionary = entry.get("objects", {})
	objects.erase(origin_name)
	entry["objects"] = objects
	levels[origin_key] = entry


# --- Opslaan en laden ---

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
	_write_file()


func _write_file() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"levels": levels,
		"completed": completed,
		"recomplete": recomplete,
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
		if s.size() >= 7:
			block.set_meta("origin", s[5])
			block.set_meta("origin_name", s[6])
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
	recomplete.clear()
	last_level = ""
	play_level(1)
