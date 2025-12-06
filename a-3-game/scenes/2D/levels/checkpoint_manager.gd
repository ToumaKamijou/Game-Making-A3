extends Node

var last_location: Node2D
var player: CharacterBody2D

func _ready() -> void:
	player = get_parent().get_node("Player")
	last_location = player
