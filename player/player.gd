extends CharacterBody2D


@export var WALK_SPEED: float = 300.0
@export var DECELERATION: float = 2000.0

@export var COYOTE_TIME: float = 0.2
@export var SPRINT_SPEED: float = WALK_SPEED * 2

@export_multiline var TUTORIAL_TEXT: String

@onready var state_machine: StateMachine = $StateMachine
@onready var label: Label = $Label

@onready var coyote_timer: Timer = $coyote_timer
var SPEED: float = WALK_SPEED

func _physics_process(_delta: float) -> void:
	if TUTORIAL_TEXT != "" && not SaveManager.is_current_level_completed():
		label.text = TUTORIAL_TEXT
	if SaveManager.lasso_on:
		velocity = Vector2.ZERO
	move_and_slide()
