extends Node3D

const SPEED : float = 2
const FADE_DURATION : float = 3.0

@onready var mesh := $MeshInstance3D
@onready var gpu_particles := $GPUParticles3D

var turning_radius : float
var target : Vector3
var velocity := Vector3(0, 0, 0)
var velocity_down := Vector3(0, -0.05, 0)
var time : float = 0
var phase : float
var timer : Timer
var alpha : float = 1
var gpu_alpha : float = 1
var shot_down : bool = false
var on_floor : bool = false

func _ready() -> void:
	$ExplosionParticles3D.visible = false
	var theta := deg_to_rad(randf_range(-60, 60))
	turning_radius = randf_range(30, 50)
	velocity = SPEED * Vector3(sin(theta), cos(theta), 0)
	phase = randf_range(-PI, PI)
	var surface : StandardMaterial3D = mesh.get_surface_override_material(0)
	var new_surface = surface.duplicate()
	mesh.set_surface_override_material(0, new_surface)
	$DestroyTimer.connect("timeout", Callable(self, "_on_DestroyTimer_timeout"))

func _process(delta: float) -> void:
	if not on_floor:
		if shot_down:
			velocity += velocity_down
			global_position += velocity * delta
		else:
			time += delta
			var r := global_position - target
			r += 0.3 * r.length() * Vector3(sin(time / 2 + phase), cos(time / 2 + phase), 0)
			var rot := Quaternion(velocity.normalized(), r.normalized()).normalized()
			rot = Quaternion.IDENTITY.slerp(rot, 1 - exp(-delta * SPEED / turning_radius))
			velocity *= rot
			velocity = SPEED * velocity.normalized()
			quaternion = Quaternion(Vector3.UP, velocity.normalized()).normalized()
			global_position += velocity * delta
		
	if global_position.y <= 0 and not on_floor:
		global_position.y = 0
		on_floor = true
		gpu_particles.amount = 5
		$DestroyTimer.start()

func destroy():
	if not shot_down:
		shot_down = true
		gpu_particles.amount = 35
		$ExplosionParticles3D.visible = true
		timer = Timer.new()
		timer.wait_time = FADE_DURATION / 10.0
		timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
		add_child(timer)
		timer.start()
	
func _on_DestroyTimer_timeout():
	queue_free()
	
func _on_Timer_timeout():
	var surface : StandardMaterial3D = mesh.get_surface_override_material(0)
	
	alpha -= 0.1
	
	if alpha <= 0:
		pass
	else:
		surface.albedo_color = Color(0, 131, 206, alpha)
		timer.start()
