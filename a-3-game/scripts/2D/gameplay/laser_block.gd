extends StaticBody2D


const LASER_SCENE = preload("res://scenes/2D/gameplay/laser.tscn")

var blocked := false
var transferring := false
var laser: Node2D
var player_lit := false
var override := false
var matched := false

@onready var laser_origin: Node2D = $LaserOrigin
@onready var mesh: MeshInstance2D = $Mesh2D
@onready var light: PointLight2D = $PointLight2D

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
	Global.LIGHT_COLOR.WHITE: Color(1, 1, 1, 0.8),
	Global.LIGHT_COLOR.RED: Color(1, 0, 0, 0.8),
	Global.LIGHT_COLOR.GREEN: Color(0.19607843, 0.8039216, 0.19607843, 0.8),
	Global.LIGHT_COLOR.BLUE: Color(0.25490198, 0.4117647, 0.88235295, 0.8),
	Global.LIGHT_COLOR.YELLOW: Color(1, 1, 0, 0.8),
	Global.LIGHT_COLOR.PURPLE: Color(0.4, 0.2, 0.6, 0.8),
	Global.LIGHT_COLOR.CYAN: Color(0.2509804, 0.8784314, 0.8156863, 0.8)
}


func _ready():
	if COLOR_MAP.has(_color_type):
		mesh.modulate = COLOR_MAP[_color_type]
		# Doesn't work as it should.
		#light.texture.gradient.set_color(0, mesh.modulate)
	if not is_in_group("Prisma"):
		add_to_group("Prisma")


func set_incoming_light_color(color: Global.LIGHT_COLOR) -> void:
	_incoming_light_color = color

	# Update laser color every frame.
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
		else:
			final_laser_color = COLOR_MAP.get(_color_type, Color.BLACK)
			_laser_instance.set_laser_properties(_color_type, final_laser_color)

var lit = false:
	set(value):
		if value:
			light.visible = true
			if not is_instance_valid(_laser_instance):
				_laser_instance = LASER_SCENE.instantiate()
				add_child(_laser_instance)

				_laser_instance.global_position = laser_origin.global_position
				_laser_instance.global_rotation = laser_origin.global_rotation
				_laser_instance.get_node("RayCast2D").add_exception(self)
		else:
			light.visible = false
			if is_instance_valid(_laser_instance):
				_laser_instance.queue_free()
				_laser_instance = null


func change_lit_status(new_status: bool) -> void:
	lit = new_status


func _physics_process(_delta: float) -> void:
	if player_lit == false and blocked == true:
		change_lit_status(false)
	elif transferring == true and is_instance_valid(laser):
		change_lit_status(true)
	elif player_lit == true and override == false:
		change_lit_status(true)
	elif override == true and matched == true:
		change_lit_status(true)
	else:
		change_lit_status(false)
