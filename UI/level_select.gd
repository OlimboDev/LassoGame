extends Control

@onready var vbox: VBoxContainer = $MarginContainer/VBoxContainer
@onready var grid: GridContainer = $MarginContainer/VBoxContainer/GridContainer

var reset_button: Button
var info_label: Label


func _ready() -> void:
	get_tree().paused = false
	PauseHandler.enabled = false

	var theme_res: Theme = load("res://Theme.tres")

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	vbox.add_child(row)

	var back_button := _make_button("Back", theme_res)
	back_button.pressed.connect(_on_back_pressed)
	row.add_child(back_button)

	reset_button = _make_button("Reset level", theme_res)
	reset_button.toggle_mode = true
	reset_button.disabled = SaveManager.visiting()
	reset_button.toggled.connect(_on_reset_toggled)
	row.add_child(reset_button)

	info_label = Label.new()
	info_label.theme = theme_res
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(info_label)

	for button in grid.get_children():
		button.selected.connect(_on_level_selected)

	_refresh()


func _make_button(text: String, theme_res: Theme) -> Button:
	var b := Button.new()
	b.text = text
	b.theme = theme_res
	b.theme_type_variation = &"QuitButton"
	return b

func _refresh() -> void:
	var limit := SaveManager.max_level
	if SaveManager.visiting():
		limit = mini(limit, SaveManager.home_level_number() - 1)

	for button in grid.get_children():
		var n: int = button.levelText
		var exists := ResourceLoader.exists("res://levels/level_%02d.tscn" % n)
		button.unlocked = exists and n <= limit
		button.state = SaveManager.level_state(n)


func _on_level_selected(n: int) -> void:
	if reset_button.button_pressed:
		SaveManager.reset_level(n)
		reset_button.set_pressed_no_signal(false)
		info_label.text = "Level %d is gereset." % n
		_refresh()
	else:
		SaveManager.play_level(n)


func _on_reset_toggled(on: bool) -> void:
	info_label.text = "Click a level to reset it." if on else ""


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()


func _on_back_pressed() -> void:
	if SaveManager.visiting():
		SaveManager.return_home() 
	else:
		get_tree().change_scene_to_file("res://UI/start_menu.tscn")
