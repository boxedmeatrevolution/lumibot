extends Camera3D

const NORMAL_FOV : float = 40
const ZOOMED_FOV : float = 7
const NORMAL_SENSITIVITY : float = 0.002
const ZOOMED_SENSITIVITY : float = 0.0001
const NORMAL_SCOPE_SCALE : float = 0.3
const ZOOMED_SCOPE_SCALE : float = 0.3
const RECOIL_DECAY_TIME : float = 0.2
const SHAKE_DECAY_TIME : float = 0.1
const SHAKE_BIG_DECAY_TIME : float = 0.4

var sensitivity := NORMAL_SENSITIVITY
var is_zoomed_in := false
var can_shoot = true

# Camera shake
var shake_intensity = 0.75

const Bullet = preload("res://entities/Bullet.tscn")

var rot_x : float = 0
var rot_y : float = 0
var rot_x_recoil : float = 0
var rot_x_shake : float = 0
var rot_y_shake : float = 0

var rot_z : float = 0

var dead := false

# Audio players
var shot_player = AudioStreamPlayer.new()
var hit_player = AudioStreamPlayer.new()
var music_player = AudioStreamPlayer.new()

@onready var scope = $Scope
@onready var timer = $Timer
@onready var greyscale := $GreyscaleMesh

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

	# Add audio
	add_child(shot_player)
	shot_player.stream = load("res://sounds/shot2.ogg")
	add_child(hit_player)
	hit_player.stream = load("res://sounds/shot.ogg")
	add_child(music_player)
	music_player.stream = load("res://sounds/ld56_music_longer.ogg")
	music_player.connect("finished", Callable(self, "on_music_loop"))
	music_player.play()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !dead && Input.is_action_pressed("zoom"):
		zoom_in()
	else:
		zoom_out()
		
	if is_zoomed_in:
		rot_x_recoil *= exp(-delta / RECOIL_DECAY_TIME)
	if shake_intensity > 5:
		shake_intensity *= exp(-delta / SHAKE_BIG_DECAY_TIME)
	else:
		shake_intensity *= exp(-delta / SHAKE_DECAY_TIME)
	var shake_factor = 0.5
	if is_zoomed_in:
		shake_factor = 0.3
	rot_x_shake = deg_to_rad(randf_range(-shake_intensity, shake_intensity) * shake_factor)
	rot_y_shake = deg_to_rad(randf_range(-shake_intensity, shake_intensity) * shake_factor)
	rotation.x = rot_x + rot_x_recoil + rot_x_shake
	rotation.y = rot_y + rot_y_shake
	rotation.z = rot_z
	
	if dead:
		rot_z = (rot_z + deg_to_rad(80)) * exp(-delta / 2) - deg_to_rad(80)
func _input(event):
	if !dead:
		if event is InputEventMouseMotion:
			rot_x += -event.relative.y * sensitivity
			rot_y += -event.relative.x * sensitivity
			rot_x = clampf(rot_x, deg_to_rad(-20), deg_to_rad(30))
			rot_y = clampf(rot_y, deg_to_rad(-35), deg_to_rad(35))

		if Input.is_action_pressed("shoot") and can_shoot:
			shoot()

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
	rot_x_recoil = deg_to_rad(2)
	
	shot_player.play()
	timer.start()

func _on_Timer_timeout():
	can_shoot = true

func shake(intensity : float) -> void:
	shake_intensity += intensity

func _on_area_entered(area: Area3D) -> void:
	area.get_parent().queue_free()
	dead = true
	greyscale.visible = true
	shake(10)

func _on_music_loop():
	music_player.play()
	