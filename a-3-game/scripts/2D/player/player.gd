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
	
	# Check whether flashlight color matches object. send signal if so
	if _shapecast.is_colliding():
		var collision_count = _shapecast.get_collision_count()
		var current_collisions: Array[Object] = []
		
		for i in range(collision_count):
			var collided = _shapecast.get_collider(i)
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
