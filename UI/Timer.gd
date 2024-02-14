extends Label

@export var level_time_secs : int = 150
var current_time : float

func _ready():
	current_time = level_time_secs


func _process(delta : float):
	if current_time > 0:
		current_time -= delta
	else:
		current_time = 0
		EventBus.time_over.emit()


	text = "Time Left: %s" % as_text()




func as_text() -> String:
	var minutes := int(current_time) / 60
	var seconds := int(current_time) % 60 + 1

	var minutes_str := str(minutes)
	var seconds_str := str(seconds)

	minutes_str = "0" + minutes_str
	if seconds < 10:
		seconds_str = "0" + seconds_str

	return "%s:%s" % [minutes_str, seconds_str]
