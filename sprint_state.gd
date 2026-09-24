extends WalkState

func enter() -> void:
	sprite.play("sprint")
	
	
func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	if Input.is_action_just_released("sprint"):
		state_machine.change_state(state_machine.walk_state)
