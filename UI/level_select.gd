extends Control

@onready var vbox: VBoxContainer = $MarginContainer/VBoxContainer
@onready var grid: GridContainer = $MarginContainer/VBoxContainer/GridContainer


func _ready() -> void:
	get_tree().paused = false
	PauseHandler.enabled = false
	var back_button := Button.new()
	back_button.text = "Back"
	back_button.theme = load("res://Theme.tres")
	back_button.theme_type_variation = &"QuitButton"
	back_button.pressed.connect(_on_back_pressed)
	vbox.add_child(back_button)
	var limit := SaveManager.max_level
	if SaveManager.visiting():
		limit = mini(limit, SaveManager.home_level_number() - 1)

	for button in grid.get_children():
		var n: int = button.levelText
		var exists := ResourceLoader.exists("res://levels/level_%02d.tscn" % n)
		button.unlocked = exists and n <= limit
		var is_completed := SaveManager.completed.any(func(c): return int(c) == n)
		button.state = 1 if is_completed else 0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()


func _on_back_pressed() -> void:
	if SaveManager.visiting():
		SaveManager.return_home()
	else:
		get_tree().change_scene_to_file("res://UI/start_menu.tscn")
