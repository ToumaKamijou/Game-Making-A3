extends RigidBody2D


const LASER_SCENE = preload("res://scenes/2D/gameplay/laser.tscn")

var blocked := false
var transferring := false
var laser: Node2D
var player_lit := false
var override := false
var matched := false
var just_lit := false

var base_color_type : Global.LIGHT_COLOR = Global.LIGHT_COLOR.WHITE

var laser_origin: Node2D

@onready var raycast: RayCast2D = $RayCast2D
@onready var _laser_origin: Node2D = $LaserOrigin
@onready var mesh: MeshInstance2D = $Mesh2D
@onready var light: PointLight2D = $PointLight2D
@onready var sprite: Sprite2D = $Node2D/Sprite2D

@onready var particles: CPUParticles2D = $CPUParticles2D

@export_enum("Vertical Movement:1", "Horizontal Movement:2") var movement_axis = 1

@export var _color_type: Global.LIGHT_COLOR = Global.LIGHT_COLOR.WHITE:
	set(value):
		_color_type = value
		if not Engine.is_editor_hint():
			var previous_group := get_groups()
			for i in previous_group:
				remove_from_group(i)
			var new_group := Global.change_color_group(value)
			if new_group != "":
				add_to_group(new_group)

var _laser_instance: Node2D = null

var _incoming_light_color: Global.LIGHT_COLOR = Global.LIGHT_COLOR.WHITE

const COLOR_MAP = {
	# Colors are at .8 transparency purely for visual elegance. This is also where the lasers derive their colors from.
	Global.LIGHT_COLOR.WHITE: Color(1, 1, 1, 0.8),
	Global.LIGHT_COLOR.RED: Color(1, 0, 0, 0.8),
	Global.LIGHT_COLOR.GREEN: Color(0.19607843, 0.8039216, 0.19607843, 0.8),
	Global.LIGHT_COLOR.BLUE: Color(0.25490198, 0.4117647, 0.88235295, 0.8),
	Global.LIGHT_COLOR.YELLOW: Color(1, 1, 0, 0.8),
	Global.LIGHT_COLOR.PURPLE: Color(0.4, 0.2, 0.6, 0.8),
	Global.LIGHT_COLOR.CYAN: Color(0.2509804, 0.8784314, 0.8156863, 0.8)
}

const TEXTURE_MAP = {
	WHITE = preload("res://assets/2D/sprites/laser_white.png"),
	RED = preload("res://assets/2D/sprites/laser_red.png"),
	GREEN = preload("res://assets/2D/sprites/laser_green.png"),
	BLUE = preload("res://assets/2D/sprites/laser_blue.png"),
	YELLOW = preload("res://assets/2D/sprites/laser_yellow.png"),
	PURPLE = preload("res://assets/2D/sprites/laser_purple.png"),
	CYAN = preload("res://assets/2D/sprites/laser_cyan.png"),
}


func _ready():
	base_color_type = _color_type
	if COLOR_MAP.has(_color_type):
		mesh.modulate = COLOR_MAP[_color_type]
	if not is_in_group("Prisma"):
		add_to_group("Prisma")
	if not is_in_group("Pushable"):
		add_to_group("Pushable")
	
	$Guideline.visible = false


func set_incoming_light_color(color: Global.LIGHT_COLOR) -> void:
	_incoming_light_color = color
	
	# Update laser color (this function is called every frame).
	if is_instance_valid(_laser_instance):
		var final_laser_color: Color
		if _color_type == Global.LIGHT_COLOR.WHITE:
			final_laser_color = COLOR_MAP.get(_incoming_light_color, Color.BLACK)
			_laser_instance.set_laser_properties(_incoming_light_color, final_laser_color)
		elif _color_type == Global.LIGHT_COLOR.RED and _incoming_light_color == Global.LIGHT_COLOR.GREEN:
			final_laser_color = COLOR_MAP.get(4, Color.BLACK)
			_laser_instance.set_laser_properties(4, final_laser_color)
		elif _color_type == Global.LIGHT_COLOR.RED and _incoming_light_color == Global.LIGHT_COLOR.BLUE:
			final_laser_color = COLOR_MAP.get(5, Color.BLACK)
			_laser_instance.set_laser_properties(5, final_laser_color)
		elif _color_type == Global.LIGHT_COLOR.GREEN and _incoming_light_color == Global.LIGHT_COLOR.RED:
			final_laser_color = COLOR_MAP.get(4, Color.BLACK)
			_laser_instance.set_laser_properties(4, final_laser_color)
		elif _color_type == Global.LIGHT_COLOR.GREEN and _incoming_light_color == Global.LIGHT_COLOR.BLUE:
			final_laser_color = COLOR_MAP.get(6, Color.BLACK)
			_laser_instance.set_laser_properties(6, final_laser_color)
		elif _color_type == Global.LIGHT_COLOR.BLUE and _incoming_light_color == Global.LIGHT_COLOR.RED:
			final_laser_color = COLOR_MAP.get(5, Color.BLACK)
			_laser_instance.set_laser_properties(5, final_laser_color)
		elif _color_type == Global.LIGHT_COLOR.BLUE and _incoming_light_color == Global.LIGHT_COLOR.GREEN:
			final_laser_color = COLOR_MAP.get(6, Color.BLACK)
			_laser_instance.set_laser_properties(6, final_laser_color)
		elif _incoming_light_color != Global.LIGHT_COLOR.WHITE and _incoming_light_color == _laser_instance.laser_color_enum and _incoming_light_color != _color_type:
			final_laser_color = COLOR_MAP.get(_incoming_light_color, Color.BLACK)
			_laser_instance.set_laser_properties(_incoming_light_color, final_laser_color)
		else:
			final_laser_color = COLOR_MAP.get(_color_type, Color.BLACK)
			_laser_instance.set_laser_properties(_color_type, final_laser_color)
		_update_block_texture(_laser_instance.laser_color_enum)


var lit = false:
	set(value):
		if value:
			light.enabled = true
			if laser_origin and just_lit == true:
					raycast.target_position = laser_origin.global_position - global_position
			# Create laser.
			if not is_instance_valid(_laser_instance):
				_laser_instance = LASER_SCENE.instantiate()
				add_child(_laser_instance)

				_laser_instance.global_position = _laser_origin.global_position
				_laser_instance.global_rotation = _laser_origin.global_rotation
		else:
			light.enabled = false
			just_lit = false
			if is_instance_valid(_laser_instance):
				_laser_instance.queue_free()
				_laser_instance = null


func _update_block_texture(color: Global.LIGHT_COLOR) -> void:
	if base_color_type == Global.LIGHT_COLOR.WHITE:
		return
	match color:
		Global.LIGHT_COLOR.WHITE: sprite.texture = TEXTURE_MAP.WHITE
		Global.LIGHT_COLOR.RED: sprite.texture = TEXTURE_MAP.RED
		Global.LIGHT_COLOR.GREEN: sprite.texture = TEXTURE_MAP.GREEN
		Global.LIGHT_COLOR.BLUE: sprite.texture = TEXTURE_MAP.BLUE
		Global.LIGHT_COLOR.YELLOW: sprite.texture = TEXTURE_MAP.YELLOW
		Global.LIGHT_COLOR.PURPLE: sprite.texture = TEXTURE_MAP.PURPLE
		Global.LIGHT_COLOR.CYAN: sprite.texture = TEXTURE_MAP.CYAN
		_: sprite.texture = TEXTURE_MAP.BLACK


func change_lit_status(new_status: bool) -> void:
	lit = new_status


func _physics_process(_delta: float) -> void:
	# Raycast target position is rotation-dependent. This fixes that.
	raycast.rotation = -rotation
# 	Check whether received laser is currently being blocked. Overriden by the player shining a matching light.
	if player_lit == false and blocked == true:
		change_lit_status(false)
	# Check whether it is currently transferring a lasera nd it has not moved.
	elif transferring == true and is_instance_valid(laser) and raycast.is_colliding() and raycast.get_collider() == laser_origin:
		change_lit_status(true)
	# Check whether player is interacting and a static light is not overriding this.
	elif player_lit == true and override == false:
		change_lit_status(true)
	# Check if static light is interacting.
	elif override == true and matched == true:
		change_lit_status(true)
	# Default state.
	else:
		change_lit_status(false)
