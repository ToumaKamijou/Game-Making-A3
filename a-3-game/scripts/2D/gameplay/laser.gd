extends Node2D

@onready var raycast: RayCast2D = $RayCast2D
@onready var line: Line2D = $Line2D

var laser_color_enum: Global.LIGHT_COLOR = Global.LIGHT_COLOR.WHITE

var _currently_lit_object: Object = null

func set_laser_properties(p_color_enum: Global.LIGHT_COLOR, p_visual_color: Color) -> void:
	laser_color_enum = p_color_enum
	line.default_color = p_visual_color

func _physics_process(delta: float) -> void:
	raycast.force_raycast_update()
	var cast_point: Vector2
	if raycast.is_colliding():
		cast_point = to_local(raycast.get_collision_point())
	else:
		cast_point = raycast.target_position
	line.set_point_position(1, cast_point)

	# Handle activating other objects
	var collider: Object = null
	if raycast.is_colliding():
		collider = raycast.get_collider()

	if collider != _currently_lit_object:
		# Deactivate old target object if it changed this frame.
		if is_instance_valid(_currently_lit_object) and _currently_lit_object.has_method("change_lit_status"):
			_currently_lit_object.change_lit_status(false)
		
		# ...and try to activate the new object.
		if is_instance_valid(collider):
			if collider.is_in_group("Prisma"):
				if laser_color_enum != Global.LIGHT_COLOR.WHITE and collider._color_type == Global.LIGHT_COLOR.WHITE:
					collider.set_incoming_light_color(laser_color_enum)
					collider.change_lit_status(true)
					
	_currently_lit_object = collider

func _exit_tree() -> void:
	if is_instance_valid(_currently_lit_object) and _currently_lit_object.has_method("change_lit_status"):
		_currently_lit_object.change_lit_status(false)
