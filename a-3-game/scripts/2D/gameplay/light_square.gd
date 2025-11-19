extends StaticBody2D

const LASER_SCENE = preload("res://scenes/2D/gameplay/laser.tscn")

var blocked := false
var transferring := false
var laser: Node2D
var player := false

@onready var laser_origin: Node2D = $LaserOrigin
@onready var mesh: MeshInstance2D = $Mesh2D

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
	Global.LIGHT_COLOR.WHITE: Color.WHITE,
	Global.LIGHT_COLOR.RED: Color.RED,
	Global.LIGHT_COLOR.GREEN: Color.LIME_GREEN,
	Global.LIGHT_COLOR.BLUE: Color.ROYAL_BLUE,
}

func _ready():
	if COLOR_MAP.has(_color_type):
		mesh.modulate = COLOR_MAP[_color_type]
	if not is_in_group("Prisma"):
		add_to_group("Prisma")


func set_incoming_light_color(color: Global.LIGHT_COLOR) -> void:
	_incoming_light_color = color

	# If a laser already exists, update its color immediately.
	if is_instance_valid(_laser_instance):
		var final_laser_color: Color
		if _color_type == Global.LIGHT_COLOR.WHITE:
			final_laser_color = COLOR_MAP.get(_incoming_light_color, Color.BLACK)
			_laser_instance.set_laser_properties(_incoming_light_color, final_laser_color)

var lit = false:
	set(value):
		if value:
			if not is_instance_valid(_laser_instance):
				_laser_instance = LASER_SCENE.instantiate()
				add_child(_laser_instance)

				_laser_instance.global_position = laser_origin.global_position
				_laser_instance.global_rotation = laser_origin.global_rotation
				_laser_instance.get_node("RayCast2D").add_exception(self)

				
				# Determine what the outgoing laser's color should be.
				var outgoing_laser_enum: Global.LIGHT_COLOR
				if _color_type == Global.LIGHT_COLOR.WHITE:
					outgoing_laser_enum = _incoming_light_color
				else:
					outgoing_laser_enum = _color_type
				
				var visual_color = COLOR_MAP.get(outgoing_laser_enum, Color.BLACK)
				_laser_instance.set_laser_properties(outgoing_laser_enum, visual_color)
		else:
			if is_instance_valid(_laser_instance):
				_laser_instance.queue_free()
				_laser_instance = null

func change_lit_status(new_status: bool) -> void:
	lit = new_status

func _physics_process(delta: float) -> void:
	if blocked == true and player == false:
		change_lit_status(false)
	elif is_instance_valid(_laser_instance) or transferring == true and is_instance_valid(laser) or player == true:
		change_lit_status(true)
	else:
		change_lit_status(false)
