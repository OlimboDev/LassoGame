class_name AirState
extends State


func physics_update(delta: float) -> void:
	super.physics_update(delta)
	
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta

	if player.is_on_floor():
		state_machine.change_state(state_machine.idle_state)
