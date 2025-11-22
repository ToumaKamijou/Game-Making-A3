@tool
extends StaticBody2D

var laser: Node2D = null
var blocked := false
var laser_color: int
var laser_color_new: int

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
			else:
				var tween = create_tween()
				tween.tween_property(self, "modulate:a", 1.0, 0.3)
				# Waiting creates issues with the lasers.
				#await get_tree().create_timer(0.15).timeout
				set_collision_layer_value(1, true)
				remove_from_group("Disappeared")

func _ready() -> void:
	if not is_in_group("Flashable"):
		add_to_group("Flashable")
		

func _physics_process(delta: float) -> void:
	if blocked == true:
		change_lit_status(false)
	elif is_instance_valid(laser) and laser_color == laser_color_new:
		change_lit_status(true)
	elif player_lit == true and override == false:
		change_lit_status(true)
	elif override == true and matched == true:
		change_lit_status(true)
	else:
		change_lit_status(false)

func change_lit_status(new_status: bool) -> void:
	lit = new_status
