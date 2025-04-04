extends Area2D

@export var drift_speed: float = 40.0
@export var roam_radius: float = 200.0
@export var change_target_interval: float = 3.0

var target_position: Vector2
var time_since_change: float = 0.0

func _ready() -> void:
	add_to_group("threat")
	set_random_target()

func _process(delta: float) -> void:
	time_since_change += delta
	if time_since_change >= change_target_interval:
		set_random_target()
		time_since_change = 0.0

	global_position = global_position.move_toward(target_position, drift_speed * delta)

func set_random_target():
	var angle = randf_range(0, TAU)
	var offset = Vector2(cos(angle), sin(angle)) * randf_range(50, roam_radius)
	target_position = global_position + offset
