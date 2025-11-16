extends Node2D

@onready var raycast: RayCast2D = $RayCast2D
@onready var line: Line2D = $Line2D

# This function will be called by the prisma to set the laser's color
func set_laser_color(color: Color) -> void:
	line.default_color = color

func _physics_process(delta: float) -> void:
	# Force the raycast to check for collisions in the current frame
	raycast.force_raycast_update()
	
	var cast_point: Vector2
	
	# If the raycast is hitting an object
	if raycast.is_colliding():
		# The end of the line is the point of collision
		# We use to_local to convert the global collision point to the Line2D's local space
		cast_point = to_local(raycast.get_collision_point())
	else:
		# If it's not hitting anything, the end of the line is the end of the raycast
		cast_point = raycast.target_position
		
	# Update the second point of the Line2D to draw the beam to the correct length
	line.set_point_position(1, cast_point)
