extends CharacterBody2D
class_name Player

# Variables for collectible tracking
@onready var _score_text: Label = $ScoreText
var score: int

@onready var _shapecast: ShapeCast2D = $Sprite2D/Flashlight/ShapeCast2D

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _flashlight: PointLight2D = $Sprite2D/Flashlight

@export var _walk_speed: float = 300.0
@export var _deceleration: float = 900.0

var _collided_objects: Array[Object] = [] # Holds all the objects seen by the flashlight


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
}


func _physics_process(delta: float) -> void:
	# Get the input direction and apply it to the character
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var movement_dir := input_dir.normalized()
	
	if movement_dir:
		velocity = movement_dir * _walk_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, _deceleration * delta)
	_sprite.rotation = lerp_angle(_sprite.rotation, get_global_mouse_position().angle_to_point(position) + PI / 2, delta * 10)
	
	move_and_slide()
	
	# Check whether flashlight color matches object. Send signal if so
	if _shapecast.is_colliding():
		var collision_count = _shapecast.get_collision_count()
		var current_collisions: Array[Object] = []
		
		for i in range(collision_count):
			var collided = _shapecast.get_collider(i)
			if collided == null:
				continue
				
			## --- NEW LOGIC FOR PRISMA GLASS ---
			## Check if the object is a prisma AND the flashlight is white
			#if collided.is_in_group("Prisma") and flash_color == 0:
				#print("test")
				#collided.change_lit_status(true)
				#current_collisions.append(collided)
				#continue # Skip to the next object, we're done with this one
						# --- REVISED PRISMA LOGIC ---
			if collided.is_in_group("Prisma"):
				var prisma_color_type = collided._color_type
				var activate = false
				
				# Condition 1: WHITE light hits a COLORED prisma
				if flash_color == Global.LIGHT_COLOR.WHITE and prisma_color_type != Global.LIGHT_COLOR.WHITE:
					activate = true
				
				# Condition 2: COLORED light hits a WHITE prisma
				elif flash_color != Global.LIGHT_COLOR.WHITE and prisma_color_type == Global.LIGHT_COLOR.WHITE:
					# Inform the prisma of our color BEFORE activating it
					collided.set_incoming_light_color(flash_color)
					activate = true

				if activate:
					collided.change_lit_status(true)
					current_collisions.append(collided)

				continue # We're done with this object, move to the next one
			
			var color_match := false
			if collided.is_in_group("Red") and collided.is_in_group("Wall") and flash_color == 1:
				color_match = true
			if collided.is_in_group("Green") and collided.is_in_group("Wall") and flash_color == 2:
				color_match = true
			if collided.is_in_group("Blue") and collided.is_in_group("Wall") and flash_color == 3:
				color_match = true
			
			if color_match:
				collided.change_lit_status(true)
				current_collisions.append(collided)
		
		for i in _collided_objects:
			if not current_collisions.has(i):
				i.change_lit_status(false)
		
		_collided_objects = current_collisions.duplicate()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("show_flashlight"):
		if _flashlight.enabled == true:
			_flashlight.enabled = false
			_shapecast.enabled = false
		else:
			_flashlight.enabled = true
			_shapecast.enabled = true
	
	elif event.is_action_pressed("change_flash_color"):
		flash_color = ((int(flash_color) + 1) % Global.LIGHT_COLOR.size()) as Global.LIGHT_COLOR


func add_score(score_amount):
	score += score_amount
	_score_text.text = str("SCORE: ", score)
