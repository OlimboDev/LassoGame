extends StaticBody2D

@export var size: Vector2 = Vector2(96, 32):
	set(value):
		size = value
		if is_node_ready():
			_apply_size()

@onready var shape_node: CollisionShape2D = $CollisionShape2D
@onready var nine_patch: NinePatchRect = $NinePatchRect


func _ready() -> void:
	_apply_size()


func _apply_size() -> void:
	var shape := RectangleShape2D.new()
	shape.size = size
	shape_node.shape = shape
	shape_node.position = Vector2.ZERO
	shape_node.scale = Vector2.ONE
	nine_patch.size = size / nine_patch.scale
	nine_patch.position = -size / 2.0
