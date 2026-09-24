class_name State
extends Node2D

var player: CharacterBody2D
var state_machine: StateMachine
var sprite: AnimatedSprite2D
var direction : float


func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	direction = Input.get_axis("moveLeft", "moveRight")

func handle_input(_event: InputEvent) -> void:
	pass
	
func move_horizontal(delta: float) -> void:
	direction = Input.get_axis("moveLeft", "moveRight")
	if direction != 0:
		player.velocity.x = direction * player.SPEED
		sprite.flip_h = direction < 0
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.DECELERATION * delta)
