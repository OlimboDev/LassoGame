extends Control

@onready var grid: GridContainer = $MarginContainer/VBoxContainer/GridContainer

@export var back_button: Button
@export var reset_button: Button
@export var info_label: Label

var is_reset_mode: bool = false

func _ready() -> void:
	get_tree().paused = false
	PauseHandler.enabled = false
	
	if reset_button:
		reset_button.disabled = SaveManager.visiting()

	for level_button in grid.get_children():
		level_button.selected.connect(_on_level_selected)

	_refresh()

func _refresh() -> void:
	var highest_playable: int = SaveManager.max_level
	if SaveManager.visiting():
		highest_playable = mini(highest_playable, SaveManager.home_level_number() - 1)

	for level_button in grid.get_children():
		var level_number: int = level_button.levelText
		var level_exists: bool = ResourceLoader.exists("res://levels/level_%02d.tscn" % level_number)
		level_button.unlocked = level_exists and level_number <= highest_playable
		level_button.state = SaveManager.level_state(level_number)


func _on_level_selected(level_number: int) -> void:
	if is_reset_mode:
		SaveManager.reset_level(level_number)
		is_reset_mode = false
		if reset_button:
			reset_button.text = "Reset level"
		if info_label:
			info_label.text = "Level %d has been reset." % level_number
		_refresh()
	else:
		SaveManager.play_level(level_number)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed()

func _on_back_button_pressed() -> void:
	if SaveManager.visiting():
		SaveManager.return_home()
	else:
		get_tree().change_scene_to_file("res://UI/start_menu.tscn")


func _on_reset_button_pressed() -> void:
	is_reset_mode = not is_reset_mode
	if is_reset_mode:
		if reset_button:
			reset_button.text = "Cancel Reset"
		if info_label:
			info_label.text = "Click a level to reset it."
	else:
		if reset_button:
			reset_button.text = "Reset level"
		if info_label:
			info_label.text = ""
