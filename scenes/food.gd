extends Area2D
signal food_collected

var is_targeted: bool = false #tracks if a jelly is cumming for the food

func _ready() -> void:
	add_to_group("food")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("jelly") and !body.carrying_food_object:
		body.pick_up_food()
		queue_free() #obliterate the food
