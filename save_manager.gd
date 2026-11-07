extends Node

const SAVE_PATH := "user://save.json"

var levels: Dictionary = {}
var completed: Array = []
var last_level: String = ""


func _ready() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(data) == TYPE_DICTIONARY:
		levels = data.get("levels", {})
		completed = data.get("completed", [])
		last_level = data.get("last_level", "")


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game() -> void:
	var level := get_tree().current_scene
	var nodes := get_tree().get_nodes_in_group("persist")
	if nodes.is_empty():
		nodes = get_tree().get_nodes_in_group("platform")

	var objects := {}
	for node in nodes:
		if node.is_in_group("spawned"):
			continue
		objects[str(level.get_path_to(node))] = [node.global_position.x, node.global_position.y]

	var spawned := []
	for node in get_tree().get_nodes_in_group("spawned"):
		spawned.append([node.scene_file_path, node.global_position.x, node.global_position.y])

	levels[level.scene_file_path] = {"objects": objects, "spawned": spawned}
	last_level = level.scene_file_path

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"levels": levels,
		"completed": completed,
		"last_level": last_level,
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

	for s in saved.get("spawned", []):
		var block: Node2D = load(s[0]).instantiate()
		block.add_to_group("spawned")
		level.add_child(block)
		block.global_position = Vector2(s[1], s[2])


func play_level(nummer: int) -> void:
	get_tree().change_scene_to_file("res://levels/level_%02d.tscn" % nummer)


func continue_game() -> void:
	if last_level != "":
		get_tree().change_scene_to_file(last_level)


func new_game() -> void:
	levels.clear()
	completed.clear()
	last_level = ""
	play_level(1)
