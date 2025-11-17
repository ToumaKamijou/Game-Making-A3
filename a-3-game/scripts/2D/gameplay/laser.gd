extends Node2D

@onready var raycast: RayCast2D = $RayCast2D
@onready var line: Line2D = $Line2D

# NEW: The laser needs to know its own color enum to pass to other prismas.
var laser_color_enum: Global.LIGHT_COLOR = Global.LIGHT_COLOR.WHITE

# NEW: This will store the object the laser is currently hitting.
var _currently_lit_object: Object = null

# NEW: A function to give the laser the information it needs when it's created.
func set_laser_properties(p_color_enum: Global.LIGHT_COLOR, p_visual_color: Color) -> void:
	laser_color_enum = p_color_enum
	line.default_color = p_visual_color

func _physics_process(delta: float) -> void:
	# --- Part 1: Update the visual line (your existing code) ---
	raycast.force_raycast_update()
	var cast_point: Vector2
	if raycast.is_colliding():
		cast_point = to_local(raycast.get_collision_point())
	else:
		cast_point = raycast.target_position
	line.set_point_position(1, cast_point)

	# --- Part 2: NEW - Handle activating other objects ---
	var collider: Object = null
	if raycast.is_colliding():
		collider = raycast.get_collider()

	# If the object we're hitting is different from the one last frame...
	if collider != _currently_lit_object:
		# ...deactivate the old object if it exists and can be deactivated.
		if is_instance_valid(_currently_lit_object) and _currently_lit_object.has_method("change_lit_status"):
			_currently_lit_object.change_lit_status(false)
		
		# ...and try to activate the new object.
		if is_instance_valid(collider):
			# We only care about activating other prismas for now.
			if collider.is_in_group("Prisma"):
				var prisma_color_type = collider._color_type
				
				# Activation condition: A COLORED laser hits a WHITE prisma.
				if laser_color_enum != Global.LIGHT_COLOR.WHITE and prisma_color_type == Global.LIGHT_COLOR.WHITE:
					# Tell the white prisma what color we are...
					collider.set_incoming_light_color(laser_color_enum)
					# ...then turn it on using the function you want to keep!
					collider.change_lit_status(true)

	# Update the state for the next frame
	_currently_lit_object = collider

# NEW: When the laser is destroyed, make sure it deactivates anything it was lighting up.
func _exit_tree() -> void:
	if is_instance_valid(_currently_lit_object) and _currently_lit_object.has_method("change_lit_status"):
		_currently_lit_object.change_lit_status(false)
