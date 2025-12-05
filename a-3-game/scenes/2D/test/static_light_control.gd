@tool
extends Node2D

@onready var _light = $StaticLight
@onready var _button = $Button

@warning_ignore_start("unused_private_class_variable")
@onready var _button_light = $Button/PointLight2D

# This here is a very blunt, probably temporary solution to a problem I couldn't manage to solve. For some reason the code breaks whenever I try to call the other input's value
@export_range(0, 6, 1) var _base_value: int

@export_range(1.0, 10.0, 0.1) var _size: float = 5.0

@export_range(0, 360, 45) var _rotation_value: int = 90

# They don't let me put a Vector2 in a range... It can't snap values otherwise, which makes it tortuous to drag.
@export_range(-300, 300, 0.5, "or_less", "or_greater") var _button_position_x: float
@export_range(-300, 300, 0.5, "or_less", "or_greater") var _button_position_y: float

@export_range(0, 360, 45) var _button_rotation: int
@warning_ignore_restore("unused_private_class_variable")

func _ready() -> void:
	_light._base_value = _base_value

# These go here so that the tool script actually works. No reason not to put them in the ready function on final export, though I doubt performance will really matter anyway.
func _physics_process(_delta: float) -> void:
	_button.position = Vector2(_button_position_x, _button_position_y)
	_button.rotation = deg_to_rad(_button_rotation)
	_light.scale = Vector2(_size, _size)
