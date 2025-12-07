extends Node2D


@onready var sub_viewport_control: Node2D = $SubViewportControl
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport



func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	sub_viewport_control.reparent(sub_viewport)
