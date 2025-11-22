extends Path2D
class_name MovingPlatform

@export var path_follow_2D : PathFollow2D
@onready var center: AnimatableBody2D = $AnimatableBody2D
var old: Vector2 = Vector2(0,0)

func _ready() -> void:
	move_tween()

func move_tween():
	var tween = get_tree().create_tween().set_loops()
	tween.tween_property(path_follow_2D, "progress_ratio", 1.0, 10.0)
	tween.tween_property(path_follow_2D, "progress_ratio", 0.0, 10.0)


func _physics_process(delta: float) -> void:
	old = center.global_position
