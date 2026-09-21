class_name StateMachine
extends Node2D

@export var initial_state: Node2D
var current_state: Node2D
var previous_state: Node2D
# Called when the node enters the scene tree for the first time.
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
		previous_state = current_state
	current_state = new_state
	current_state.enter()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)
