extends State


@onready var walk_state: State = $"../walk_state"

func enter() -> void:
	player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
	if sprite:
		sprite.play("idle")

func physics_update(_delta: float) -> void:
	super.physics_update(_delta)
	if Input.get_axis("moveLeft", "moveRight") != 0:
		state_machine.change_state(walk_state)
