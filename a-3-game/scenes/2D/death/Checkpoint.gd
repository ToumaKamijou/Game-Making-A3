extends Area2D

@onready var checkpoint_manager = get_parent()
@onready var particles := $CPUParticles2D

@onready var _respawn := $RespawnPoint

# This variable and its operations are currently adding nothing, but intended to be used in the future for changing state based on whether or not it is the active checkpoint.
var active := false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if checkpoint_manager.last_location != _respawn and checkpoint_manager.last_location != body and checkpoint_manager.last_location:
			checkpoint_manager.last_location.get_parent().active = false
		checkpoint_manager.last_location = _respawn
		active = true


func _physics_process(_delta: float) -> void:
	if active == true:
		particles.hue_variation_min = 1
		particles.hue_variation_max = 1
	else:
		particles.hue_variation_min = 0
		particles.hue_variation_max = 0
