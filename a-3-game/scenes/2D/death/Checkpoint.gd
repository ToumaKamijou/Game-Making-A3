extends Area2D

@onready var checkpoint_manager = get_parent()
@onready var particles := $CPUParticles2D

var active = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		checkpoint_manager.last_location = $RespawnPoint.global_position
		active = true

func _physics_process(delta: float) -> void:
	if active == true:
		particles.hue_variation_min = 1
		particles.hue_variation_max = 1
