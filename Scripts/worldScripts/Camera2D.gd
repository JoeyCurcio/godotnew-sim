extends Camera2D

# Declare some variables
@export var zoomSpeed: float = 0.05
@export var zoomMin: float = 0.5
@export var zoomMax: float = 2.0
@export var dragSensitivity: float = 1.0

# Handle the input of the middle mouse button
func _input(event):
	# Handle the movement
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		position -= event.relative * dragSensitivity / zoom
		
	# Handle the zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom += Vector2(zoomSpeed, zoomSpeed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= Vector2(zoomSpeed, zoomSpeed)
		
		# Clamp the zoom to the specific range
		zoom = clamp(zoom, Vector2(zoomMin, zoomMin), Vector2(zoomMax, zoomMax))
