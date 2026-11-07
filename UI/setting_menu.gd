extends Control

@export var music_slider: HSlider
@export var SFX_Slider: HSlider
@export var window_mode_button: OptionButton
@export var vsync_check: CheckBox
@export var resolution_button: OptionButton

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(640, 360),
	Vector2i(854, 480),
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160),
]

var windowed_size := Vector2i(1280, 720)
var window_mode_index := 0
var enabled: bool = false
var waiting_button: Button = null
var swallow_release_keycode: Key = KEY_NONE

func _ready() -> void:
	
	print(LoadSFX.get_path())
	print(LoadSFX.get_children())
	_preload_settings()

	music_slider.value_changed.connect(_on_music_slider_value_changed)
	SFX_Slider.value_changed.connect(_on_SFX_slider_value_changed)
	_on_music_slider_value_changed(0.5)
	_on_SFX_slider_value_changed(0.5)


func _preload_settings() -> void:
	match DisplayServer.window_get_mode():
		DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			window_mode_index = 2
		_:
			var borderless := DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)
			window_mode_index = 1 if borderless else 0
	window_mode_button.selected = window_mode_index

	var res_index := RESOLUTIONS.find(windowed_size)
	if res_index != -1:
		resolution_button.selected = res_index
	resolution_button.disabled = window_mode_index == 2

	vsync_check.set_pressed_no_signal(
		DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED
	)


func _unhandled_input(event: InputEvent) -> void:
	if waiting_button == null:
		if event.is_action_pressed("ui_cancel") and visible:
			visible = false
			get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.pressed and not event.echo:
		var action: String = waiting_button.get_meta("action", "")
		if action != "":
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)
			waiting_button.text = event.as_text().to_upper()
		waiting_button = null
		get_viewport().set_input_as_handled()

func _on_music_slider_value_changed(value: float) -> void:
	var bus_index := AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value < 0.001)


func _on_SFX_slider_value_changed(value: float) -> void:
	var bus_index := AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value < 0.001)

func _on_window_mode_item_selected(index: int) -> void:
	window_mode_index = index

	match index:
		0: # Windowed
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

		1: # Borderless
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

		2: # Fullscreen
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	_apply_resolution()

func _on_v_sync_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED)

func _on_resolution_item_selected(index: int) -> void:
	windowed_size = RESOLUTIONS[index]
	_apply_resolution()


func _apply_resolution() -> void:
	resolution_button.disabled = window_mode_index == 2
	if window_mode_index == 2:
		return

	var screen := DisplayServer.window_get_current_screen()
	var screen_pos := DisplayServer.screen_get_position(screen)
	var screen_size := DisplayServer.screen_get_size(screen)
	DisplayServer.window_set_size(windowed_size)
	DisplayServer.window_set_position(screen_pos + (screen_size - windowed_size) / 2)


func _on_visibility_changed() -> void:
	
		if not enabled:
			LoadSFX.close_menu()
			PauseHandler.enabled = true
			enabled = true
		else:
			LoadSFX.open_menu()
			PauseHandler.enabled = false
			enabled = false
			



func _on_keybind_button_pressed(path: NodePath) -> void:
	var btn: Button = get_node(path)
	btn.release_focus()
	waiting_button = btn
	btn.text = "..."


func _on_tab_container_tab_changed(tab: int) -> void:
	if not enabled:
		LoadSFX.tab_switch()
