extends RigidBody2D


const LASER_SCENE = preload("res://scenes/2D/gameplay/laser.tscn")

# Most of these values are useless for the mirrors. However, leaving them declared as false prevents errors with the lasers (we would otherwise need to create separate logic for them).
var blocked := false
var transferring := false
var laser: Node2D
var player_lit := false
var override := false
var matched := false
var just_lit := false

@onready var raycast: RayCast2D = $RayCast2D
@onready var _laser_origin: Node2D = $LaserOrigin
@onready var light: PointLight2D = $PointLight2D

@onready var particles: CPUParticles2D = $CPUParticles2D

var laser_origin: Node2D
var _laser_instance: Node2D = null

var _incoming_light_color: Global.LIGHT_COLOR = Global.LIGHT_COLOR.WHITE

@export_enum("Vertical Movement:1", "Horizontal Movement:2") var movement_axis = 1

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

var lit = false:
	set(value):
		if value:
			light.enabled = true
			if laser_origin and just_lit == false:
					raycast.target_position = laser_origin.global_position - global_position
					just_lit = true
			# Create laser.
			if not is_instance_valid(_laser_instance):
				_laser_instance = LASER_SCENE.instantiate()
				add_child(_laser_instance)

				_laser_instance.global_position = _laser_origin.global_position
				_laser_instance.global_rotation = _laser_origin.global_rotation + deg_to_rad(45)
		else:
			light.enabled = false
			just_lit = false
			if is_instance_valid(_laser_instance):
				_laser_instance.queue_free()
				_laser_instance = null


func _ready():
	if not is_in_group("Prisma"):
		add_to_group("Prisma")
	if not is_in_group("Mirror"):
		add_to_group("Mirror")
	if not is_in_group("Rotatable"):
		add_to_group("Rotatable")
	
	$Guideline.visible = false


func set_incoming_light_color(color: Global.LIGHT_COLOR) -> void:
	_incoming_light_color = color

	# Update laser color if it already exists (this function is *not* called every frame while the object is active, not sure what the difference is).
	if is_instance_valid(_laser_instance):
		var final_laser_color: Color
		final_laser_color = COLOR_MAP.get(_incoming_light_color, Color.BLACK)
		_laser_instance.set_laser_properties(_incoming_light_color, final_laser_color)


func change_lit_status(new_status: bool) -> void:
	lit = new_status


func _physics_process(_delta: float) -> void:
	# Raycast target position is rotation-dependent. This fixes that.
	raycast.rotation = -rotation
	# Keep rotation value between 0 and 360.
	var angle: float
	if is_instance_valid(laser):
		angle = rad_to_deg(global_rotation - laser.global_rotation)
		if angle < 0:
			angle += 360
		elif angle > 360:
			angle -= 360
	
	# Check whether received laser is currently being blocked. Overriden by the player shining a matching light.
	if blocked == true:
		change_lit_status(false)
	# Check whether it is currently transferring a laser and it has not moved.
	elif is_instance_valid(laser) and angle < 180 and raycast.is_colliding() and raycast.get_collider() == laser_origin:
		change_lit_status(true)
	# Default state.
	else:
		change_lit_status(false)
