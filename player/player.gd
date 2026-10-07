extends CharacterBody2D


@export var WALK_SPEED: float = 300.0
@export var DECELERATION := 2000

@export var COYOTE_TIME: float = 0.2
@export var SPRINT_SPEED: float = WALK_SPEED * 2
@export var JUMP_VELOCITY: float = -1000.0
@onready var state_machine: StateMachine = $StateMachine
@onready var label: Label = $Label

@onready var coyote_timer: Timer = $coyote_timer
var SPEED: float = WALK_SPEED

func _physics_process(_delta: float) -> void:
	label.text = "%s | SPEED: %s" % [state_machine.current_state.name, SPEED]
	move_and_slide()
