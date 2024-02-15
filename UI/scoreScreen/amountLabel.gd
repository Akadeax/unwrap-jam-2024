extends Label

var name_dict = {
	0 : "chair       ",
	1 : "chair2      ",
	2 : "roll chair  ",
	3 : "small couch ",
	4 : "box         ",
	5 : "box2        ",
	6 : "fridge      ",
	7 : "stove       ",
	8 : "sink        ",
	9 : "sink2       ",
	10 : "kitchen sink",
	11 : "toilet      ",
	12 : "table       ",
	13 : "table2      ",
	14 : "fish table  ",
	15 : "computer    ",
	16 : "tv          ",
	17 : "drawer      ",
	18 : "open drawer ",
	19 : "lamp        ",
	20 : "tub         ",
	21 : "big couch   ",
	22 : "bed         ",
}
var name_to_type_dict = {
	"chair       " : PickupObject.Type.CHAIR,
	"chair2      " : PickupObject.Type.CHAIR2,
	"roll chair  " : PickupObject.Type.ROLLING_CHAIR,
	"small couch " : PickupObject.Type.SMALL_COUCH,
	"box         " : PickupObject.Type.BOX,
	"box2        " : PickupObject.Type.BOX2,
	"fridge      " : PickupObject.Type.FRIDGE,
	"stove       " : PickupObject.Type.STOVE,
	"sink        " : PickupObject.Type.SINK,
	"sink2       " : PickupObject.Type.SINK2,
	"kitchen sink" : PickupObject.Type.KITCHEN_SINK,
	"toilet      " : PickupObject.Type.TOILET,
	"table       " : PickupObject.Type.TABLE,
	"table2      " : PickupObject.Type.TABLE2,
	"fish table  " : PickupObject.Type.FISH_COFFEE_TABLE,
	"computer    " : PickupObject.Type.COMPUTER_DESK,
	"tv          " : PickupObject.Type.TV_DESK,
	"drawer      " : PickupObject.Type.DRAWER,
	"open drawer " : PickupObject.Type.OPEN_DRESSER,
	"lamp        " : PickupObject.Type.LAMP,
	"tub         " : PickupObject.Type.TUB,
	"big couch   " : PickupObject.Type.SOFA,
	"bed         " : PickupObject.Type.BED,
}


# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.amntUpdate.connect(amnt_update)
	pass # Replace with function body.

func amnt_update(amnt : Array[int]):
	text ="Object type     amnt      value\n"
	for i in range(amnt.size()):
		if amnt[i] != 0:
			await get_tree().create_timer(0.3).timeout
			text += " %s    " %name_dict[i]
			text += "%s         " %amnt[i]
			var total_val : int= ScoreBoard.score_dict[name_to_type_dict[name_dict[i]]]*amnt[i]
			text += "%s \n" %total_val
