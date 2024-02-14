extends Camera2D
class_name CustomCamera

@onready var rand := RandomNumberGenerator.new()

var shake_strength : float = 0.0
var decay_rate : float = 0.0

var players : Array[Node]


@export var zoom_modifier_curve : Curve

var base_zoom : float = 0

func _ready() -> void:
	base_zoom = zoom.x

	rand.randomize()

	players = get_tree().get_nodes_in_group("player")

func apply_shake(strength : float = 15, decay : float = 50) -> void:
	shake_strength = strength
	decay_rate = decay


func _process(delta: float) -> void:
	# Fade out the intensity over time
	shake_strength = move_toward(shake_strength, 0, decay_rate * delta)

	if players.size() == 2:
		var player_distance : float = players[0].global_position.distance_to(players[1].global_position)
		var player_distance_factor : float = (player_distance / 5000)
		zoom.x = base_zoom * zoom_modifier_curve.sample(player_distance_factor)
		zoom.y = base_zoom * zoom_modifier_curve.sample(player_distance_factor)


	var avg : Vector2 = Vector2.ZERO
	for player in players:
		avg += player.global_position
	avg /= players.size()
	position = avg
	# Shake by adjusting camera.offset so we can move the camera around the level via it's position
	offset = get_random_offset()


func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)
