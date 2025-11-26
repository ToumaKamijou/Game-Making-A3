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
var _collided_zones: Array[Area2D] = []

@onready var _checkpoint_manager: Node2D = get_parent().get_node("CheckpointManager")
@onready var _player: CharacterBody2D = self
@onready var _area_check: ShapeCast2D = $AreaCheck
var safe := false

var score: int = 0
@onready var _score_text: RichTextLabel = $"../../../Display/ScoreContainer/Score"


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


func respawn():
	_player.position = _checkpoint_manager.last_location


func _physics_process(delta: float) -> void:
	# Get the input direction and apply it to the character
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var movement_dir := input_dir.normalized()
	
	if movement_dir:
		velocity = movement_dir * _walk_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, _deceleration * delta)
	
	# Rotate sprite.
	_sprite.rotation = lerp_angle(_sprite.rotation, get_global_mouse_position().angle_to_point(position) + PI / 2, delta * 10)
	
	move_and_slide()
	
	# Check whether flashlight color matches objects within it. Communicate necessary information if so.
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
				
			if collided.is_in_group("Prisma"):
				color_match = true
			
			if color_match:
				if collided.is_in_group("Prisma") and not collided.is_in_group("Mirror"):
					if not collided.is_in_group("Yellow") and not collided.is_in_group("Purple") and not collided.is_in_group("Cyan") or flash_color == 0:
						collided.set_incoming_light_color(flash_color)
					else:
						continue
				
				collided.player_lit = true
				current_collisions.append(collided)
		
		for i in _collided_objects:
			# Disable object if it is no longer being detected by the flashlight.
			if not current_collisions.has(i):
				if i.has_method("change_lit_status"):
					i.player_lit = false
	
		_collided_objects = current_collisions.duplicate()
	
# Check whether flashlight is colliding with another light. Change its color if so.
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
		# Still no idea why this happens btw
		for i in _collided_areas:
			if not current_collisions.has(i):
				i.get_parent()._flash_color = 0
		
		_collided_areas = current_collisions.duplicate()
		
	# Sort out moving platforms and deathzones. Shapecast is necessary so that invulnerability can be properly checked.
	if _area_check.is_colliding():
		var collision_count = _area_check.get_collision_count()

		var current_collisions: Array[Area2D] = []
		for i in collision_count:
			var collided = _area_check.get_collider(i)
			if collided.is_in_group("Mover"):
				if not collided.is_in_group("Hazard"):
					safe = true
				global_position.y += collided.get_owner().center.global_position.y - collided.get_owner().old.y
			if collided.is_in_group("Hazard") and safe == false:
				respawn()
				
			current_collisions.append(collided)
				
		for i in _collided_zones:
			if not current_collisions.has(i):
				if i.is_in_group("Mover"):
					safe = false
	
		_collided_zones = current_collisions.duplicate()


func _input(event: InputEvent) -> void:
	# Currently broken. Disabling them means that it can no longer communicate the player_lit value, which is also necessary to turn thing back on.
	# Probably just solved by setting player_lit = false on all objects when hiding it.
	if event.is_action_pressed("show_flashlight"):
		if _flashlight.enabled == true:
			_flashlight.enabled = false
			_shapecast_body.enabled = false
			_shapecast_area.enabled = false
		else:
			_flashlight.enabled = true
			_shapecast_body.enabled = true
			_shapecast_area.enabled = true
	
	# Why is this an elif?
	elif event.is_action_pressed("change_flash_color"):
		flash_color = ((int(flash_color) + 1) % Global.LIGHT_COLOR.size()) as Global.LIGHT_COLOR

# Tracks collectibles. That this is a score on a text label right now is purely placeholder; easily adaptable to track by different methods such as lighting up an object or some such.
func add_score(score_amount):
	score += score_amount
	_score_text.text = str("SCORE: ", score)
