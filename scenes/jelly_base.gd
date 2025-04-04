extends CharacterBody2D

@export var move_speed: float =  5.0 #slow floater
@export var move_interval: float = 15 #how frequently the base sets a new target to float to
@export var jelly_scene: PackedScene
@onready var MoveTimer = $Timer

var target_position: Vector2
@onready var dropoffzone: Area2D = $dropoffzone
signal jelly_spawned
signal food_collected

func _ready() -> void:
	add_to_group("jelly_base")
	
	#set initial position
	pick_new_target()
	global_position = target_position
	
	#set up movement timer
	MoveTimer.wait_time = move_interval
	MoveTimer.timeout.connect(pick_new_target)
	MoveTimer.start()
	
	dropoffzone.body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	global_position = global_position.move_toward(target_position, move_speed * delta)


func pick_new_target():
	var viewport_size = get_viewport_rect().size
	var new_x = randf_range(350, viewport_size.x - 350)
	target_position = Vector2(new_x, randf_range(100, 250))

func _on_body_entered(body):
	if body.is_in_group("jelly") and body.carrying_food_object:
			body.drop_off_food()
			food_collected.emit()

#func spawn_new_jelly():
	#if jelly_scene:
		#var new_jelly = jelly_scene.instantiate()
		#var spawn_offset = Vector2(randf_range(-50, 50), randf_range(50, 100))
		#new_jelly.global_position = global_position + spawn_offset
		#
		#get_parent().add_child(new_jelly)
		#jelly_spawned.emit(1)
		#print("Oh shit waddup, a new jello is here")
