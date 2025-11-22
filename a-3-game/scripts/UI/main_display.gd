extends Control


@export var _viewport : SubViewport
@export var _pixel_movement : bool = true
@export var _sub_pixel_movement_at_integer_scale : bool = true

@onready var _sprite : Sprite2D = $"Subpixel Snapper"


func _process(_delta: float) -> void:
	var screen_size := Vector2(get_window().size)
	# viewport size minus padding
	var game_size := Vector2(_viewport.size - Vector2i(2, 2))
	var display_scale := screen_size / game_size
	# control node scaling
	var subviewport_container : SubViewportContainer = _viewport.get_parent()
	var stretch_shrink_size := subviewport_container.stretch_shrink
	scale = Vector2(stretch_shrink_size, stretch_shrink_size)
	# smooth!
	if _pixel_movement:
		var cam := _viewport.get_camera_2d() as Camera2DTexelSnapped
		var pixel_error : Vector2 = cam.texel_error * _sprite.scale
		_sprite.position = -_sprite.scale + pixel_error
		var is_integer_scale := display_scale == display_scale.floor()
		if is_integer_scale and not _sub_pixel_movement_at_integer_scale:
			_sprite.position = _sprite.position.round()
