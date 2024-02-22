extends Node

@export var initial_state: State

var current_state : State
var states : Dictionary = {}

func _ready():
	
	for child in get_children():
		if child is State:
			# lowercase child Node name
			states[child.name.to_lower()] = child
			child.Transitioned.connect(_on_child_transition)
			
	if initial_state:
		initial_state.enter()
		current_state = initial_state
	# emits every time the player moves
	Autoload.PlayerMovedSignal.connect(_on_player_moved)

func _on_player_moved():
	if current_state:
		current_state.update()

# these two arguments are passed during .emit
func _on_child_transition(state, new_state_name):
	if state != current_state:
		return
	
	# change Node name to lowercase	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.exit()
		
	new_state.enter()
	current_state = new_state
