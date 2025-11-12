extends StaticBody2D

var lit = false

func _physics_process(delta: float) -> void:
	if lit == true:
		visible = false
		set_collision_layer_value(1, false)
	else:
		set_collision_layer_value(1, true)
		visible = true
	lit = false
