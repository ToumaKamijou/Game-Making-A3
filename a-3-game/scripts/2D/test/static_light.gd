@tool
extends PointLight2D


var _flash_color: int = 0

@onready var _shapecast: ShapeCast2D = $ShapeCast2D

# This here is a very blunt, probably temporary solution to a problem I couldn't manage to solve. For some reason the code breaks whenever I try to call the other input's value
@export_range(1, 6, 1) var _base_value: int

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

var _collided_objects: Array[Object] = [] # Holds all the objects seen by the light


func _physics_process(_delta: float) -> void:
	# Check whether light color matches object. send signal if so
	if _shapecast.is_colliding():
		var collision_count = _shapecast.get_collision_count()
		var current_collisions: Array[Object] = []
		
		for i in range(collision_count):
			var collided = _shapecast.get_collider(i)
			if collided == null:
				continue
			
			collided.override = true
			
			var color_match := false
			if collided.is_in_group("Red") and _light_color == 1:
				color_match = true
			if collided.is_in_group("Green") and _light_color == 2:
				color_match = true
			if collided.is_in_group("Blue") and _light_color == 3:
				color_match = true
			if collided.is_in_group("Yellow") and _light_color == 4:
				color_match = true
			if collided.is_in_group("Purple") and _light_color == 5:
				color_match = true
			if collided.is_in_group("Cyan") and _light_color == 6:
				color_match = true
			
			
			if color_match:
				collided.change_lit_status(true)
				current_collisions.append(collided)
		
		for i in _collided_objects:
			if not current_collisions.has(i):
				i.change_lit_status(false)
		
		_collided_objects = current_collisions.duplicate()
		
	# There's probably a math solution for this, as well as a more elegant loop. This works too.
	if _flash_color != 0:
		var tween = create_tween()
		if _base_value == 1:
			if _flash_color == 1:
				tween.tween_property(self, "color", Color.RED, .5)
				_light_color = Global.LIGHT_COLOR.RED
			if _flash_color == 2:
				tween.tween_property(self, "color", Color.YELLOW, .5)
				_light_color = Global.LIGHT_COLOR.YELLOW
			if _flash_color == 3:
				tween.tween_property(self, "color", Color.PURPLE, .5)
				_light_color = Global.LIGHT_COLOR.PURPLE
		elif _base_value == 2:
			if _flash_color == 1:
				tween.tween_property(self, "color", Color.YELLOW, .5)
				_light_color = Global.LIGHT_COLOR.YELLOW
			if _flash_color == 2:
				tween.tween_property(self, "color", Color.LIME_GREEN, .5)
				_light_color = Global.LIGHT_COLOR.GREEN
			if _flash_color == 3:
				tween.tween_property(self, "color", Color.CYAN, .5)
				_light_color = Global.LIGHT_COLOR.CYAN
		elif _base_value == 3:
			if _flash_color == 1:
				tween.tween_property(self, "color", Color.PURPLE, .5)
				_light_color = Global.LIGHT_COLOR.PURPLE
			if _flash_color == 2:
				tween.tween_property(self, "color", Color.CYAN, .5)
				_light_color = Global.LIGHT_COLOR.CYAN
			if _flash_color == 3:
				tween.tween_property(self, "color", Color.ROYAL_BLUE, .5)
				_light_color = Global.LIGHT_COLOR.BLUE
	else:
		# This tween obviously does not work right now. I could do it with a bunch of if statements but thought we should probably just find a way to find a dynamic variable first.
		# Basically, we need to call the value within the global script that is equivalent to whatever the _base_value represents.
		#var tween = create_tween()
		#tween.tween_property(self, "color", _base_value, 1)
		
		# For some reason, this works while deriving the value from within the other variable does not. Actually, why does this even change the colour of the light?
		# Shouldn't that only be happening when setting the variable initially? Is it that it executes that function every time the value changes?
		# If that is what's happening then we probably do actually need the secondary value?
		@warning_ignore_start("int_as_enum_without_cast")
		_light_color = _base_value
		@warning_ignore_restore("int_as_enum_without_cast")
