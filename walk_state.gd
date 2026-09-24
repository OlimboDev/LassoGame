extends GroundState

func enter() -> void:
	player.SPEED = player.WALK_SPEED
	if sprite:
		sprite.play("walk")

func physics_update(delta: float) -> void:
	super.physics_update(delta)
	idle_check(delta)
	
	if direction != 0 and Input.is_action_pressed("sprint"):
		state_machine.change_state(state_machine.sprint_state)
