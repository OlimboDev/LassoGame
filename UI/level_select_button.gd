class_name LevelButton
extends Control

@onready var button: Button = $Button
@onready var completion_mark: TextureRect = $CompletionMark

@export var levelText: int = 0:
	set(value):
		levelText = value
		if button:
			button.text = str(levelText)

@export_enum("Uncompleted", "Completed", "Needs Recompletion") var state: int = 0:
	set(value):
		state = value
		if completion_mark and completion_mark.has_method("update_svg_colors"):
			completion_mark.update_svg_colors(state)
			
@export var unlocked: bool = false:
	set(value):
		unlocked = value
		_update_status()

func _ready() -> void:
	button.text = str(levelText)
	completion_mark.update_svg_colors(state)
	_update_status()

func _update_status() -> void:
	if button:
		button.disabled = not unlocked
	if completion_mark:
		completion_mark.visible = unlocked

func _on_button_pressed() -> void:
	SaveManager.play_level(levelText)
