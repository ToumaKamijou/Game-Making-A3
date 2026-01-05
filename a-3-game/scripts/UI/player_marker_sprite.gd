extends Sprite2D


@onready var player: Player = $"../../GameWorld/Player"


func _process(_delta: float) -> void:
	rotation = player.get_child(0).rotation
