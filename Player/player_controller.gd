extends CharacterBody2D
class_name PlayerController

@export var forward_speed : float = 200
@export var rotation_speed : float = 90

var current_move_angle : float = -90

@export_group("body")
@export var body_holder : Node2D
@export var fishie_holder : AnimatedSprite2D

@export_group("fin")
@export var fin_holder : Node2D

var current_fin_angle : float = -90

@export var fin_follow_speed : float = 45
@export var fin_follow_curve : Curve

var moving_back : bool = false
@export var moving_back_multiplier : float = 0.4

# pickup var
@export var is_holding_object : bool = false
var objects = []
var held_object

var knockback_dir : Vector2
var knockback_time_left : float


func _physics_process(delta):

	#region handle movement and animation
	# handle input
	if Input.is_action_pressed("left") && !moving_back:
		current_move_angle -= rotation_speed * delta

	elif Input.is_action_pressed("right") && !moving_back:
		current_move_angle += rotation_speed * delta

	if Input.is_action_just_pressed("back"):
		current_move_angle += 180
		moving_back = true
		fishie_holder.play()
	elif Input.is_action_just_released("back"):
		current_move_angle -= 180
		moving_back = false
		fishie_holder.frame = 0
		fishie_holder.pause()


	var curr_speed := forward_speed
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

func knockback(dir : Vector2, time : float):
	knockback_dir = dir
	knockback_time_left = time

func _on_pickup_area_body_entered(body):
	if body.is_in_group("pickup"):
		print("added")
		objects.push_back(body)


func _on_pickup_area_body_exited(body):
	if body.is_in_group("pickup"):
		objects.erase(body)


func _process(__):
	if not held_object or not is_instance_valid(held_object):
		is_holding_object = false

	if is_holding_object:
		if Input.is_action_pressed("drop"):
			held_object.drop()
			is_holding_object = false
		if Input.is_action_pressed("yeet"):
			held_object.yeet()
			is_holding_object = false
			knockback(up_direction.rotated(rotation)*-50, 0.2)
			
	else:
		if Input.is_action_pressed("pickup") and not objects.is_empty():
			print(objects.size())
			objects.sort_custom(distance_sort)
			objects[0].pickup(self)
			held_object = objects[0]
			is_holding_object = true


func distance_sort(lhs,rhs) -> bool:
	return (Vector2(lhs.position - position).length_squared() < Vector2(rhs.position - position).length_squared())
