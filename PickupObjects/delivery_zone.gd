extends Area2D

func _on_body_entered(body):
	if body.is_in_group("pickup"):
		if (!body.is_held):
			body.queue_free()
		else:
			body.in_delivery = true


func _on_body_exited(body):
	if body.is_in_group("pickup"):
		body.in_delivery = true
