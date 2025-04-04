extends Camera2D

@export var pan_speed: float = 300.0
@export var zoom_speed: float = 0.1
@export var min_zoom: Vector2 = Vector2(0.2, 0.2)
@export var max_zoom: Vector2 = Vector2(3.0, 3.0)

var is_panning = false
var last_mouse_position = Vector2()

func _process(delta: float) -> void:
	# Panning using arrow keys or "ui_" actions:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if input_vector != Vector2.ZERO:
		position += input_vector.normalized() * pan_speed * delta

func _input(event):
	# Zoom with the mouse wheel:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom -= Vector2(zoom_speed, zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom += Vector2(zoom_speed, zoom_speed)
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = event.pressed
			last_mouse_position = event.position
	elif event is InputEventMouseMotion and is_panning:
		var cursor_delta = event.position - last_mouse_position
		position -= cursor_delta / zoom
		last_mouse_position = event.position
		# Clamp zoom to desired limits:
		zoom.x = clamp(zoom.x, min_zoom.x, max_zoom.x)
		zoom.y = clamp(zoom.y, min_zoom.y, max_zoom.y)
		
