extends Label

var name_dict = {
	0 : "chair       ",
	1 : "chair       ",
	2 : "roll chair  ",
	3 : "table       ",
	4 : "drawer      ",
	5 : "small couch ",
	6 : "box         ",
	7 : "box         ",
	8 : "fridge      ",
	9 : "stove       ",
	10 : "sink        ",
	11 : "sink        ",
	12 : "kitchen sink",
	13 : "toilet      ",
	14 : "table       ",
	15 : "table       ",
	16 : "fish table  ",
	17 : "computer    ",
	18 : "tv          ",
	19 : "lamp        ",
	20 : "tub         ",
	21 : "big couch   ",
	22 : "bed         ",
}
const score_dict = {
	PickupObject.Type.TUB : 90,
	PickupObject.Type.SOFA : 100,
	PickupObject.Type.BED : 100,
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
			text += " %s    " %name_dict[amnt[i]]
			text += "%s         " %amnt[i]
			var total_val : int= ScoreBoard.score_dict[PickupObject.Type.get(name_dict[i].strip_edges().to_upper())]*amnt[i] 
			text += "%s \n" %total_val
