@tool
extends PointLight2D

var _flash_color: int = 0

@onready var _shapecast_body: ShapeCast2D = $ShapeCastBodies
@onready var _shapecast_area: ShapeCast2D = $ShapeCastAreas

# This here is a very blunt, probably temporary solution to a problem I couldn't manage to solve. For some reason the code breaks whenever I try to call the other input's value
@export_range(0, 6, 1) var _base_value: int

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
var _collided_areas: Array[Area2D] = []

var overriden = false


func _physics_process(_delta: float) -> void:
	# Check whether light color matches object. Communicate necessary information if so.
	if _shapecast_body.is_colliding():
		var collision_count = _shapecast_body.get_collision_count()
		var current_collisions: Array[Object] = []
		
		for i in range(collision_count):
			var collided = _shapecast_body.get_collider(i)
			if collided == null:
				continue
			
			if collided.has_method("change_lit_status"):
				collided.override = true
			
			# Differs from player script in that this checks all six colors as opposed to three.
			var color_match := false
			if collided.is_in_group("Flashable"):
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
			
			if collided.is_in_group("Prisma"):
				if collided.is_in_group("Yellow") or collided.is_in_group("Purple") or collided.is_in_group("Cyan") and _light_color != 0:
					continue
				else:
					color_match = true
					collided.set_incoming_light_color(_light_color)
			
			if color_match:
				collided.matched = true
				current_collisions.append(collided)
		
		for i in _collided_objects:
			if not current_collisions.has(i):
				i.override = false
				i.matched = false
		
		_collided_objects = current_collisions.duplicate()
	
	# Check whether static light is colliding with another light. Change its color and except self if so.
	# This can be integrated into the above script quite easily, combining both shapecasts into one object as well. Separating them was just much easier for figuring out a good method.
	if _shapecast_area.is_colliding():
		var collision_count = _shapecast_area.get_collision_count()
		var current_collisions: Array[Area2D] = []
		
		for i in range(collision_count):
			var collided = _shapecast_area.get_collider(i)
			if collided == null:
				continue
			
			if collided.is_in_group("ColorLight") and overriden == false:
				overriden = true
				collided.get_parent()._flash_color = _light_color
				current_collisions.append(collided)
				
		# This seems to be extremely slow. It needs to resolve on the next frame for the lights to feel natural. Since this isn't my method I'm not gonna mess with it too much.
		# Still no idea why this happens btw
		for i in _collided_areas:
			if not current_collisions.has(i):
				i.get_parent()._flash_color = 0
				if i.is_in_group("ColorLight"):
					overriden = false
		
		_collided_areas = current_collisions.duplicate()
		
	# Calculate color mixing. Not yet adapted to allow two static lights to mix.
	# There's probably a math solution for this, as well as a more elegant loop. This works too.
	if _flash_color != 0:
		if _base_value == 0 or 4 or 5 or 6:
			if _flash_color == 1:
				var tween = create_tween()
				tween.tween_property(self, "color", Color.RED, .5)
				_light_color = Global.LIGHT_COLOR.RED
			if _flash_color == 2:
				var tween = create_tween()
				tween.tween_property(self, "color", Color.LIME_GREEN, .5)
				_light_color = Global.LIGHT_COLOR.GREEN
			if _flash_color == 3:
				var tween = create_tween()
				tween.tween_property(self, "color", Color.ROYAL_BLUE, .5)
				_light_color = Global.LIGHT_COLOR.BLUE
		if _base_value == 1:
			if _flash_color == 1:
				var tween = create_tween()
				tween.tween_property(self, "color", Color.RED, .5)
				_light_color = Global.LIGHT_COLOR.RED
			if _flash_color == 2:
				var tween = create_tween()
				tween.tween_property(self, "color", Color.YELLOW, .5)
				_light_color = Global.LIGHT_COLOR.YELLOW
			if _flash_color == 3:
				var tween = create_tween()
				tween.tween_property(self, "color", Color.PURPLE, .5)
				_light_color = Global.LIGHT_COLOR.PURPLE
		elif _base_value == 2:
			if _flash_color == 1:
				var tween = create_tween()
				tween.tween_property(self, "color", Color.YELLOW, .5)
				_light_color = Global.LIGHT_COLOR.YELLOW
			if _flash_color == 2:
				var tween = create_tween()
				tween.tween_property(self, "color", Color.LIME_GREEN, .5)
				_light_color = Global.LIGHT_COLOR.GREEN
			if _flash_color == 3:
				var tween = create_tween()
				tween.tween_property(self, "color", Color.CYAN, .5)
				_light_color = Global.LIGHT_COLOR.CYAN
		elif _base_value == 3:
			if _flash_color == 1:
				var tween = create_tween()
				tween.tween_property(self, "color", Color.PURPLE, .5)
				_light_color = Global.LIGHT_COLOR.PURPLE
			if _flash_color == 2:
				var tween = create_tween()
				tween.tween_property(self, "color", Color.CYAN, .5)
				_light_color = Global.LIGHT_COLOR.CYAN
			if _flash_color == 3:
				var tween = create_tween()
				tween.tween_property(self, "color", Color.ROYAL_BLUE, .5)
				_light_color = Global.LIGHT_COLOR.BLUE
	else:
		# This tween needs to call the base value as a color. It seems silly to create an entirely new dictionary here just for that, so someone else can figure out a better method.
		#var tween = create_tween()
		#tween.tween_property(self, "color", _base_value as Global.LIGHT_COLOR, 1)
		@warning_ignore_start("int_as_enum_without_cast")
		_light_color = _base_value
		@warning_ignore_restore("int_as_enum_without_cast")
