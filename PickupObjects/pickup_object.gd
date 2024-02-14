extends RigidBody2D
signal deliver(health_procent, base_score)

@export var base_score : float
@export var max_health : float

var health : float
var is_held = false;
const relative_pos = Vector2(0,-400);
var shark;
var immunity_time : float
@export var max_immunity_time : float

# Called when the node enters the scene tree for the first time.
func _ready():
	health = max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if is_held:
		rotation = shark.rotation
		position = shark.position + relative_pos.rotated(shark.rotation)
		linear_velocity = shark.velocity
	

func pickup( new_shark ):
	shark = new_shark;
	is_held = true;

func drop():
	is_held = false;


func damage_object():
	health -= 1
	
	if health < 0:
		# call reduce score
		print("I die")
		queue_free()
	#update sprite

func _on_tree_exiting():
	deliver.emit(float(health/max_health), base_score)
	


func _on_area_2d_area_entered(area):
	if ((shark as Node2D) != area):
		#shark.linear_velocity *= -1
		damage_object()
		print("damage")
