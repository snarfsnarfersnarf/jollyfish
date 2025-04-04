extends Node2D

@export var food_scene: PackedScene #assign food.tscn in the inspector
@export var threat_scene: PackedScene #threat.tscn
@export var max_food_count: int = 10 #maximum amount of food which should be on the area
@export var max_threat_count: int = 3 # max amount of threats which should be in the area
@export var safe_zone_height: int = 500 #no food in top 500 px
@onready var game_controller: Node = $"../GameController"

var difficulty_scale: float = 1

func _ready() -> void:
	$SpawnTimer.timeout.connect(spawn_food) #spawns food when SpawnTimer times out
	$ThreatTimer.timeout.connect(spawn_threat)
	for i in range(10):
		spawn_food()

func _process(delta: float) -> void:
	difficulty_scale = clamp((game_controller.game_runtime * .01), 1, INF)

func spawn_food():
	var viewport_size = get_viewport_rect().size
	var food_list = get_tree().get_nodes_in_group("food") if get_tree().has_group("food") else []
	if food_list.size() >= max_food_count:
		return
	
	var food = food_scene.instantiate()
	var random_x = randf_range(100, viewport_size.x - 100) * difficulty_scale
	var random_y = randf_range(safe_zone_height, viewport_size.y - 100) * difficulty_scale
	food.position = Vector2(random_x, random_y)
	
	add_child(food)

func spawn_threat():
	print("running threat function")
	var viewport_size = get_viewport_rect().size
	var threat_list = get_tree().get_nodes_in_group("threat") if get_tree().has_group("threat") else []
	if threat_list.size() >= max_threat_count:
		print("determined there are too many threats")
		return 
		
	print("instantiating a threat")
	var threat = threat_scene.instantiate()
	var random_x = randf_range(100, viewport_size.x - 100) * difficulty_scale
	var random_y = randf_range(safe_zone_height, viewport_size.y - 100) * difficulty_scale
	threat.position = Vector2(random_x, random_y)
	add_child(threat)
