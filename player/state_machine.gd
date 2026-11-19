class_name StateMachine
extends Node2D


@export_category("States")
@export_subgroup("setup")
@export var idle_state: State
@export var walk_state: State
@export var sprint_state: State
@export var jump_state: State
@export var fall_state: State
@export_subgroup("")
@export var initial_state: State

var current_state: State

func _ready() -> void:
	for child in get_children():
		if child is State:
			child.player = owner
			child.state_machine = self
			child.sprite = $"../AnimatedSprite2D"
	if (initial_state):
		change_state(initial_state)
	
func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)
