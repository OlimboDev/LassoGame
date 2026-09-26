class_name GroundState
extends State

@onready var coyote_timer: Timer = $"../../coyote_timer"

@export var idle_timer_wait: float = 0.1
var idle_timer: float = 0.0

func _ready() -> void:
	pass

func physics_update(delta: float) -> void:
	move_horizontal(delta)
	
	if not player.is_on_floor():
		state_machine.change_state(state_machine.fall_state)
		return
		
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state(state_machine.jump_state)
		return

func idle_check(delta: float):
	if direction == 0:
		idle_timer += delta
		if idle_timer >= idle_timer_wait:
			state_machine.change_state(state_machine.idle_state)
			idle_timer = 0
			return
	else:
		idle_timer = 0
