extends Node2D


@onready var raycast: RayCast2D = $RayCastCollision
@onready var visual: RayCast2D = $RayCastVisual
@onready var line: Line2D = $Line2D
@onready var light_line: Line2D = $Line2D/LightLine2D
@onready var color_line: Line2D = $Line2D/ColorLine2D

var laser_color_enum: Global.LIGHT_COLOR = Global.LIGHT_COLOR.WHITE

var _currently_lit_object: Object = null


func _ready() -> void:
	# Fixes visual bug (by making it invisible)
	visible = false
	await get_tree().create_timer(0.05).timeout
	visible = true


func set_laser_properties(p_color_enum: Global.LIGHT_COLOR, p_visual_color: Color) -> void:
	laser_color_enum = p_color_enum
	line.default_color = p_visual_color
	color_line.default_color = p_visual_color


func _physics_process(_delta: float) -> void:
	# Handle visual
	var cast_point: Vector2
	if visual.is_colliding():
		cast_point = to_local(visual.get_collision_point())
	else:
		cast_point = visual.target_position
	line.set_point_position(1, cast_point)
	light_line.set_point_position(1, cast_point)
	color_line.set_point_position(1, cast_point)
	
	# Handle activating other objects
	var collider: Object = null
	if raycast.is_colliding():
		collider = raycast.get_collider()
		# Check if laser is currently being blocked and communicate this if so.
		if collider and collider.has_method("change_lit_status"):
			collider.laser_origin = get_parent()
			if visual.is_colliding() and collider != visual.get_collider():
				if raycast.get_collision_point() != visual.get_collision_point():
					collider.blocked = true
			else:
				collider.blocked = false
		
		# Communicate necessary information to flashable walls to handle blocking/color switching.
		if collider and collider.is_in_group("Flashable"):
			collider.laser_color = laser_color_enum
			# Check whether target object is gone and skip it if so.
			if collider.is_in_group("Disappeared"):
				raycast.add_exception(collider)
				raycast.force_raycast_update()
				collider = raycast.get_collider()
		
		# Necessary to check again here because of the forced raycast update above.
		if collider:
			if collider.is_in_group("Prisma"):
				
				if collider.is_in_group("Yellow") and laser_color_enum != 0 and laser_color_enum != 4 or collider.is_in_group("Purple") and laser_color_enum != 0 and laser_color_enum != 5 or collider.is_in_group("Cyan") and laser_color_enum != 0 and laser_color_enum != 6:
					pass
				else:
					# Activate the new object and communicate necessary information.
					collider.set_incoming_light_color(laser_color_enum)
					collider.override = false
					collider.transferring = true
					collider.laser = self
					collider.change_lit_status(true)
					
			if collider.is_in_group("Flashable"):
				if collider._color_type == laser_color_enum:
					collider.override = false
					collider.laser = self
					collider.change_lit_status(true)
	
	_currently_lit_object = collider


func _exit_tree() -> void:
	if is_instance_valid(_currently_lit_object) and _currently_lit_object.is_in_group("Prisma"):
		_currently_lit_object.transferring = false
		_currently_lit_object.change_lit_status(false)
