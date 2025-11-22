extends Sprite2D


@export var _main_viewport : SubViewport


func _ready():
	var viewport_texture = _main_viewport.get_texture()
	texture = viewport_texture
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
