extends Area2D

func _on_body_entered(body):
	if body.is_in_group("pickup"):
		if (!body.is_held):
			body.queue_free()
		else:
			body.in_delivery = true


func _on_body_exited(body):
	if body.is_in_group("pickup"):
		body.in_delivery = false


func _on_door_body_entered(body):
	if body is PlayerController:
		$DoorOpen.visible = false
		$DoorClosed.visible = true
		#get_tree().get_first_node_in_group("cam").apply_shake(80, 80)
		await get_tree().create_timer(1.0).timeout
		$DoorClosed.visible = false
		$VanClosed.visible = true
		#get_tree().get_first_node_in_group("cam").apply_shake(80, 80)
		#await get_tree().create_timer(1.0).timeout
		#lerp(position,position + Vector2(-1000, 0).rotated(rotation),)
		
		print("game end")
