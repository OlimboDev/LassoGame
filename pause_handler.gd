extends Node

signal paused

var enabled: bool = false
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and enabled:
		_change_paused()
		get_viewport().set_input_as_handled()

func _change_paused():
		get_tree().paused = not get_tree().paused
		paused.emit()
	
