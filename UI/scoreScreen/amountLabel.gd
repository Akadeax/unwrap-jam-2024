extends Label

var name_dict = {
	0 : "chair   ",
	1 : "box     ",
	2 : "table   ",
	3 : "drawer  ",
	4 : "sofa    ",
}

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.amntUpdate.connect(amnt_update)
	pass # Replace with function body.

func amnt_update(amnt : Array[int]):
	text ="Object type     amnt      value\n\n"
	for i in range(amnt.size()):
		if amnt[i] != 0:
			await get_tree().create_timer(0.3).timeout
			text += " %s        " %name_dict[i]
			text += "%s         " %amnt[i]
			var total_val : int= ScoreBoard.score_dict[PickupObject.Type.get(name_dict[i].strip_edges().to_upper())]*amnt[i] 
			text += "%s \n" %total_val


