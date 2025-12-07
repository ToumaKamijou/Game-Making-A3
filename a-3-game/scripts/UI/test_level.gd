extends Node2D


@onready var tile_map_layers: Node2D = $TileMapLayers
@onready var tile_map_control: Node2D = $SubViewportContainer/SubViewport/TileMapControl


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	#move_child(tile_map_layers, sub_viewport_container.get_index())
	#sub_viewport_container.move_child(get_child(sub_viewport_container.get_children().size()), 0)
	tile_map_layers.reparent(tile_map_control)
