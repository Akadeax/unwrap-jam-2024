extends Label

@export var level_time_secs : int = 150
var current_time : float

@export var progress : ProgressBar

func _ready():
	current_time = level_time_secs


func _process(delta : float):
	if get_tree().paused == false:
		if current_time > 0:
			current_time -= delta
		else:
			current_time = 0
			var van = get_tree().get_first_node_in_group("delivery")
			van.game_end()
			#EventBus.time_over.emit()

	text = as_text()
	progress.max_value = 1
	progress.value = current_time / level_time_secs




func as_text() -> String:
	var minutes := int(current_time) / 60
	var seconds := int(current_time) % 60

	var minutes_str := str(minutes)
	var seconds_str := str(seconds)

	minutes_str = "0" + minutes_str
	if seconds < 10:
		seconds_str = "0" + seconds_str

	return "Time Left"
