extends Area2D

var score
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	print(body)
	if body.is_in_group("pickup"):
		body.queue_free()


#func _on_area_entered(area):
	#if area.is_in_group("pickup"):
		#area.queue_free()