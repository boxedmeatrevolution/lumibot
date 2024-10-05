extends Camera3D

var normal_fov = 70.0
var zoomed_fov = 20.0
var sensitivity = 0.001

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mouseButton = InputEventMouseButton.new()
	mouseButton.set_button_index(MOUSE_BUTTON_RIGHT)

	var key = InputEventKey.new()
	key.physical_keycode = KEY_CTRL

	InputMap.add_action("zoom")
	InputMap.action_add_event("zoom", mouseButton)
	InputMap.action_add_event("zoom", key)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("zoom"):
		zoom_in()
	else:
		zoom_out()

# Function to zoom in
func zoom_in():
	fov = zoomed_fov
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Function to zoom out
func zoom_out(): 
	fov = normal_fov
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 

func _input(event):
	if Input.is_action_pressed("zoom") and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		rotate_x(-event.relative.y * sensitivity)
