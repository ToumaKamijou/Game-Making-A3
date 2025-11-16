extends StaticBody2D

const LASER_SCENE = preload("res://scenes/2D/gameplay/laser.tscn")
enum BlockColor { RED, GREEN, BLUE }

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

# Keep a reference to the laser so we can destroy it later
var _laser_instance: Node2D = null

# Using your Global script's color enum is more consistent
const COLOR_MAP = {
	Global.LIGHT_COLOR.RED: Color.RED,
	Global.LIGHT_COLOR.GREEN: Color.GREEN,
	Global.LIGHT_COLOR.BLUE: Color.BLUE,
}

func _ready():
	# Make sure the color is set visually when the game starts
	if COLOR_MAP.has(_color_type):
		mesh.modulate = COLOR_MAP[_color_type]

var lit = false:
	set(value):
		# If the light is shining on the prisma
		if value:
			print("Activating Laser")
			# And if a laser doesn't already exist, create one
			if not is_instance_valid(_laser_instance):
				# --- THIS IS THE CORRECTED ORDER ---

				# 1. Create the instance in memory
				_laser_instance = LASER_SCENE.instantiate()
				
				# 2. Add it to the scene tree. THIS IS THE KEY STEP.
				#    This triggers the laser's _ready() and sets its @onready vars.
				add_child(_laser_instance)
				
				# 3. NOW that it's in the tree, it's safe to position it and call its functions.
				_laser_instance.global_position = laser_origin.global_position
				_laser_instance.global_rotation = laser_origin.global_rotation
				
				# Set the laser's color to be the same as the prisma's color
				var prisma_color = COLOR_MAP.get(_color_type, Color.WHITE) # Use .get() for safety
				_laser_instance.set_laser_color(prisma_color)
				
		# If the light is NOT shining on the prisma
		else:
			print("Deactivating Laser")
			# And a laser currently exists, destroy it
			if is_instance_valid(_laser_instance):
				_laser_instance.queue_free()
				_laser_instance = null
	
func change_lit_status(new_status: bool) -> void:
	lit = new_status
