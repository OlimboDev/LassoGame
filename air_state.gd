class_name AirState
extends State


func physics_update(delta: float) -> void:
	super.physics_update(delta)
	if Input.is_action_pressed("sprint"):
		player.SPEED = player.SPRINT_SPEED
	else:
		player.SPEED = player.WALK_SPEED
	move_horizontal(delta)
	
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta

	if player.is_on_floor():
		state_machine.change_state(state_machine.idle_state)
