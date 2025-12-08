extends Sprite2D


@export var _bob_speed : float = 1.5
@export var _bob_height : float = 25.0

var t: float = 0.0
var _start_y : float


func _ready() -> void:
	_start_y = global_position.y


func _physics_process(delta: float) -> void:
	# Bob up and down.
	t += delta
	var d = sin((t * _bob_speed) + 1) / 2
	global_position.y = _start_y + (d * _bob_height)
