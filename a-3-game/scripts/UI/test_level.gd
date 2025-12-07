extends Node2D


@onready var tile_map_layers: Node2D = $TileMapLayers
@onready var tile_map_control: Node2D = $SubViewportContainer/SubViewport/TileMapControl


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	tile_map_layers.reparent(tile_map_control)
