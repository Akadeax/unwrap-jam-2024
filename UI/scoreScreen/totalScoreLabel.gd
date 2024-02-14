extends Label

func _ready():
	EventBus.totalUpdate.connect(change_score)

func change_score(current_score : int, amnt : Array[int]):
	var wait_time : float = 0
	for i in range(amnt.size()):
		if amnt[i] != 0:
			wait_time+=0.3
	wait_time += 0.6
	await get_tree().create_timer(wait_time).timeout
	
	var amnt_of_items : int = 0
	for i in range(amnt.size()):
		amnt_of_items += amnt[i]
	
	text = "      Total     %s" %amnt_of_items
	if amnt_of_items < 10:
		text += " "
	text += "        %s" %current_score
