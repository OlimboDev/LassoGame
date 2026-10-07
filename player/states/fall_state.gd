extends AirState

func enter() -> void:
	if sprite:
		sprite.play("fall")

func physics_update(delta: float) -> void:
	super.physics_update(delta)
	if changed():
		return

	if not player.coyote_timer.is_stopped() and Input.is_action_just_pressed("jump"):
		state_machine.change_state(state_machine.jump_state)
