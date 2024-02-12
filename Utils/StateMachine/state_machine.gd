extends Node
class_name StateMachine

var states : Dictionary = {}
var current_state : State = null

@export var start_state : State

func _ready():
	current_state = start_state
	for child in get_children():
		if child is State:
			states[child.name] = child

	current_state.enter()

func _process(delta):
	if current_state != null:
		current_state.update(delta)

	for key in states.keys():
		states[key].background_update(delta)

func transition(new_state_name : String):
	if new_state_name == current_state.name:
		return

	if states[new_state_name].can_transition_into() == false:
		return

	current_state.exit()
	current_state = states[new_state_name]
	current_state.enter()
