@tool
extends PointLight2D


@onready var _shapecast: ShapeCast2D = $ShapeCast2D

@export var _light_color: Global.LIGHT_COLOR = Global.LIGHT_COLOR.WHITE:
	set(value):
		_light_color = value
		if not Engine.is_editor_hint():
			color = Global.change_flash_color(_light_color)
			var previous_group := get_groups()
			for i in previous_group:
				remove_from_group(i)
			var new_group := Global.change_color_group(value)
			if new_group != "":
				add_to_group(new_group)

@export_range(1.0, 5.0, 0.1) var _size: float = 1.0:
	set(value):
		_size = value
		scale = Vector2(value, value)

var _collided_objects: Array[Object] = [] # Holds all the objects seen by the flashlight


func _physics_process(_delta: float) -> void:
	# Check whether flashlight color matches object. send signal if so
	if _shapecast.is_colliding():
		var collision_count = _shapecast.get_collision_count()
		var current_collisions: Array[Object] = []
		
		for i in range(collision_count):
			var collided = _shapecast.get_collider(i)
			if collided == null:
				continue
			
			var color_match := false
			if collided.is_in_group("Red") and _light_color == 1:
				color_match = true
			if collided.is_in_group("Green") and _light_color == 2:
				color_match = true
			if collided.is_in_group("Blue") and _light_color == 3:
				color_match = true
			
			if color_match:
				collided.change_lit_status(true)
				current_collisions.append(collided)
		
		for i in _collided_objects:
			if not current_collisions.has(i):
				i.change_lit_status(false)
		
		_collided_objects = current_collisions.duplicate()
