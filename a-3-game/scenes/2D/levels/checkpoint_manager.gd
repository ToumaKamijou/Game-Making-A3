extends Node

var last_location: Node2D
var player: CharacterBody2D

func _ready() -> void:
	for i in get_parent().get_children(true):
		if i.is_in_group("Player"):
			player = i
			break
	last_location = player
