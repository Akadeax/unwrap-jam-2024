extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.damagesUpdate.connect(update_damage_label)

func update_damage_label(lost_score : int, amnt : Array[int]):
	var wait_time : float = 0
	for i in range(amnt.size()):
		if amnt[i] != 0:
			wait_time+=0.3
	wait_time += 0.3
	await get_tree().create_timer(wait_time).timeout
	text = "      Damages             %s" %lost_score

