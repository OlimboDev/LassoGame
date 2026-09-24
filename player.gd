extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

@onready var state_machine: StateMachine = $StateMachine
@onready var label: Label = $Camera2D/Label

func _physics_process(delta: float) -> void:
	label.text = state_machine.current_state.name
	move_and_slide()
