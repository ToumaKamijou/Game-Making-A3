extends Node

func _unhandled_key_input(event : InputEvent) -> void:
	var _event : InputEventKey = event
	if event.is_pressed():
		var key : int = _event.keycode
		match key:
			KEY_R:
				# Reset the level
				get_tree().reload_current_scene()
			KEY_Y:
				get_tree().quit()
			KEY_T:
				var is_fullscreen : bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
				var target_mode : int = DisplayServer.WINDOW_MODE_WINDOWED if is_fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN
				DisplayServer.window_set_mode(target_mode)
