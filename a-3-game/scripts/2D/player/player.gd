extends CharacterBody2D
class_name Player


@onready var _shapecast_body: ShapeCast2D = $Sprite2D/Flashlight/ShapeCastBodies
@onready var _shapecast_area: ShapeCast2D = $Sprite2D/Flashlight/ShapeCastAreas

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _flashlight: PointLight2D = $Sprite2D/Flashlight

@export var _walk_speed: float = 300.0
@export var _deceleration: float = 900.0

var _collided_objects: Array[Object] = [] # Holds all the objects seen by the flashlight
var _collided_areas: Array[Area2D] = []


var flash_color: Global.LIGHT_COLOR = 0 as Global.LIGHT_COLOR: # White
	set(value):
		var new_value: int = int(value)
		# Skip locked colors
		while new_value != int(Global.LIGHT_COLOR.WHITE) and not unlocked_colors.get(new_value, true):
			new_value += 1
			new_value %= Global.LIGHT_COLOR.size()
		
		flash_color = new_value as Global.LIGHT_COLOR
		_flashlight.color = Global.change_flash_color(flash_color)


var unlocked_colors: Dictionary = {
	Global.LIGHT_COLOR.RED: true,
	Global.LIGHT_COLOR.GREEN: true,
	Global.LIGHT_COLOR.BLUE: true,
	# Declarations below are necessary here in order to make the script properly skip colours. They are not intended to ever be changed.
	Global.LIGHT_COLOR.YELLOW: false,
	Global.LIGHT_COLOR.PURPLE: false,
	Global.LIGHT_COLOR.CYAN: false
}


func _physics_process(delta: float) -> void:
	# Get the input direction and apply it to the character
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var movement_dir := input_dir.normalized()
	
	if movement_dir:
		velocity = movement_dir * _walk_speed
		_sprite.rotation = lerp_angle(_sprite.rotation, movement_dir.angle() - PI / 2, delta * 10)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, _deceleration * delta)
	
	move_and_slide()
	
	# Check whether flashlight color matches object. Send signal if so
	if _shapecast_body.is_colliding():
		var collision_count = _shapecast_body.get_collision_count()
		var current_collisions: Array[Object] = []
		
		for i in range(collision_count):
			var collided = _shapecast_body.get_collider(i)
			if collided == null:
				continue
			
			var color_match := false
			if collided.is_in_group("Red") and flash_color == 1:
				color_match = true
			if collided.is_in_group("Green") and flash_color == 2:
				color_match = true
			if collided.is_in_group("Blue") and flash_color == 3:
				color_match = true
			
			if color_match:
				collided.player_lit = true
				current_collisions.append(collided)
		
		for i in _collided_objects:
			if not current_collisions.has(i):
				i.change_lit_status(false)
		
		_collided_objects = current_collisions.duplicate()
		
# Check whether flashlight is colliding with another light. Send signal if so.
# This can be integrated into the above script quite easily, combining both shapecasts into one object as well. Separating them was just much easier for figuring out a good method.
	if _shapecast_area.is_colliding():
		var collision_count = _shapecast_area.get_collision_count()
		var current_collisions: Array[Area2D] = []
		
		for i in range(collision_count):
			var collided = _shapecast_area.get_collider(i)
			if collided == null:
				continue
			
			if collided.is_in_group("ColorLight"):
				collided.get_parent()._flash_color = flash_color
				current_collisions.append(collided)
				
		# This seems to be extremely slow. It needs to resolve on the next frame for the lights to feel natural. Since this isn't my method I'm not gonna mess with it too much.
		for i in _collided_areas:
			if not current_collisions.has(i):
				i.get_parent()._flash_color = 0
		
		# I just copied and adapted this from the above. No idea what it does
		_collided_areas = current_collisions.duplicate()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("show_flashlight"):
		if _flashlight.enabled == true:
			_flashlight.enabled = false
			_shapecast_body.enabled = false
		else:
			_flashlight.enabled = true
			_shapecast_body.enabled = true
	
	elif event.is_action_pressed("change_flash_color"):
		flash_color = ((int(flash_color) + 1) % Global.LIGHT_COLOR.size()) as Global.LIGHT_COLOR
