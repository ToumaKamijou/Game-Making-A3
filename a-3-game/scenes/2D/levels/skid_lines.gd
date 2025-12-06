@tool
extends Sprite2D

@export var parent: Node2D
@export var rotate_90_degrees := false

func _ready() -> void:
	global_position = parent.global_position
	if rotate_90_degrees:
		rotation = deg_to_rad(90)
		if not parent.is_in_group("Mirror"):
			global_position -= Vector2(0, 15)
