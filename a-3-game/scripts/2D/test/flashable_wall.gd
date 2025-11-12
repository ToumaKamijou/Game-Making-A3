extends StaticBody2D


var lit = false


func _physics_process(_delta: float) -> void:
	if lit == true:
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.1)
		set_collision_layer_value(1, false)
	else:
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.1)
		await get_tree().create_timer(0.15).timeout
		set_collision_layer_value(1, true)
	lit = false
