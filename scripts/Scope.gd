extends Camera3D

const NORMAL_FOV : float = 40
const ZOOMED_FOV : float = 15
const NORMAL_SENSITIVITY : float = 0.002
const ZOOMED_SENSITIVITY : float = 0.0004
const NORMAL_SCOPE_SCALE : float = 0.15
const ZOOMED_SCOPE_SCALE : float = 0.6
const RECOIL_DECAY_TIME : float = 0.2

var sensitivity := NORMAL_SENSITIVITY
var is_zoomed_in := false
var can_shoot = true

# Camera shake
var shake_amount = 0.0
var shake_decay = 10.0
var shake_intensity = 0.75

const Bullet = preload("res://entities/Bullet.tscn")

var rot_x : float = 0
var rot_y : float = 0
var rot_x_recoil : float = 0

@onready var scope = $Scope
@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
	scope.scale = Vector3(NORMAL_SCOPE_SCALE, NORMAL_SCOPE_SCALE, NORMAL_SCOPE_SCALE)
	fov = NORMAL_FOV
	
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
		rot_x_recoil *= exp(-delta / RECOIL_DECAY_TIME)
		#if shake_amount > 0:
			#shake_amount -= shake_decay * delta
			#var shake_offset = Vector3(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity)) * shake_amount
			#global_transform.origin += shake_offset
		#else:
			#global_transform.origin = global_transform.origin
	rotation.x = rot_x + rot_x_recoil
	rotation.y = rot_y
		
func _input(event):
	if event is InputEventMouseMotion:
		rot_x += -event.relative.y * sensitivity
		rot_y += -event.relative.x * sensitivity
		rot_x = clampf(rot_x, deg_to_rad(-20), deg_to_rad(30))
		rot_y = clampf(rot_y, deg_to_rad(-35), deg_to_rad(35))

	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
		
		if Input.is_action_pressed("zoom"):
			shake_amount = 1.0

# Function to zoom in
func zoom_in():
	if not is_zoomed_in:
		fov = ZOOMED_FOV
		scope.scale = Vector3(ZOOMED_SCOPE_SCALE, ZOOMED_SCOPE_SCALE, ZOOMED_SCOPE_SCALE)
		is_zoomed_in = true
		sensitivity = ZOOMED_SENSITIVITY

# Function to zoom out
func zoom_out(): 
	if is_zoomed_in:
		fov = NORMAL_FOV
		scope.scale = Vector3(NORMAL_SCOPE_SCALE, NORMAL_SCOPE_SCALE, NORMAL_SCOPE_SCALE)
		is_zoomed_in = false
		sensitivity = NORMAL_SENSITIVITY

func shoot():
	var bullet_instance = Bullet.instantiate()
	get_tree().root.add_child(bullet_instance)
	bullet_instance.global_position = global_position + 0.1 * Vector3.DOWN
	bullet_instance.velocity = -global_transform.basis.z * bullet_instance.speed + global_transform.basis.y * bullet_instance.upspeed
	can_shoot = false
	rot_x_recoil = deg_to_rad(4)
	timer.start()

func _on_Timer_timeout():
	can_shoot = true
