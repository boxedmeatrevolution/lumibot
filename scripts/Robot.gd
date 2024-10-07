extends Node3D

const RocketScene := preload("res://entities/Rocket.tscn")
const Building := preload("res://scripts/Building.gd")
const Player := preload("res://scripts/Scope.gd")

@onready var animation_player := $AnimationPlayer
@onready var grab_point := $GrabPoint
@onready var fire_point := $FirePoint
@onready var player : Player = owner.find_child("Camera3D")
@onready var label := $Label3D

var velocity := Vector3.ZERO
var state_timer : float

const STATE_MIN_TIME : float = 1.5
const STATE_MAX_TIME : float = 5

enum State {
	STAND,
	WALK,
	THROW,
	BARRAGE,
	STOMP,
	WAVE,
}

var state : State = State.STAND
var building : Building = null

func _ready() -> void:
	animation_player.play("STAND")

func _process(delta: float) -> void:
	state_timer += delta
	if state_timer > STATE_MAX_TIME:
		state_timer = STATE_MAX_TIME + 1
	var at_min_time := (state_timer > STATE_MIN_TIME)
	var at_max_time := (state_timer > STATE_MAX_TIME)
	if state != State.WAVE && Global.num_gremlins <= 0:
		state = State.WAVE
		state_timer = 0
		animation_player.play("WAVE", 0.5, 1.2)
		velocity = Vector3.ZERO
	if state == State.STAND:
		if building != null && at_min_time && (at_max_time || randf() > exp(-delta / 3)):
			state = State.THROW
			state_timer = 0
			animation_player.play("THROW", 0.5, 0.4)
		if building == null && Global.rocket_count <= 6 && at_min_time && (at_max_time || randf() > exp(-delta / 3)):
			state = State.BARRAGE
			state_timer = 0
			animation_player.play("BARRAGE", 0.5, 0.5)
		if at_min_time && (at_max_time || randf() > exp(-delta / 2)):
			state = State.WALK
			state_timer = 0
			animation_player.play("WALK", 0.5, 0.33)
			velocity = Vector3(randf_range(-2, 2), 0, randf_range(-1, 1))
		if building == null && at_min_time && (at_max_time || randf() > exp(-delta / 4)):
			state = State.STOMP
			state_timer = 0
			animation_player.play("STOMP", 0.5, 1.0)
	elif state == State.WALK:
		position += velocity * delta
		if at_min_time && (at_max_time || randf() > exp(-delta / 3)):
			state = State.STAND
			state_timer = 0
			animation_player.play("STAND", 0.5, 0.5)
			stomp_small()
			velocity = Vector3.ZERO
	elif state == State.THROW || state == State.BARRAGE:
		if !animation_player.is_playing():
			state = State.STAND
			state_timer = 0
			animation_player.play("STAND", 0.5, 0.5)
			velocity = Vector3.ZERO
	elif state == State.STOMP:
		if state_timer > 1.4 * 3:
			state = State.STAND
			state_timer = 0
			animation_player.play("STAND", 0.5, 0.5)
			velocity = Vector3.ZERO
	elif state == State.WAVE:
		if state_timer > 2:
			label.visible = true

func throw_building():
	if building != null:
		building.throw(get_parent(), player.global_position + 1 * Vector3.DOWN)
		building = null

func fire_missile():
		var rocket = RocketScene.instantiate()
		get_parent().add_child(rocket)
		rocket.global_position = fire_point.global_position
		rocket.target = player.global_position

func _on_area_entered(area: Area3D) -> void:
	if area.get_collision_layer_value(4):
		var b : Building = area.get_parent()
		if building == null:
			building = b
			b.pickup(grab_point)
			stomp_small()
		else:
			b.shoot(100)
			stomp_large()

func stomp_small() -> void:
	player.shake(2)

func stomp_large() -> void:
	player.shake(10)
