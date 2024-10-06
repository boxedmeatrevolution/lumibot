extends Camera3D

const NORMAL_FOV : float = 40
const ZOOMED_FOV : float = 15
const NORMAL_SENSITIVITY : float = 0.002
const ZOOMED_SENSITIVITY : float = 0.0004
var sensitivity := NORMAL_SENSITIVITY
var is_zoomed_in := false

var rot_x : float = 0
var rot_y : float = 0

@onready var crosshair := $Crosshair

@onready var scope := $Scope

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fov = NORMAL_FOV
	scope.visible = false
	crosshair.visible = true
	var mouseButton = InputEventMouseButton.new()
	mouseButton.set_button_index(MOUSE_BUTTON_RIGHT)

	var key = InputEventKey.new()
	key.physical_keycode = KEY_CTRL

	InputMap.add_action("zoom")
	InputMap.action_add_event("zoom", mouseButton)
	InputMap.action_add_event("zoom", key)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("zoom"):
		zoom_in()
	else:
		zoom_out()

# Function to zoom in
func zoom_in():
	if not is_zoomed_in:
		scope.visible = true
		crosshair.visible = false
		fov = ZOOMED_FOV
		is_zoomed_in = true
		sensitivity = ZOOMED_SENSITIVITY
		# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Function to zoom out
func zoom_out(): 
	if is_zoomed_in:
		scope.visible = false
		crosshair.visible = true
		fov = NORMAL_FOV
		is_zoomed_in = false
		sensitivity = NORMAL_SENSITIVITY
		# Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	# if Input.is_action_pressed("zoom") and event is InputEventMouseMotion:
	if event is InputEventMouseMotion:
		rot_x += -event.relative.y * sensitivity
		rot_y += -event.relative.x * sensitivity
		rot_x = clampf(rot_x, deg_to_rad(-20), deg_to_rad(30))
		rot_y = clampf(rot_y, deg_to_rad(-35), deg_to_rad(35))
		rotation.x = rot_x
		rotation.y = rot_y
		#rotation.x += -event.relative.y * sensitivity
		#rotation.y += -event.relative.x * sensitivity
