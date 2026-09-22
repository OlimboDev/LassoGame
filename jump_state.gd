extends State

const JUMP_VELOCITY = -400.0

@onready var walk_state: State = $"../walk_state"
@onready var idle_state: State = $"../idle_state"

func enter() -> void:
	if player.is_on_floor():
		player.velocity.y = JUMP_VELOCITY

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	if player.is_on_floor() and player.velocity.y >= 0:
			state_machine.change_state(idle_state)

func handle_input(_event: InputEvent) -> void:
	pass
