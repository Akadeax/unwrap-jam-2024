extends RigidBody2D
signal deliver(health_procent, base_score)

@export var base_score : float
@export var max_health : float

enum Type{ CHAIR, SOFA, DRAWER, RUG, TABLE, BOX }
@export var type : Type

var health : float
var is_held = false;
@export var relative_pos : Vector2 = Vector2(0,-400);
var shark;
var immunity_time : float
@export var max_immunity_time : float

# Called when the node enters the scene tree for the first time.
func _ready():
	health = max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if is_held:
		global_rotation = shark.rotation
		global_position = shark.position + relative_pos.rotated(shark.rotation)


func pickup( new_shark ):
	shark = new_shark;
	is_held = true;

func drop():
	is_held = false;
	linear_velocity = shark.velocity


func damage_object():
	health -= 1

	if health < 0:
		# call reduce score
		print("I die")
		queue_free()
	#update sprite

func _on_tree_exiting():
	deliver.emit(float(health/max_health), base_score)

func _on_area_2d_body_entered(body):
	print("damage wall")
	if (body is TileMap or body.is_in_group("pickup")) and is_held:
		shark.knockback(Vector2(0, 200).rotated(shark.rotation) , 0.2)
		damage_object()

func _on_area_2d_area_entered(area):
	if ((shark as Node2D) != area):
		#shark.linear_velocity *= -1
		damage_object()
		print("damage")
