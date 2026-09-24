class_name State
extends Node2D

var player: CharacterBody2D
var state_machine: StateMachine
var sprite: AnimatedSprite2D
var direction : float
var speed_multiplier: float = 1.0

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	direction = Input.get_axis("moveLeft", "moveRight")
	
	if Input.is_action_pressed("sprint"):
		speed_multiplier = 2
	else:
		speed_multiplier = 1
	
	if direction != 0:
		player.velocity.x = direction * player.SPEED * speed_multiplier
		sprite.flip_h = direction < 0
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)

func handle_input(_event: InputEvent) -> void:
	pass
