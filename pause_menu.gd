extends Control

@onready var setting_menu: Control = $"../SettingMenu"

func _ready() -> void:
	hide()
	PauseHandler.paused.connect(_on_paused)


func _on_paused() -> void:
	visible = get_tree().paused


func _on_resume_button_pressed() -> void:
	PauseHandler.toggle_pause()


func _on_settings_button_pressed() -> void:
	setting_menu.visible = not setting_menu.visible


func _on_exit_button_pressed() -> void:
	PauseHandler.toggle_pause()
	get_tree().change_scene_to_file("res://UI/start_menu.tscn")


func _on_level_select_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/level_select.tscn")
