extends CharacterBody2D
class_name Player

@onready var _object_check: ShapeCast2D = $Sprite2D/ObjectCheck
@onready var _shapecast_body: ShapeCast2D = $Sprite2D/Flashlight/ShapeCastBodies
@onready var _shapecast_area: ShapeCast2D = $Sprite2D/Flashlight/ShapeCastAreas

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _flashlight: PointLight2D = $Sprite2D/Flashlight

@export var _walk_speed: float = 300.0
@export var _deceleration: float = 900.0

var _collided_objects: Array[Object] = [] # Holds all the objects seen by the flashlight
var _collided_areas: Array[Area2D] = []
var _collided_zones: Array[Area2D] = []

@onready var _checkpoint_manager: Node2D = $"../CheckpointManager"
@onready var _area_check: ShapeCast2D = $AreaCheck
var safe := false

var score: int = 5
@onready var _score_text: RichTextLabel = $"../../Display/ScoreContainer/Score"

var checkpoint: Area2D
var light_control: Node2D

var old_modulate: Color

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
	# Declarations below are necessary here in order to make the script properly skip colors. They are not intended to ever be changed.
	Global.LIGHT_COLOR.YELLOW: false,
	Global.LIGHT_COLOR.PURPLE: false,
	Global.LIGHT_COLOR.CYAN: false
}


var held_object: RigidBody2D = null
var push_axis: Vector2 = Vector2.ZERO

func respawn():
	global_position = _checkpoint_manager.last_location.global_position if _checkpoint_manager.last_location else Vector2(0.0, 0.0)
	if held_object:
		held_object = null


func _physics_process(delta: float) -> void:
	# Attempt at forcing player to let go of object when it exits grab range. Doesn't work and not important enough for me to bother fixing it right now. Feel free to look into it.
	#if held_object and _object_check.is_colliding():
		#for i in range(_object_check.get_collision_count()):
			#if _object_check.get_collider(i).is_in_group("Pushable") and not held_object:
				#held_object.particles.emitting = false
				#held_object.linear_velocity = Vector2.ZERO
				#held_object = null
	 #Get the input direction and apply it to the character
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var movement_dir := input_dir.normalized()
	
	if held_object:
		# Constrain movement to the push axis
		var projected_movement = movement_dir.project(push_axis)
		if projected_movement:
			velocity = projected_movement * _walk_speed
			held_object.linear_velocity = velocity
		else:
			velocity = Vector2.ZERO
			held_object.linear_velocity = velocity
		
		# Handle rotation of held object
		if held_object.is_in_group("Rotatable"):
			if Input.is_action_just_pressed("rotate_left"):
				held_object.rotation += deg_to_rad(-45)
				held_object.change_lit_status(false)
			elif Input.is_action_just_pressed("rotate_right"):
				held_object.rotation += deg_to_rad(45)
				held_object.change_lit_status(false)
		
		# Patchwork solution to prevent stupidly complicated raycast problems with dynamic updating
		if held_object.has_method("change_lit_status"):
			held_object.lit = false
			held_object.light.enabled = false
			held_object.modulate = Color(0.176, 0.176, 0.176, 1.0)
	
	elif movement_dir and velocity != movement_dir * _walk_speed:
		velocity = velocity.move_toward(movement_dir * _walk_speed, delta * 2000)
	elif movement_dir:
		velocity = movement_dir * _walk_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, _deceleration * delta)
	
	# Rotate sprite.
	_sprite.rotation = lerp_angle(_sprite.rotation, get_global_mouse_position().angle_to_point(position) + PI / 2, delta * 10)
	
	move_and_slide()
	
	# Check whether flashlight color matches objects within it. Communicate necessary information if so.
	var  current_collisions_bodies: Array[Object]
	if _shapecast_body.is_colliding():
		var collision_count = _shapecast_body.get_collision_count()
		current_collisions_bodies = []
		
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
				
			if collided.is_in_group("Prisma"):
				color_match = true
			
			if color_match:
				if collided.is_in_group("Prisma") and not collided.is_in_group("Mirror"):
					if not collided.is_in_group("Yellow") and not collided.is_in_group("Purple") and not collided.is_in_group("Cyan") or flash_color == 0:
						collided.set_incoming_light_color(flash_color)
					else:
						continue
				
				collided.player_lit = true
				current_collisions_bodies.append(collided)
		
	for i in _collided_objects:
		# Disable object if it is no longer being detected by the flashlight.
		if not current_collisions_bodies.has(i):
			if i and i.has_method("change_lit_status"):
				i.player_lit = false
	
	_collided_objects = current_collisions_bodies.duplicate()
	
	# Check whether flashlight is colliding with another light. Change its color if so.
	# This can be integrated into the above script quite easily, combining both shapecasts into one object as well. Separating them was just much easier for figuring out a good method.
	var current_collisions_areas: Array[Area2D]
	if _shapecast_area.is_colliding():
		var collision_count = _shapecast_area.get_collision_count()
		current_collisions_areas = []
		
		for i in range(collision_count):
			var collided = _shapecast_area.get_collider(i)
			if collided == null:
				continue
			
			if collided.is_in_group("ColorLight") and collided.get_owner()._light.override == false:
				collided.get_owner()._light._flash_color = flash_color
				current_collisions_areas.append(collided)
				
		
	_collided_areas = current_collisions_areas.duplicate()
		
	# Sort out moving platforms and deathzones. Shapecast is necessary so that invulnerability can be properly checked.
	var current_collisions_zones: Array[Area2D]
	if _area_check.is_colliding():
		var collision_count = _area_check.get_collision_count()

		current_collisions_zones = []
		for i in collision_count:
			var collided = _area_check.get_collider(i)
			if collided and collided.is_in_group("Mover"):
				if not collided.is_in_group("Hazard"):
					safe = true
				global_position += collided.get_owner().center.global_position - collided.get_owner().older
			elif collided.is_in_group("Hazard") and safe == false:
				respawn()
			elif collided.is_in_group("Button"):
				light_control = collided.get_owner()
				light_control._button_light.enabled = true
				
			current_collisions_zones.append(collided)
				
	for i in _collided_zones:
		if not current_collisions_zones.has(i):
			if i.is_in_group("Mover"):
				safe = false
			if light_control and i.is_in_group("Button"):
				light_control._button_light.enabled = false
				light_control = null
	
	_collided_zones = current_collisions_zones.duplicate()


func _input(event: InputEvent) -> void:	
	if event.is_action_pressed("change_flash_color"):
		flash_color = ((int(flash_color) + 1) % Global.LIGHT_COLOR.size()) as Global.LIGHT_COLOR
	
	if event.is_action_pressed("interact"): # Using F key as interact
		# Rotate static lights via button
		if light_control:
			light_control._light.rotate(deg_to_rad(light_control._rotation_value))
		
		# Release held object if it exists
		if held_object:
			#held_object.particles.emitting = false
			held_object.linear_velocity = Vector2.ZERO
			held_object.modulate = old_modulate
			held_object = null
		else:
			# Grab closest object
			if _object_check.is_colliding():
				var count = _object_check.get_collision_count()
				var closest_obj: RigidBody2D = null
				var closest_dist: float = INF
				
				for i in range(count):
					var collider = _object_check.get_collider(i)
					if collider is RigidBody2D and collider.is_in_group("Pushable"):
						var dist = global_position.distance_to(collider.global_position)
						if dist < closest_dist:
							closest_dist = dist
							closest_obj = collider
				
				if closest_obj:
					held_object = closest_obj
					old_modulate = held_object.modulate
					#held_object.particles.emitting = true
					# Determine movement axis
					if held_object.movement_axis == 1:
						push_axis = Vector2(0, 1)
					else:
						push_axis = Vector2(1, 0)


# Tracks collectibles. That this is a score on a text label right now is purely placeholder; easily adaptable to track by different methods such as lighting up an object or some such.
func add_score(score_amount):
	score -= score_amount
	if score == 0 or score < 0:
		_score_text.text = "THE DOOR IS OPEN"
	else:
		_score_text.text = str(str(score) + " REMAINING")
