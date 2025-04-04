extends CharacterBody2D

@export var drift_speed: float = 10.0      # The base drifting speed
@export var burst_speed: float = 450.0       # Initial speed during a burst
@export var burst_cooldown: float = 2.50      # Minimum time between bursts (seconds)
@export var burst_duration: float = 0.5      # How long a burst lasts (seconds)

@onready var game_controller: Node = $"../GameController"

@onready var debug_label = $DebugLabel
@onready var food_sprite: Sprite2D = $JellyBodySprite/FoodSprite
signal jelly_died()


var target_position: Vector2
var carrying_food_object: bool = false
var returning_to_base: bool = false
var targeted_food: Node2D = null
var time_since_last_delivered_food: float = 0.0
var jelly_energy: float = 35.0
var burst_duration_final = burst_duration

# Variables for burst behavior
var current_burst_speed: float = drift_speed
var is_bursting: bool = false
var time_since_last_burst: float = 0.0
var burst_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("jelly")
	global_position.y = 350.0
	target_position = global_position
	food_sprite.visible = false

func _physics_process(delta: float) -> void:
	update_debug_label()
	
	time_since_last_burst += delta
	time_since_last_delivered_food += delta
	if time_since_last_delivered_food >= jelly_energy:
		die()
	
	# Determine the current target: if carrying food, return to base; otherwise, pursue food.
	var base_node = get_tree().get_first_node_in_group("dropoff")
	var base_position = base_node.global_position
	
	if carrying_food_object and returning_to_base:
		target_position = base_position
	else:
		if targeted_food and is_instance_valid(targeted_food):
			retarget_food()
		else:
			find_new_food_target()
	
	# Calculate desired direction toward target.
	var to_target = target_position - global_position
	var distance = to_target.length()
	var desired_direction: Vector2 = to_target.normalized() if (distance > 5.0) else Vector2.ZERO
	
	
	# Check if we should trigger a burst.
	if not is_bursting and time_since_last_burst >= burst_cooldown and desired_direction != Vector2.ZERO:
		# 20% chance per frame after cooldown to trigger a burst.
		if randi() % 100 < 20:
			# Set burst_direction once with a random offset.
			burst_direction = desired_direction.rotated(randf_range(-0.4, 0.4))
			is_bursting = true
			current_burst_speed = burst_speed
			time_since_last_burst = 0.0
			# Create a tween to interpolate current_burst_speed from burst_speed to drift_speed.
			var tw = get_tree().create_tween()
			tw.set_trans(Tween.TRANS_SINE)
			tw.tween_property(self, "current_burst_speed", drift_speed, burst_duration_final)
			tw.connect("finished", Callable(self, "_on_burst_finished"))
	
	# Set velocity: use burst behavior if in a burst, otherwise drift normally.
	if is_bursting:
		velocity = burst_direction * current_burst_speed
	else:
		velocity = desired_direction * drift_speed
	
	move_and_slide()

func _on_burst_finished() -> void:
	is_bursting = false
	calculate_burst_duration()

# --- Retargeting and Target Selection ---

func retarget_food() -> void:
	var current_target_distance = global_position.distance_to(targeted_food.global_position)
	for food in get_tree().get_nodes_in_group("food"):
		if food.is_targeted:
			continue
		var food_distance = global_position.distance_to(food.global_position)
		if food_distance < current_target_distance:
			targeted_food.is_targeted = false
			targeted_food = food
			targeted_food.is_targeted = true
			break
	target_position = targeted_food.global_position

func find_new_food_target() -> void:
	var closest_food = null
	var closest_food_distance = INF
	for food in get_tree().get_nodes_in_group("food"):
		if food.is_targeted:
			continue
		var food_distance = global_position.distance_to(food.global_position)
		if food_distance < closest_food_distance:
			closest_food_distance = food_distance
			closest_food = food
	
	if closest_food:
		targeted_food = closest_food
		targeted_food.is_targeted = true
		target_position = closest_food.global_position
	else:
		target_position = global_position

# --- Food Pickup/Drop Functions ---

func pick_up_food() -> void:
	if not carrying_food_object:
		carrying_food_object = true
		returning_to_base = true
		food_sprite.visible = true
		if targeted_food:
			targeted_food.is_targeted = false
			targeted_food = null

func drop_off_food() -> void:
	carrying_food_object = false
	returning_to_base = false
	target_position = global_position
	food_sprite.visible = false
	time_since_last_delivered_food = 0.0
	

func die():
	jelly_died.emit()
	queue_free()

func calculate_burst_duration(): #scale jellyfish's burst time with available food
	var burst_duration_modifier = game_controller.available_food
	burst_duration_final = burst_duration + (0.05 * burst_duration_modifier)
	


func update_debug_label() -> void:
	debug_label.text = "Energy: " + str( round(jelly_energy - time_since_last_delivered_food)) + "\n Burst Duration: " + str(burst_duration_final)
