extends Node3D

const SPEED : float = 2
const FADE_DURATION : float = 2.0

@onready var mesh := $MeshInstance3D
# @onready var destroy_timer := $DestroyTimer

var turning_radius : float
var target : Vector3
var velocity := Vector3(0, 0, 0)
var time : float = 0
var phase : float
var timer : Timer
var alpha : float = 1

func _ready() -> void:
	$ExplosionParticles3D.visible = false
	var theta := deg_to_rad(randf_range(-60, 60))
	turning_radius = randf_range(30, 50)
	velocity = SPEED * Vector3(sin(theta), cos(theta), 0)
	phase = randf_range(-PI, PI)
	var surface : StandardMaterial3D = mesh.get_surface_override_material(0)
	var new_surface = surface.duplicate()
	mesh.set_surface_override_material(0, new_surface)

func _process(delta: float) -> void:
	time += delta
	var r := global_position - target
	r += 0.3 * r.length() * Vector3(sin(time / 2 + phase), cos(time / 2 + phase), 0)
	var rot := Quaternion(velocity.normalized(), r.normalized()).normalized()
	rot = Quaternion.IDENTITY.slerp(rot, 1 - exp(-delta * SPEED / turning_radius))
	velocity *= rot
	velocity = SPEED * velocity.normalized()
	quaternion = Quaternion(Vector3.UP, velocity.normalized()).normalized()
	global_position += velocity * delta

func destroy():
	$ExplosionParticles3D.visible = true
	timer = Timer.new()
	timer.wait_time = FADE_DURATION / 10.0
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
	add_child(timer)
	timer.start()
	
func _on_Timer_timeout():
	var surface : StandardMaterial3D = mesh.get_surface_override_material(0)

	if $Sprite3D.modulate.a > 0:
		$Sprite3D.modulate.a -= 0.1
	if $GPUParticles3D.lifetime > 0:
		$GPUParticles3D.lifetime -= 0.25
	if $ExplosionParticles3D.lifetime > 0:
		$ExplosionParticles3D.lifetime -= 0.25
	
	alpha -= 0.1

	surface.albedo_color = Color(0, 131, 206, alpha)
	
	if alpha <= 0:
		queue_free()
	else:
		timer.start()
