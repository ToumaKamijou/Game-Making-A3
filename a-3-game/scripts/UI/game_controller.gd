extends Node2D


@onready var viewport_mover: Node2D = $ViewportMover
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	viewport_mover.reparent(sub_viewport)
