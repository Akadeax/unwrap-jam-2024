extends RigidBody2D
class_name PickupObject
signal deliver(health_procent, base_score)

@export var fragility : float
@export var max_health : float
@export var destruction_frames : float

enum Type{ CHAIR, BOX, TABLE, DRAWER, SOFA }
@export var type : Type

var health : float
var is_held = false;
@export var relative_pos : Vector2 = Vector2(0,-400);
var shark;
var immunity_time : float
@export var max_immunity_time : float

var relative_rot : float

# Called when the node enters the scene tree for the first time.
func _ready():
	health = max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if is_held:
		global_rotation = shark.global_rotation + relative_rot
		global_position = shark.global_position + relative_pos.rotated(shark.global_rotation)


func pickup( new_shark ):
	shark = new_shark;
	is_held = true;
	relative_rot = angle_difference(shark.rotation, global_rotation)
	set_collision_layer_value(1,0);

func drop():
	is_held = false;
	linear_velocity = shark.velocity * 1.3
	set_collision_layer_value(1,1);
	

func yeet():
	is_held = false;
	linear_velocity = shark.velocity * 3
	set_collision_layer_value(1,1);


func damage_object():
	health -= fragility
	var i : int = 1
	while  ( health < max_health - max_health/ destruction_frames * i):
		i+=1
	$Sprite2D.frame = i - 1
	
	if health < 0:
		queue_free()

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

