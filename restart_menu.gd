extends Control


func _ready() -> void:
	hide()


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/start_menu.tscn")
