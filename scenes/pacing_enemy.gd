extends CharacterBody2D

@export var move_speed: float = 60.0
@export var gravity: float = 900.0

@onready var floor_check: RayCast2D = $FloorCheck
var direction: int = -1

func _physics_process(delta: float) -> void:
    velocity.y += gravity * delta
    velocity.x = move_speed * direction
    move_and_slide()

    floor_check.position.x = abs(floor_check.position.x) * direction
    if is_on_wall() or not floor_check.is_colliding():
        direction *= -1

func hit() -> void:
    queue_free()
