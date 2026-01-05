extends Path2D
class_name MovingPlatform

@export var path_follow_2D : PathFollow2D
@export var distance_to_end: Vector2
@export var duration: int
@onready var center: AnimatableBody2D = $AnimatableBody2D
var old: Vector2 = Vector2(0,0)
var older: Vector2

func _ready() -> void:
	curve.add_point(distance_to_end/2)
	move_tween()

func move_tween():
	var tween = get_tree().create_tween().set_loops()
	tween.tween_property(path_follow_2D, "progress_ratio", 1.0, duration)
	tween.tween_property(path_follow_2D, "progress_ratio", 0.0, duration)


func _physics_process(_delta: float) -> void:
	# Store previous frame's position to be able to access relative distance in the player script.
	# This used to work with only one variable but for some reason the order they update in was changed. The second variable is just artificially delaying things by one frame.
	older = old
	old = center.global_position
