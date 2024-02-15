extends RigidBody2D
class_name PickupObject
signal deliver(health_procent, base_score)

@export var fragility : float
@export var max_health : float = 100
@export var destruction_frames : float = 3

@export var destroyed_particles_scene : PackedScene

enum Type{ 
CHAIR, CHAIR2, ROLLING_CHAIR,
SMALL_COUCH, 
BOX, BOX2, 
FRIDGE, STOVE,
SINK, SINK2, KITCHEN_SINK,
TOILET,
TABLE, TABLE2, FISH_COFFEE_TABLE, 
COMPUTER_DESK, TV_DESK, 
DRAWER, OPEN_DRESSER,
LAMP,
TUB,
SOFA, BED }
@export var type : Type

var health : float
var is_held = false;
@export var relative_pos : Vector2 = Vector2(0,-400)
@export var wall_offset_correction : float
var shark;
var immunity_time : float = 0
@export var max_immunity_time : float = 2
var immune : bool
var in_delivery : bool

var relative_rot : float


var interact_delay : float
const max_interact_delay : float = 0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	health = max_health
	linear_damp = 100


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if immunity_time < max_immunity_time:
		immunity_time+=delta
		linear_damp = 1


	if is_held:
		global_rotation = shark.global_rotation + relative_rot
		global_position = shark.global_position + relative_pos.rotated(shark.global_rotation) + Vector2(0,-wall_offset_correction).rotated(global_rotation)
	else:
		if immune:
			interact_delay -= delta
			if interact_delay <= 0:
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
	interact_delay = max_interact_delay


func yeet():
	is_held = false;
	linear_velocity = shark.velocity * 3
	immune = true
	interact_delay = max_interact_delay


func damage_object():
	if immunity_time < max_immunity_time:
		return
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
	if ((body is TileMap and is_held ) or body.is_in_group("pickup") ) and (body as Node2D) != self:
		if (is_held):
			shark.knockback(Vector2(0, 200).rotated(shark.rotation) , 0.2)
		damage_object()
