extends Area2D


# Values adjustable in inspector per separate instance. Change here to adjust defaults.
@export var _score_amount: int = 1
@export var _bob_height: float = 15.0
@export var _bob_speed: float = 2.0

@onready var _audio := $AudioStreamPlayer

# Fetch starting position and time for bob function.
@onready var _start_y: float = global_position.y
var t: float = 0.0

var _collected = false


func _physics_process(delta: float) -> void:
	# Bob up and down.
	t += delta
	var d = sin((t * _bob_speed) + 1) / 2
	global_position.y = _start_y + (d * _bob_height)


func _on_body_entered(body: Node2D) -> void:
	# Add score (or track in other ways).
	if body.is_in_group("Player") and _collected == false:
		body.add_score(_score_amount)
		_collect_coin()


func _collect_coin() -> void:
	# Play sound and then destroy self if collected.
	if _collected == false:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(0.0, 0.5), 0.3)
		
		_audio.play()
		_collected = true
		
		# queue_free() crashes due to the player areacheck shapecast. score amount change here is a safeguard, should not affect anything.
		await tween.finished
		visible = false
		_score_amount = 0
