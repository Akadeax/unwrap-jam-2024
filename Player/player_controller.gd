extends CharacterBody2D
class_name PlayerController

@export var forward_speed : float = 200
@export var rotation_speed : float = 90

var current_move_angle : float = -90

@export_group("body")
@export var body_holder : AnimatedSprite2D
@export var fishie_holder : AnimatedSprite2D

@export_group("fin")
@export var fin_holder : AnimatedSprite2D

var current_fin_angle : float = -90

@export var fin_follow_speed : float = 45
@export var fin_follow_curve : Curve

var moving_back : bool = false
@export var moving_back_multiplier : float = 0.4

# pickup var
@export var is_holding_object : bool = false
var objects = []
var held_object
var held_weight : float
var knockback_dir : Vector2
var knockback_time_left : float

var current_tongue_angle : float = -50
@export var tongue_rotation_speed : float = 50

@export_group("input")
@export var left_input : String = "left"
@export var right_input : String = "right"
@export var back_input : String = "back"
@export var pickup_input : String = "pickup"
@export var drop_input : String = "drop"
@export var yeet_input : String = "yeet"

func _physics_process(delta):

	#region handle movement and animation
	# handle input
	if Input.is_action_pressed(left_input) && !moving_back:
		current_move_angle -= rotation_speed * delta
		current_tongue_angle -= tongue_rotation_speed * delta

	elif Input.is_action_pressed(right_input) && !moving_back:
		current_move_angle += rotation_speed * delta
		current_tongue_angle += tongue_rotation_speed * delta

	current_tongue_angle = clampf(current_tongue_angle, -50, 50)
	$Tongue.set_rotation(deg_to_rad(current_tongue_angle))

	if Input.is_action_just_pressed(back_input):
		current_move_angle += 180
		moving_back = true
		fishie_holder.play()
		fin_holder.speed_scale = 0.25
	elif Input.is_action_just_released(back_input):
		current_move_angle -= 180
		moving_back = false
		fishie_holder.frame = 0
		fishie_holder.pause()
		fin_holder.speed_scale = 1


	var curr_speed := forward_speed - held_weight
	if moving_back:
		curr_speed *= moving_back_multiplier

	velocity = Vector2(cos(deg_to_rad(current_move_angle)), sin(deg_to_rad(current_move_angle))) * curr_speed

	# body
	if !moving_back:
		var move_body_angle : float = current_move_angle + 90
		rotation = deg_to_rad(move_body_angle)

		# fin
		var body_fin_rotation_diff := current_move_angle - current_fin_angle
		var closeness_factor := absf(body_fin_rotation_diff) / 100
		var follow_speed : float = fin_follow_speed * delta * fin_follow_curve.sample(closeness_factor)

		current_fin_angle = move_toward(current_fin_angle, current_move_angle, follow_speed)
		fin_holder.rotation =  deg_to_rad(current_fin_angle + 90) - deg_to_rad(move_body_angle)
	#endregion

	knockback_time_left -= delta
	if knockback_time_left > 0:
		velocity = knockback_dir * 150 * knockback_time_left

	if (move_and_slide()):
		knockback(get_wall_normal()*50, 0.2)
		get_tree().get_first_node_in_group("cam").apply_shake(8.5, 30)


func knockback(dir : Vector2, time : float):
	knockback_dir = dir
	knockback_time_left = time

func _on_pickup_area_body_entered(body):
	if body.is_in_group(pickup_input):
		print("added")
		objects.push_back(body)


func _on_pickup_area_body_exited(body):
	if body.is_in_group("pickup"):
		objects.erase(body)


func _process(__):
	if not held_object or not is_instance_valid(held_object):
		is_holding_object = false

	if is_holding_object:
		$Tongue.visible = false
		$Teeth.visible = true
		if Input.is_action_pressed(drop_input):
			held_object.drop()
			held_weight = 0
			is_holding_object = false
		if Input.is_action_pressed(yeet_input):
			held_object.yeet()
			held_weight = 0
			is_holding_object = false
			knockback(up_direction.rotated(rotation)*-50, 0.2)

	else:
		$Tongue.visible = true
		$Teeth.visible = false
		if Input.is_action_pressed(pickup_input) and not objects.is_empty():
			print(objects.size())
			objects.sort_custom(distance_sort)
			held_weight = objects[0].pickup(self)
			print(held_weight)
			held_object = objects[0]
			is_holding_object = true


func distance_sort(lhs,rhs) -> bool:
	return (Vector2(lhs.position - position).length_squared() < Vector2(rhs.position - position).length_squared())
