extends Control

@export var jelly_type_a_scene: PackedScene
@export var jelly_type_b_scene: PackedScene
@export var jelly_type_c_scene: PackedScene
@export var jelly_type_d_scene: PackedScene
@onready var game_controller: Node = $"../../../GameController"

func _ready() -> void:
	# Connect the pressed signals for the buttons.
	$VBoxContainer/SpawnJellyAButton.pressed.connect(_on_spawn_jelly_a)
	$VBoxContainer/SpawnJellyBButton.pressed.connect(_on_spawn_jelly_b)
	$VBoxContainer/SpawnJellyCButton.pressed.connect(_on_spawn_jelly_c)
	$VBoxContainer/SpawnJellyDButton.pressed.connect(_on_spawn_jelly_d)

func _on_spawn_jelly_a() -> void:
	game_controller.spawn_jelly(jelly_type_a_scene, 3)

func _on_spawn_jelly_b() -> void:
	game_controller.spawn_jelly(jelly_type_b_scene, 1)

func _on_spawn_jelly_c() -> void:
	game_controller.spawn_jelly(jelly_type_c_scene, 1)

func _on_spawn_jelly_d() -> void:
	game_controller.spawn_jelly(jelly_type_d_scene, 1)

#func spawn_jelly(jelly_scene: PackedScene, cost: int) -> void:
	#if jelly_scene:
		#var new_jelly = jelly_scene.instantiate()
		## Position the new jelly at a desired location in your game world.
		## This example places it near the center of the viewport; adjust as needed.
		#new_jelly.global_position = get_viewport().get_visible_rect().size / 2
		## Add the new jelly to the main scene (assumes the main scene is the parent of GameController).
		#get_tree().get_root().get_node("Main Scene").add_child(new_jelly)
		#print("Spawned new jelly of type: ", jelly_scene)
		#jelly_count += 1
		#available_food -= cost
