extends StaticBody2D

# None of these values are doing anything here, but it prevents crashes. This object should not have used the flashable_wall instance.
@onready var raycast = $RayCast2D
var laser_origin: Node2D
var collider: Node2D

var blocked := false

var laser: Node2D = null
var laser_color: int

var player_lit := false
var override := false
var matched := false
var just_lit := false
var laser_original_position: Vector2

@onready var mesh: MeshInstance2D = $MeshInstance2D

var player : Player


func _ready() -> void:
	for i in get_parent().get_parent().get_parent().get_children(true):
		if i.is_in_group("Player"):
			player = i
			return


func _process(_delta: float) -> void:
	if player and player.score <= 0:
		queue_free()
