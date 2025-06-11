extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 900.0
@export var attack_time: float = 0.2
@export var attack_cooldown: float = 0.3

@onready var attack_area: Area2D = $AttackArea

func _ready() -> void:
    attack_area.body_entered.connect(_on_attack_area_body_entered)
    attack_area.monitoring = false

var attacking: bool = false
var facing: int = 1
var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
    velocity.y += gravity * delta

    var direction := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    if direction != 0:
        facing = sign(direction)
    velocity.x = direction * speed

    if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
        velocity.y = jump_velocity

    move_and_slide()
    attack_area.position.x = abs(attack_area.position.x) * facing

    if Input.is_action_just_pressed("attack") and not attacking:
        start_attack()

func start_attack() -> void:
    attacking = true
    attack_area.monitoring = true
    var timer = get_tree().create_timer(attack_time)
    timer.timeout.connect(end_attack)

func end_attack() -> void:
    attack_area.monitoring = false
    await get_tree().create_timer(attack_cooldown).timeout
    attacking = false

func _on_attack_area_body_entered(body: Node) -> void:
    if body.has_method("hit"):
        body.hit()
