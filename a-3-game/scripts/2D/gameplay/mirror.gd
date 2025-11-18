extends StaticBody2D

const LASER_SCENE = preload("res://scenes/2D/gameplay/laser.tscn")

@onready var laser_origin: Node2D = $LaserOrigin
@onready var mesh: MeshInstance2D = $Mesh2D

@export var _color_type: Global.LIGHT_COLOR = Global.LIGHT_COLOR.WHITE
	#set(value):
		#_color_type = value
		#if not Engine.is_editor_hint():
			#var previous_group := get_groups()
			#for i in previous_group:
				#remove_from_group(i)
			## Make sure all prismas are in the "Prisma" group for easy finding
			#add_to_group("Mirror")
			#var new_group := Global.change_color_group(value)
			#if new_group != "":
				#add_to_group(new_group)

var _laser_instance: Node2D = null

# --- NEW VARIABLE ---
# This will temporarily store the color of the flashlight shining on us.
var _incoming_light_color: Global.LIGHT_COLOR = Global.LIGHT_COLOR.WHITE

const COLOR_MAP = {
	Global.LIGHT_COLOR.WHITE: Color.WHITE,
	Global.LIGHT_COLOR.RED: Color.RED,
	Global.LIGHT_COLOR.GREEN: Color.GREEN,
	Global.LIGHT_COLOR.BLUE: Color.BLUE,
}

func _ready():
	if COLOR_MAP.has(_color_type):
		mesh.modulate = COLOR_MAP[_color_type]
	if not is_in_group("Mirror"):
		add_to_group("Mirror")

# --- NEW FUNCTION ---
# The player will call this function right before calling change_lit_status.
# --- THIS IS THE KEY CHANGE ---
func set_incoming_light_color(color: Global.LIGHT_COLOR) -> void:
	# First, store the new incoming color. This is important for when
	# the laser is first created.
	_incoming_light_color = color

	# NEW LOGIC: If a laser already exists, update its color immediately.
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

				# --- THIS IS THE ONLY PART THAT CHANGES ---
				
				# First, determine what the outgoing laser's color should be, just like before.
				var outgoing_laser_enum: Global.LIGHT_COLOR
				if _color_type == Global.LIGHT_COLOR.WHITE:
					outgoing_laser_enum = _incoming_light_color
				else:
					outgoing_laser_enum = _color_type
				
				var visual_color = COLOR_MAP.get(outgoing_laser_enum, Color.BLACK)

				# NOW, use the new function to pass BOTH the enum and the visual color to the laser.
				_laser_instance.set_laser_properties(outgoing_laser_enum, visual_color)
		else:
			if is_instance_valid(_laser_instance):
				_laser_instance.queue_free()
				_laser_instance = null

func change_lit_status(new_status: bool) -> void:
	lit = new_status
