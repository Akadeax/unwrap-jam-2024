class_name FreeLookCamera extends Camera2D

@onready var rand := RandomNumberGenerator.new()

var shake_strength : float = 0.0
var decay_rate : float = 0.0

var players : Array[Node]

# Modifier keys' speed multiplier
const SHIFT_MULTIPLIER = 2.5
const ALT_MULTIPLIER = 1.0 / SHIFT_MULTIPLIER


@export_range(0.0, 1.0) var sensitivity: float = 0.25

# Mouse state
var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0

# Movement state
var _direction = Vector2(0.0, 0.0)
var _velocity = Vector2(0.0, 0.0)
var _acceleration = 3000
var _deceleration = -1000
var _vel_multiplier = 400

# Keyboard state
var _w = false
var _s = false
var _a = false
var _d = false
var _shift = false
var _alt = false

func _ready() -> void:
	rand.randomize()
	players = get_tree().get_nodes_in_group("player")
	
func apply_shake(strength : float = 15, decay : float = 50) -> void:
	pass

func _input(event):
	# Receives mouse motion
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
	
	# Receives mouse button input
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP: # Increases max velocity
				zoom *= 1.1
			MOUSE_BUTTON_WHEEL_DOWN: # Decereases max velocity
				zoom *= 0.9

	# Receives key input
	if event is InputEventKey:
		match event.keycode:
			KEY_W:
				_w = event.pressed
			KEY_S:
				_s = event.pressed
			KEY_A:
				_a = event.pressed
			KEY_D:
				_d = event.pressed
			KEY_SHIFT:
				_shift = event.pressed
			KEY_ALT:
				_alt = event.pressed

# Updates mouselook and movement every frame
func _process(delta):
	_update_movement(delta)

# Updates camera movement
func _update_movement(delta):
	# Computes desired direction from key states
	_direction = Vector2(
		(_d as float) - (_a as float), 
		(_s as float) - (_w as float)
	)
	
	# Computes the change in velocity due to desired direction and "drag"
	# The "drag" is a constant acceleration on the camera to bring it's velocity to 0
	var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta \
		+ _velocity.normalized() * _deceleration * _vel_multiplier * delta
	
	# Compute modifiers' speed multiplier
	var speed_multi = 1
	if _shift: speed_multi *= SHIFT_MULTIPLIER
	if _alt: speed_multi *= ALT_MULTIPLIER
	
	# Checks if we should bother translating the camera
	if _direction == Vector2.ZERO and offset.length_squared() > _velocity.length_squared():
		# Sets the velocity to 0 to prevent jittering due to imperfect deceleration
		_velocity = Vector2.ZERO
	else:
		# Clamps speed to stay within maximum value (_vel_multiplier)
		_velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier)
		_velocity.y = clamp(_velocity.y + offset.y, -_vel_multiplier, _vel_multiplier)
		translate(_velocity * delta * speed_multi * (1/zoom.x)) 

