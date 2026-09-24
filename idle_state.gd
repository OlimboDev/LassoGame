extends GroundState

func enter() -> void:
	if sprite:
		sprite.play("idle")

func physics_update(delta: float) -> void:
	super.physics_update(delta)
		
	if Input.get_axis("moveLeft", "moveRight") != 0:
		state_machine.change_state(state_machine.walk_state)
