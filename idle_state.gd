extends State

func enter() -> void:
	player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
	if sprite:
		sprite.play("idle")

func physics_update(_delta: float) -> void:
	if player.is_on_floor() and Input.is_action_just_pressed("jump"):
		state_machine.change_state(state_machine.jump_state)
		
	if Input.get_axis("moveLeft", "moveRight") != 0:
		state_machine.change_state(state_machine.walk_state)
