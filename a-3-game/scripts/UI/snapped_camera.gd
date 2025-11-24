class_name Camera2DTexelSnapped
extends Camera2D


@export var _snap := true

var texel_error := Vector2.ZERO

@onready var _prev_rotation := global_rotation
@onready var _snap_space := global_transform
var _texel_size: float = 0.0


func _process(_delta: float) -> void:
	# rotation changes the snap space
	if global_rotation != _prev_rotation:
		_prev_rotation = global_rotation
		_snap_space = global_transform
	_texel_size = scale.x / float((get_viewport() as SubViewport).size.y)
	# camera position in snap space
	var snap_space_position := global_position * _snap_space
	# snap!
	var snapped_snap_space_position := snap_space_position.snapped(Vector2.ONE * _texel_size)
	# how much we snapped (in snap space)
	var snap_error := snapped_snap_space_position - snap_space_position
	if _snap:
		# apply camera offset as to not affect the actual transform
		offset.x = snap_error.x
		offset.y = snap_error.y
		# error in screen texels (will be used later)
		texel_error = Vector2(snap_error.x, -snap_error.y) / _texel_size
	else:
		texel_error = Vector2.ZERO
