@tool
extends StaticBody2D

@onready var raycast = $RayCast2D
var laser_block: Node2D
var collider: Node2D

var laser: Node2D = null
var blocked := false
var laser_color: int

var player_lit := false
var override := false
var matched := false


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

var lit = false:
	set(value):
			if value == true:
				var tween = create_tween()
				tween.tween_property(self, "modulate:a", 0.0, 0.3)
				set_collision_layer_value(1, false)
				add_to_group("Disappeared")
				# Cast raycast back at laser origin to check for blockages
				if laser_block:
					raycast.target_position = laser_block.global_position - global_position
			else:
				var tween = create_tween()
				tween.tween_property(self, "modulate:a", 1.0, 0.3)
				# Waiting creates issues with the lasers. --> It looks like it most likely doesn't anymore, but I did not test this extensively.
				await get_tree().create_timer(0.15).timeout
				set_collision_layer_value(1, true)
				remove_from_group("Disappeared")


func _ready() -> void:
	if not is_in_group("Flashable"):
		add_to_group("Flashable")

func _physics_process(_delta: float) -> void:
	if raycast.is_colliding():
		collider = raycast.get_collider()
	# Check whether laser is currently being blocked. This is *not* calling the change_lit_status function because it should not be changing groups.
	if is_in_group("Disappeared") and collider and collider != laser_block.get_parent():
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.3)
		await get_tree().create_timer(0.15).timeout
		set_collision_layer_value(1, true)
		
	# Check whether laser is telling the block it is being blocked. 99% this is now obsolete, but I did not bother testing. Reactivate if problems occur.
	#elif player_lit == false and blocked == true:
		#change_lit_status(false)
		
	# Check whether laser color has changed. This is necessary to do here due to the disappearing behaviour.
	elif collider and collider.is_in_group("Prisma") and collider._laser_instance and collider._laser_instance.laser_color_enum != laser_color:
		change_lit_status(false)
	# Check if received laser still exists.
	elif is_instance_valid(laser):
		change_lit_status(true)
	# Check if player is interacting and a static light is not overriding this.
	elif player_lit == true and override == false:
		change_lit_status(true)
	# Check if static light is interacting.
	elif override == true and matched == true:
		change_lit_status(true)
	# Default state.
	else:
		change_lit_status(false)


func change_lit_status(new_status: bool) -> void:
	lit = new_status
