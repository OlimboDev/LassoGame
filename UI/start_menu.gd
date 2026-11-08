extends Control

@onready var setting_menu: Control = $SettingMenu
@onready var continue_button: Button = $PanelContainer/MarginContainer/VBoxContainer/ContinueButton


func _ready() -> void:
	continue_button.visible = SaveManager.has_save()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_setting_button_pressed() -> void:
	setting_menu.visible = not setting_menu.visible


func _on_start_button_pressed() -> void:
	SaveManager.new_game()


func _on_continue_button_pressed() -> void:
	SaveManager.continue_game()
