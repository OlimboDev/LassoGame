class_name WalkState
extends State

@export var idle_timer_wait: float = 0.1
var idle_timer: float = 0.0



func enter() -> void:
	idle_timer = 0.0
	if sprite:
		sprite.play("walk")

func physics_update(delta: float) -> void:
	super.physics_update(delta)
	if player.is_on_floor() and Input.is_action_just_pressed("jump"):
		state_machine.change_state(state_machine.jump_state)
		return
		
	if direction != 0:
		idle_timer = 0.0
		if Input.is_action_pressed("sprint"):
			state_machine.change_state(state_machine.sprint_state)
			return
	else:
		idle_timer += delta
		player.velocity.x = 0
		if idle_timer >= idle_timer_wait:
			state_machine.change_state(state_machine.idle_state)
			return
