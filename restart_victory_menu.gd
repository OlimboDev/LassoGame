extends Control

func _ready() -> void:
	hide()


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/start_menu.tscn")


func _on_next_button_pressed() -> void:
	var current_level = get_tree().current_scene.scene_file_path

	var level_number = int(current_level.get_file().get_basename().trim_prefix("level_"))
	var next_level_number = level_number + 1

	var next_level_path = "res://levels/level_%02d.tscn" % next_level_number

	print_debug(next_level_path)
	get_tree().change_scene_to_file(next_level_path)


func _on_select_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/level_select.tscn")
