extends CharacterBody2D
class_name Player


@onready var _sprite: Sprite2D = $Sprite2D
@onready var _flashlight: PointLight2D = $Sprite2D/Flashlight
@onready var _flash_zone: Area2D = $"Sprite2D/Flashlight/Flash Zone"

@export var _walk_speed: float = 300.0
@export var _deceleration: float = 900.0


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
