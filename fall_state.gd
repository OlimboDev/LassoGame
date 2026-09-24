extends AirState

func enter() -> void:
	if sprite:
		sprite.play("fall")
