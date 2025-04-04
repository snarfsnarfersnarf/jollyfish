extends CharacterBody2D

@export var drift_speed: float = 20.0
@export var burst_speed: float = 150
@export var burst_cooldown: float = 0.15
@export var burst_duration: float = 0.25

@onready var debug_label = $DebugLabel

var threat_target: Node2D = null
var patrol_center: Vector2

var current_burst_speed: float = drift_speed
var is_bursting: bool = false
var time_since_last_burst: float = 0.0
var burst_direction: Vector2 = Vector2.ZERO

func _ready():
	#add_to_group("jelly")
	global_position.y = 350.0
	patrol_center = global_position

func _physics_process(delta):
	time_since_last_burst += delta

	var target_position = patrol_center
	var closest_threat: Node2D = null
	var closest_distance = INF

	for threat in get_tree().get_nodes_in_group("threat"):
		var dist = global_position.distance_to(threat.global_position)
		if dist < closest_distance:
			closest_threat = threat
			closest_distance = dist

	if closest_threat:
		threat_target = closest_threat
		target_position = threat_target.global_position
		if closest_distance < 30:
			threat_target.queue_free()
			threat_target = null

	var to_target = target_position - global_position
	var direction = to_target.normalized() if to_target.length() > 5.0 else Vector2.ZERO

	if not is_bursting and time_since_last_burst >= burst_cooldown and direction != Vector2.ZERO:
		if randi() % 100 < 25:
			burst_direction = direction.rotated(randf_range(-0.15, 0.15))
			is_bursting = true
			current_burst_speed = burst_speed
			time_since_last_burst = 0.0
			var tw = get_tree().create_tween()
			tw.set_trans(Tween.TRANS_SINE)
			tw.tween_property(self, "current_burst_speed", drift_speed, burst_duration)
			tw.connect("finished", Callable(self, "_on_burst_finished"))

	velocity = burst_direction * current_burst_speed if is_bursting else direction * drift_speed
	move_and_slide()

	debug_label.text = "Threat: " + (str(threat_target) if threat_target else "None")

func _on_burst_finished():
	is_bursting = false
