extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.play_object_damage.connect(_on_dmg)
	EventBus.play_object_break.connect(_on_brk)
	EventBus.increase_intensity.connect(_on_inc)
	EventBus.objectDroppedOff.connect(_on_dropped)
	$I1.play()
	$I1.volume_db = 0
	$I2.play()
	$I2.volume_db = -500
	$I3.play()
	$I3.volume_db = -500
	$I4.play()
	$I4.volume_db = -500

func _on_dmg():
	$Damage.play()


func _on_brk():
	$Break.play()

var current_intensity : int = 0
func _on_dropped(__, ___):
	current_intensity += 1

	if current_intensity == 1:
		$I2.volume_db = 0
	elif current_intensity == 2:
		$I3.volume_db = 0
	elif current_intensity == 3:
		$I4.volume_db = 0


func _on_inc():
	_on_dropped(null, null)
