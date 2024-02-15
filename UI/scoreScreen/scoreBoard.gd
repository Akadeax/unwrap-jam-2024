extends Control
class_name ScoreBoard

const score_dict = {
	PickupObject.Type.CHAIR : 10,
	PickupObject.Type.CHAIR2 : 10,
	PickupObject.Type.ROLLING_CHAIR : 10,
	PickupObject.Type.SMALL_COUCH : 12,
	PickupObject.Type.BOX : 15,
	PickupObject.Type.BOX2 : 15,
	PickupObject.Type.FRIDGE : 20,
	PickupObject.Type.STOVE : 20,
	PickupObject.Type.SINK : 22,
	PickupObject.Type.SINK2 : 22,
	PickupObject.Type.KITCHEN_SINK : 22,
	PickupObject.Type.TOILET : 23,
	PickupObject.Type.TABLE : 25,
	PickupObject.Type.TABLE2 : 25,
	PickupObject.Type.FISH_COFFEE_TABLE : 25,
	PickupObject.Type.COMPUTER_DESK : 30,
	PickupObject.Type.TV_DESK : 30,
	PickupObject.Type.DRAWER : 50,
	PickupObject.Type.OPEN_DRESSER : 50,
	PickupObject.Type.LAMP : 50,
	PickupObject.Type.TUB : 90,
	PickupObject.Type.SOFA : 100,
	PickupObject.Type.BED : 100,
}
var amount_of_objects : Array[int] = []
var score : int = 0
var lost_score : int = 0

@export var bg : ColorRect

@export var score_thresholds : Array[int] = [0, 30, 60, 100, 150]
@export var score_stamps : Array[Texture2D]
@export var score_texts : Array[Texture2D]
@export var stamp_roll_curve : Curve

@export var stamp_holder : TextureRect
@export var stamp_text_holder : TextureRect
@export var you_scored_holder : TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.objectDroppedOff.connect(on_object_dropped_off)
	EventBus.objectDestroyed.connect(on_object_destroyed)

	amount_of_objects.resize(score_dict.values().size())
	amount_of_objects.fill(0)


	hide()
	EventBus.time_over.connect(_on_time_over)


var do_time : bool = false
var time : float = 0
func _process(delta):
	if do_time:
		time += delta / 4.5


func _on_time_over():
	get_tree().paused = true
	bg.color.a = 0.3


	var old_scale : Vector2 = scale
	modulate.a = 0
	scale = Vector2.ZERO

	var you_scored_scale : Vector2 = you_scored_holder.scale
	you_scored_holder.scale = Vector2.ZERO

	var stamp_text_scale : Vector2 = stamp_text_holder.scale
	stamp_text_holder.scale = Vector2.ZERO

	var stamp_scale : Vector2 = stamp_holder.scale
	stamp_holder.scale = Vector2.ZERO

	show()
	var board_tween := get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).set_parallel(true).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	board_tween.tween_property(self, "modulate:a", 1, 0.5)
	board_tween.tween_property(self, "scale", old_scale, 0.75)
	board_tween.chain().tween_callback(init_scoreboard)




	await get_tree().create_timer(3).timeout


	var score_index : int
	for i in range(score_thresholds.size() - 1, -1, -1):
		if score > score_thresholds[i]:
			score_index = i
			break


	# you scored
	var you_scored_tween := get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).set_parallel(true).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	you_scored_tween.tween_property(you_scored_holder, "scale", you_scored_scale, 0.5)

	await get_tree().create_timer(3).timeout


	# stampyou score
	var stamp_x_pos := stamp_holder.global_position.x
	var stamp_y_pos := stamp_holder.global_position.y
	stamp_holder.global_position.x -= 200
	stamp_holder.global_position.y -= 200

	var stamp_tween := get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).set_parallel(true).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	stamp_tween.tween_property(stamp_holder, "scale", stamp_scale, 0.5)
	stamp_tween.tween_property(stamp_holder, "global_position:x", stamp_x_pos, 0.5)
	stamp_tween.tween_property(stamp_holder, "global_position:y", stamp_y_pos, 0.5)


	do_time = true
	$Drumroll.play()
	while time < 1:
		stamp_holder.texture = score_stamps.pick_random()
		await get_tree().create_timer(stamp_roll_curve.sample(time / 5)).timeout


	stamp_text_holder.scale = stamp_text_scale

	stamp_holder.texture = score_stamps[score_index]
	stamp_text_holder.texture = score_texts[score_index]


	var stamp_text_tween := get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	stamp_text_tween.tween_property(stamp_text_holder, "scale", stamp_text_scale, 0.5)
	const VAL := 0.05
	stamp_text_tween.tween_property(stamp_text_holder, "scale", stamp_text_scale + Vector2(VAL, VAL), 0.2)
	stamp_text_tween.tween_property(stamp_text_holder, "scale", stamp_text_scale - Vector2(VAL, VAL), 0.2)
	stamp_text_tween.tween_property(stamp_text_holder, "scale", stamp_text_scale + Vector2(VAL, VAL), 0.2)
	stamp_text_tween.tween_property(stamp_text_holder, "scale", stamp_text_scale - Vector2(VAL, VAL), 0.2)
	stamp_text_tween.tween_property(stamp_text_holder, "scale", stamp_text_scale + Vector2(VAL, VAL), 0.2)
	stamp_text_tween.tween_property(stamp_text_holder, "scale", stamp_text_scale - Vector2(VAL, VAL), 0.2)
	stamp_text_tween.tween_property(stamp_text_holder, "scale", stamp_text_scale, 0.2)

	await get_tree().create_timer(3).timeout





func init_scoreboard():
	EventBus.amntUpdate.emit(amount_of_objects)
	EventBus.totalUpdate.emit(score,amount_of_objects)
	EventBus.damagesUpdate.emit(lost_score,amount_of_objects)


func on_object_dropped_off(type : PickupObject.Type, damage_percentage : float):
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
