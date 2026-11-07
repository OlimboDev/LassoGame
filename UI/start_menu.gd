extends Control

@onready var setting_menu: Control = $SettingMenu
@onready var continue_button: Button = $VBoxContainer/ContinueButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not SaveManager.has_save():
		continue_button.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_setting_button_pressed() -> void:
	setting_menu.visible = not setting_menu.visible
	
func _on_start_button_pressed() -> void:
	SaveManager.new_game()


func _on_continue_button_pressed() -> void:
	SaveManager.continue_game()
