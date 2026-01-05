extends SubViewport


@onready var player: Player = $"../../../GameWorld/Player"

@onready var camera_2d: Camera2D = $Camera2D


func _ready() -> void:
	world_2d = get_tree().root.world_2d

func _process(_delta: float) -> void:
	camera_2d.position = player.position
