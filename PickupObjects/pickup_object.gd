extends RigidBody2D
signal deliver

@export var base_score : float
@export var max_health : float
var health : float
var is_held = false;
const relative_pos = Vector2(0,10);
var shark;

# Called when the node enters the scene tree for the first time.
func _ready():
	health = max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if !is_held:
		# slow down objects
		linear_velocity *= 0.5;
		angular_velocity *= 0.5;
	else:
		linear_velocity *= 0;
		angular_velocity *= 0;
		position = shark.position + relative_pos.rotated(shark.rotation)
	

func pickup( new_shark ):
	shark = new_shark;
	is_held = true;

func drop():
	is_held = false;

func yeet( speed ):
	is_held = false;
	var yeet_speed  = Vector2(0, speed);
	linear_velocity =  yeet_speed.rotated(shark.rotation);


func _on_body_entered(body):
	if ((shark as Node2D) != body):
		shark.linear_velocity *= -1
		damage_object()
		

func damage_object():
	health -= 1
	
	if health < 0:
		# call reduce score
		print("I die")
		queue_free()
	#update sprite

func _on_tree_exiting():
	deliver.emit(float(health/max_health), base_score)
	
