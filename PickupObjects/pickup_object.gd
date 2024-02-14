extends RigidBody2D
class_name PickupObject
signal deliver(health_procent, base_score)

@export var fragility : float
@export var max_health : float
@export var destruction_frames : float

@export var destroyed_particles_scene : PackedScene

enum Type{ CHAIR, BOX, TABLE, DRAWER, SOFA }
@export var type : Type

var health : float
var is_held = false;
@export var relative_pos : Vector2 = Vector2(0,-400);
var shark;
var immunity_time : float
@export var max_immunity_time : float
var immune : bool
var in_delivery : bool

var relative_rot : float

var iteract_delay : float
const max_interact_delay : float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	health = max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):


	if is_held:
		global_rotation = shark.global_rotation + relative_rot
		global_position = shark.global_position + relative_pos.rotated(shark.global_rotation)
	else:
		if immune:
			immunity_time -= delta
			if immunity_time <= 0:
				immune=false
				set_collision_layer_value(1,1);

		if in_delivery:
			queue_free()

func pickup( new_shark ) -> float:
	shark = new_shark;
	is_held = true;
	relative_rot = angle_difference(shark.rotation, global_rotation)
	set_collision_layer_value(1,0);
	return mass

func drop():
	is_held = false;
	linear_velocity = shark.velocity * 1.3
	immune = true
	immunity_time = max_immunity_time


func yeet():
	is_held = false;
	linear_velocity = shark.velocity * 3
	immune = true
	immunity_time = max_immunity_time


func damage_object():
	health -= fragility
	var i : int = 1
	while  ( health < max_health - max_health/ destruction_frames * i):
		i+=1
	$Sprite2D.frame = i - 1

	if health < 0:
		var part := destroyed_particles_scene.instantiate() as GPUParticles2D
		part.emitting = true
		get_tree().root.add_child(part)
		part.global_position = global_position
		queue_free()
		get_tree().get_first_node_in_group("cam").apply_shake(50, 50)
	else:
		$BonkParticles.emitting = true
		get_tree().get_first_node_in_group("cam").apply_shake(20, 30)

func _on_tree_exiting():
	if health > 0:
		EventBus.objectDroppedOff.emit(type, health/max_health)
	else:
		EventBus.objectDestroyed.emit(type)

func _on_area_2d_body_entered(body):
	if ((body is TileMap  and is_held ) or body.is_in_group("pickup") ) and (body as Node2D) != self:
		if (is_held):
			shark.knockback(Vector2(0, 200).rotated(shark.rotation) , 0.2)
		damage_object()
