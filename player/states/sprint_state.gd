extends GroundState

func enter() -> void:
	player.SPEED = player.SPRINT_SPEED
	sprite.play("sprint")
	
	
func physics_update(delta: float) -> void:
	super.physics_update(delta)
	if changed(): return
	idle_check(delta)
	
	if Input.is_action_just_released("sprint"):
		state_machine.change_state(state_machine.walk_state)
