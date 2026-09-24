extends AirState

const JUMP_VELOCITY = -400.0

func enter() -> void:
	player.velocity.y = JUMP_VELOCITY
	sprite.play("jump")
	

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	if player.is_on_floor() and player.velocity.y >= 0:
			state_machine.change_state(state_machine.idle_state)
			
	if player.velocity.y > 0:
		state_machine.change_state(state_machine.fall_state)
