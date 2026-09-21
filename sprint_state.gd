extends WalkState

@onready var walk_state: State = $"../walk_state"

func enter() -> void:
	speed_multiplier = 2
	sprite.play("sprint")
	
	
func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	if Input.is_action_just_released("sprint"):
		state_machine.change_state(walk_state)
