extends Area2D

# values adjustable in inspector per separate instance. change here to adjust defaults
@export var score_amount: int = 1
@export var bob_height: float = 15.0
@export var bob_speed: float = 2.0

@onready var audio = $AudioStreamPlayer2D

# fetch starting position and time for bob function
@onready var start_y: float = global_position.y
var t: float = 0.0

var collected = false

func _physics_process(delta: float) -> void:
	# bob up and down
	t += delta
	var d = sin((t * bob_speed) + 1) / 2
	global_position.y = start_y + (d * bob_height)
	
	# destroy self if collected
	if collected == true:
		scale -= Vector2(.1,.1) * 2
		if scale <= Vector2(.5,.5):
			audio.play()
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and collected == false:
		body.add_score(score_amount)
		print("collected")
		collected = true
