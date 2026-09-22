class_name State
extends Node2D

var player: CharacterBody2D
var state_machine: StateMachine
var sprite: AnimatedSprite2D
var direction : float
var speed_multiplier: float = 1.0

@onready var jump_state: State = $"../jump_state"
func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	if direction != 0:
		player.velocity.x = direction * player.SPEED * speed_multiplier
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state(jump_state)
	direction = Input.get_axis("moveLeft", "moveRight")
	if direction != 0:
		sprite.flip_h = direction < 0

func handle_input(_event: InputEvent) -> void:
	pass
