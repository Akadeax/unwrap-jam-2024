extends Area2D

@export var deliver_player : AudioStreamPlayer
@export var deliver_particles : GPUParticles2D

var is_ending : bool = false
var is_driving : bool = false

func _process(delta):
	if is_ending:
		var players = get_tree().get_nodes_in_group("player")
		for player in players:
			player.position = position
			player.visible = false
			if is_driving:
				position += (Vector2(-100, 0) * delta).rotated(rotation)
	
func _on_body_entered(body):
	if body.is_in_group("pickup"):
		if (!body.is_held):
			body.queue_free()
			deliver_player.play()
			deliver_particles.emitting = true
		else:
			body.in_delivery = true


func _on_body_exited(body):
	if body.is_in_group("pickup"):
		body.in_delivery = false


func _on_door_body_entered(body):
	if body is PlayerController:
		is_ending = true
		$DoorOpen.visible = false
		$DoorClosed.visible = true
		get_tree().get_first_node_in_group("cam").apply_shake(80, 80)
		await get_tree().create_timer(1.0).timeout
		$DoorClosed.visible = false
		$VanClosed.visible = true
		get_tree().get_first_node_in_group("cam").apply_shake(80, 80)
		await get_tree().create_timer(1.0).timeout
		
		
		EventBus.time_over.emit()
