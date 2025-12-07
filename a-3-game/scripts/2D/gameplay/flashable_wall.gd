extends StaticBody2D


@onready var raycast = $RayCast2D
var laser_origin: Node2D
var collider: Node2D

# Obsolete, but prevents invalid assignments.
var blocked := false

var laser: Node2D = null
var laser_color: int

var player_lit := false
var override := false
var matched := false
var just_lit := false

@onready var mesh: MeshInstance2D = $MeshInstance2D

const COLOR_MAP = {
	# Colors are at .8 transparency purely for visual elegance. This is also where the lasers derive their colors from.
	Global.LIGHT_COLOR.WHITE: Color(1, 1, 1),
	Global.LIGHT_COLOR.RED: Color(1, 0, 0),
	Global.LIGHT_COLOR.GREEN: Color(0.19607843, 0.8039216, 0.19607843),
	Global.LIGHT_COLOR.BLUE: Color(0.25490198, 0.4117647, 0.88235295),
	Global.LIGHT_COLOR.YELLOW: Color(1, 1, 0),
	Global.LIGHT_COLOR.PURPLE: Color(0.4, 0.2, 0.6),
	Global.LIGHT_COLOR.CYAN: Color(0.2509804, 0.8784314, 0.8156863)
}

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
				if laser_origin and just_lit == false:
					raycast.target_position = laser_origin.global_position - global_position
					just_lit = true
			else:
				just_lit = false
				var tween = create_tween()
				tween.tween_property(self, "modulate:a", 1.0, 0.3)
				# Waiting creates issues with the lasers. --> It looks like it most likely doesn't anymore, but I did not test this extensively.
				await get_tree().create_timer(0.15).timeout
				set_collision_layer_value(1, true)
				remove_from_group("Disappeared")


func _ready() -> void:
	if COLOR_MAP.has(_color_type):
		mesh.modulate = COLOR_MAP[_color_type]
	if not is_in_group("Flashable"):
		add_to_group("Flashable")


func _physics_process(_delta: float) -> void:
	# Raycast target position is rotation-dependent. This fixes that.
	raycast.rotation = -rotation
	if raycast.is_colliding():
		collider = raycast.get_collider()
	# Check whether laser is currently being blocked. This is *not* calling the change_lit_status function because it should not be changing groups.
	if laser_origin and is_in_group("Disappeared") and collider and collider != laser_origin and collider is not TileMapLayer and player_lit == false:
		just_lit = false
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.3)
		await get_tree().create_timer(0.15).timeout
		set_collision_layer_value(1, true)
		
	# Check whether laser color has changed. This is necessary to do here due to the disappearing behaviour.
	elif collider and collider.is_in_group("Prisma") and collider._laser_instance and collider._laser_instance.laser_color_enum != laser_color:
		change_lit_status(false)
	# Check if received laser still exists and matches colors.
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
