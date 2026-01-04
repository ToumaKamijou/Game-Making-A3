extends StaticBody2D


var player : Player


func _ready() -> void:
	for i in get_parent().get_parent().get_parent().get_children(true):
		if i.is_in_group("Player"):
			player = i
			return


func _process(_delta: float) -> void:
	if player and player.score >= 5:
		queue_free()
