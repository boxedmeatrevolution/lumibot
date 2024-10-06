extends Camera3D

var normal_fov = 70.0
var zoomed_fov = 20.0
var sensitivity = 0.001
var is_zoomed_in = false

# Camera shake
var shake_amount = 0.0
var shake_decay = 10.0
var shake_intensity = 0.75

@export var Bullet = preload("res://entities/Bullet.tscn")

@onready
var crosshair = $Crosshair

@onready
var scope = $Scope

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scope.visible = false
	crosshair.visible = true
	
	# Set camera zoom input
	var mouseButtonRight = InputEventMouseButton.new()
	mouseButtonRight.set_button_index(MOUSE_BUTTON_RIGHT)

	var keyCtrl = InputEventKey.new()
	keyCtrl.physical_keycode = KEY_CTRL

	InputMap.add_action("zoom")
	InputMap.action_add_event("zoom", mouseButtonRight)
	InputMap.action_add_event("zoom", keyCtrl)

	# Set shooting input
	var mouseButtonLeft = InputEventMouseButton.new()
	mouseButtonLeft.set_button_index(MOUSE_BUTTON_LEFT)
	
	var keyShift = InputEventKey.new()
	keyShift.physical_keycode = KEY_SHIFT
	
	InputMap.add_action("shoot")
	InputMap.action_add_event("shoot", mouseButtonLeft)
	InputMap.action_add_event("shoot", keyShift)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("zoom"):
		zoom_in()
	else:
		zoom_out()
		
	if is_zoomed_in:
		if shake_amount > 0:
			shake_amount -= shake_decay * delta
			print(shake_amount)
			var shake_offset = Vector3(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity)) * shake_amount
			global_transform.origin += shake_offset
		else:
			global_transform.origin = global_transform.origin
		
func _input(event):
	# if Input.is_action_pressed("zoom") and event is InputEventMouseMotion:
	if event is InputEventMouseMotion:
		rotation.x += -event.relative.y * sensitivity
		rotation.y += -event.relative.x * sensitivity

	if Input.is_action_pressed("shoot"):
		shoot()
		
		if Input.is_action_pressed("zoom"):
			shake_amount = 1.0

# Function to zoom in
func zoom_in():
	if not is_zoomed_in:
		scope.visible = true
		crosshair.visible = false
		fov = zoomed_fov			
		is_zoomed_in = true
		# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Function to zoom out
func zoom_out(): 
	if is_zoomed_in:
		scope.visible = false
		crosshair.visible = true
		fov = normal_fov
		is_zoomed_in = false
		# Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func shoot():
	var bullet_instance = Bullet.instantiate()
	get_tree().root.add_child(bullet_instance)
	bullet_instance.global_transform = global_transform.translated(Vector3(0, -5, 0))
	
