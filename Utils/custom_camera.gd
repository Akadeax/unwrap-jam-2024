extends Camera2D
class_name CustomCamera

@onready var rand := RandomNumberGenerator.new()

var shake_strength : float = 0.0
var decay_rate : float = 0.0

func _ready() -> void:
	rand.randomize()

func apply_shake(strength : float = 15, decay : float = 50) -> void:
	shake_strength = strength
	decay_rate = decay


func _process(delta: float) -> void:
	# Fade out the intensity over time
	shake_strength = move_toward(shake_strength, 0, decay_rate * delta)

	# Shake by adjusting camera.offset so we can move the camera around the level via it's position
	offset = get_random_offset()

	if Input.is_action_just_pressed("ui_left"):
		apply_shake()
	elif Input.is_action_just_pressed("ui_right"):
		apply_shake(20, 10)


func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)