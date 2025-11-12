extends CharacterBody2D
class_name Player


@onready var _sprite: Sprite2D = $Sprite2D
@onready var _flashlight: PointLight2D = $Sprite2D/Flashlight
@onready var _flash_zone: Area2D = $"Sprite2D/Flashlight/Flash Zone"

@export var _walk_speed: float = 300.0
@export var _deceleration: float = 900.0

var flash_color: Global.LIGHT_COLOR = 0 as Global.LIGHT_COLOR: # White
	set(value):
		var new_value: int = int(value)
		# Skip locked colors
		while new_value != int(Global.LIGHT_COLOR.WHITE) and not unlocked_colors.get(new_value, true):
			new_value += 1
			new_value %= Global.LIGHT_COLOR.size()
		
		flash_color = new_value as Global.LIGHT_COLOR
		_change_flash_color()

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
		_sprite.rotation = movement_dir.angle() - PI / 2
	else:
		velocity = velocity.move_toward(Vector2.ZERO, _deceleration * delta)

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("show_flashlight"):
		if _flashlight.enabled == true:
			_flashlight.enabled = false
			_flash_zone.monitoring = false
		else:
			_flashlight.enabled = true
			_flash_zone.monitoring = true
	
	elif event.is_action_pressed("change_flash_color"):
		flash_color = ((int(flash_color) + 1) % Global.LIGHT_COLOR.size()) as Global.LIGHT_COLOR


func _change_flash_color() -> void:
	match flash_color:
		Global.LIGHT_COLOR.WHITE:
			_flashlight.color = Color.WHITE
		Global.LIGHT_COLOR.RED:
			_flashlight.color = Color.RED
		Global.LIGHT_COLOR.GREEN:
			_flashlight.color = Color.LIME_GREEN
		Global.LIGHT_COLOR.BLUE:
			_flashlight.color = Color.ROYAL_BLUE
