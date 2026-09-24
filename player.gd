extends CharacterBody2D


@export var WALK_SPEED = 300.0
@export var DECELERATION := 2000

@export var SPRINT_SPEED = WALK_SPEED * 2
@export var JUMP_VELOCITY = -1000.0
@onready var state_machine: StateMachine = $StateMachine
@onready var label: Label = $Camera2D/Label

var SPEED = WALK_SPEED

func _physics_process(delta: float) -> void:
	label.text = "%s | SPEED: %s" % [state_machine.current_state.name, SPEED]
	move_and_slide()
