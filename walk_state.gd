class_name WalkState
extends State


@onready var idle_state: State = $"../idle_state"
@onready var sprint_state: State = $"../sprint_state"

@export var idle_timer_wait: float = 0.1
var idle_timer: float = 0.0



func enter() -> void:
	speed_multiplier = 1.0
	idle_timer = 0.0
	if sprite:
		sprite.play("walk")

func physics_update(delta: float) -> void:
	super.physics_update(delta)
	if direction != 0:
		idle_timer = 0.0
		player.velocity.x = direction * player.SPEED * speed_multiplier
		if Input.is_action_pressed("sprint"):
			state_machine.change_state(sprint_state)
	else:
		idle_timer += delta
		player.velocity.x = 0
		if idle_timer >= idle_timer_wait:
			state_machine.change_state(idle_state)
