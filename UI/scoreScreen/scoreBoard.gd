extends Control
class_name ScoreBoard

const score_dict = {
	PickupObject.Type.CHAIR : 10,
	PickupObject.Type.BOX : 15,
	PickupObject.Type.TABLE : 25,
	PickupObject.Type.DRAWER : 50,
	PickupObject.Type.SOFA : 100,
}
var amount_of_objects : Array[int] = [0,0,0,0,0]
var score : int = 0
var lost_score : int = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.objectDroppedOff.connect(on_object_dropped_off)
	EventBus.objectDestroyed.connect(on_object_destroyed)
	# EventBus.objectDroppedOff.emit(PickupObject.Type.CHAIR,0.5)
	# EventBus.objectDroppedOff.emit(PickupObject.Type.CHAIR,1)
	# EventBus.objectDroppedOff.emit(PickupObject.Type.CHAIR,1)
	# EventBus.objectDroppedOff.emit(PickupObject.Type.CHAIR,1)
	# EventBus.objectDroppedOff.emit(PickupObject.Type.TABLE,1)
	# EventBus.objectDestroyed.emit(PickupObject.Type.SOFA)

	hide()
	EventBus.time_over.connect(_on_time_over)

func _on_time_over():
	get_tree().paused = true
	show()
	EventBus.amntUpdate.emit(amount_of_objects)
	EventBus.totalUpdate.emit(score,amount_of_objects)
	EventBus.damagesUpdate.emit(lost_score,amount_of_objects)


func on_object_dropped_off(type : PickupObject.Type, damage_percentage : float):
	print("called")
	var gained_score : int = int(score_dict[type] * damage_percentage)
	score += gained_score
	lost_score +=  score_dict[type] - gained_score
	amount_of_objects[int(type)] +=1
	EventBus.scoreUpdate.emit(score)


func on_object_destroyed(type : PickupObject.Type):
	var lost : int = int(score_dict[type] * 0.5)
	score -= lost
	lost_score += lost
	EventBus.scoreUpdate.emit(score)
