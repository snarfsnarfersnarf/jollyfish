extends Node

@export var jelly_count: int = 1
@export var total_food_collected: int = 0
@export var available_food: int = 0
@onready var jelly_base: CharacterBody2D = $"../jelly base"
@onready var resource_counter: Label = %"Resource Counter"
@onready var jelly_spawner_ui: Control = $"../CanvasLayer/VBoxContainer/JellySpawnerUI"

@export var game_runtime: float = 0.0

func _ready() -> void:
	jelly_base.jelly_spawned.connect(_on_jelly_spawned)
	jelly_base.food_collected.connect(_on_food_collected)
	update_spawn_buttons()

func _process(delta: float) -> void:
	for jelly in get_tree().get_nodes_in_group("jelly"):
		if not jelly.jelly_died.is_connected(_on_jelly_died):
			jelly.jelly_died.connect(_on_jelly_died)
			print("Jelly connected")
			update_jelly_count_display()
	game_runtime += delta
	update_jelly_count_display()
	update_spawn_buttons()

func spawn_jelly(jelly_scene: PackedScene, cost: int) -> void:
	if jelly_scene:
		var new_jelly = jelly_scene.instantiate()
		# Position the new jelly at a desired location in your game world.
		# This example places it near the center of the viewport; adjust as needed.
		new_jelly.global_position = get_viewport().get_visible_rect().size / 2
		# Add the new jelly to the main scene (assumes the main scene is the parent of GameController).
		get_tree().get_root().get_node("Main Scene").add_child(new_jelly)
		print("Spawned new jelly of type: ", jelly_scene)
		jelly_count += 1
		available_food -= cost

func _on_jelly_died():
	jelly_count -= 1
	update_jelly_count_display()
	if jelly_count <=0:
		game_over()

func _on_jelly_spawned(amount: int):
	jelly_count += amount
	update_jelly_count_display()

func _on_food_collected():
	total_food_collected +=1
	available_food += 1
	update_jelly_count_display()
	update_spawn_buttons()

func update_jelly_count_display():
	resource_counter.text =(
	"Jelly Count: " + str(jelly_count)
	+ "\nTotal Food Collected: " + str(total_food_collected)
	+ "\nAvailable Food: " + str(available_food)
	+ "\nGame Runtime in Seconds: " + str(round(game_runtime))
	)

func update_spawn_buttons():
	var btnA = jelly_spawner_ui.get_node("VBoxContainer/SpawnJellyAButton") as Button
	var btnB = jelly_spawner_ui.get_node("VBoxContainer/SpawnJellyBButton") as Button
	var btnC = jelly_spawner_ui.get_node("VBoxContainer/SpawnJellyCButton") as Button
	var btnD = jelly_spawner_ui.get_node("VBoxContainer/SpawnJellyDButton") as Button
	btnB.disabled = true
	btnC.disabled = true
	btnD.disabled = true
	if available_food < 3:
		btnA.disabled = true
	else:
		btnA.disabled = false

func calculate_food_spawn_rate():
	pass

func game_over():
	pass
