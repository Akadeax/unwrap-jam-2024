extends CharacterBody2D
class_name PlayerController

@export var forward_speed : float = 200
@export var rotation_speed : float = 90

var current_move_angle : float = -90

@export_group("body")
@export var body_holder : Node2D


@export_group("fin")
@export var fin_holder : Node2D

var current_fin_angle : float = -90

@export var fin_follow_speed : float = 45
@export var fin_follow_curve : Curve


# pickup var
@export var is_holding_object : bool = false
var objects = []
var held_object

func _physics_process(delta):

	#region handle movement and animation
	# handle input
	if Input.is_action_pressed("left"):
		current_move_angle -= rotation_speed * delta

	elif Input.is_action_pressed("right"):
		current_move_angle += rotation_speed * delta

	velocity = Vector2(cos(deg_to_rad(current_move_angle)), sin(deg_to_rad(current_move_angle))) * forward_speed

	# body
	var move_body_angle : float = current_move_angle + 90
	rotation = deg_to_rad(move_body_angle)

	# fin
	var body_fin_rotation_diff := current_move_angle - current_fin_angle
	var closeness_factor := absf(body_fin_rotation_diff) / 100
	var follow_speed : float = fin_follow_speed * delta * fin_follow_curve.sample(closeness_factor)

	current_fin_angle = move_toward(current_fin_angle, current_move_angle, follow_speed)
	fin_holder.rotation =  deg_to_rad(current_fin_angle + 90) - deg_to_rad(move_body_angle)
	#endregion

	move_and_slide()


func _on_pickup_area_body_entered(body):
	if body.is_in_group("pickup"):
		objects.push_back(body)


func _on_pickup_area_body_exited(body):
	if body.is_in_group("pickup"):
		objects.erase(body)


func _process(delta):
	if not held_object or not is_instance_valid(held_object):
		is_holding_object = false
	
	if is_holding_object:
		if Input.is_action_pressed("drop"):
			held_object.drop()
			is_holding_object = false
	else:
		if Input.is_action_pressed("pickup") and not objects.is_empty():
			objects.sort_custom(distance_sort)
			objects[0].pickup(self)
			#var object = objects[0]
			#objects[0].get_parent().remove_child(objects[0])
			#add_child(object)
			held_object = objects[0]
			is_holding_object = true
		

func distance_sort(lhs,rhs) -> bool:
	return (Vector2(lhs.position - position).length_squared() < Vector2(rhs.position - position).length_squared())
