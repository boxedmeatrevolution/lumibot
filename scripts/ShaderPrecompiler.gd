extends Node3D

@onready var rocket := $Rocket

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	rocket.destroy()

func _on_timer_2_timeout() -> void:
	queue_free()
