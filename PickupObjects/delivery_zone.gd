extends Area2D

var score
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("pickup"):
		if (!body.is_held):
			body.queue_free()
		else :
			body.in_delivery = true


#func _on_area_entered(area):
	#if area.is_in_group("pickup"):
		#area.queue_free()


func _on_body_exited(body):
	
	if body.is_in_group("pickup"):
		body.in_delivery = true
