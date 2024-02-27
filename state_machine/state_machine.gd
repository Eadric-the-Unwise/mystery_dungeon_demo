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
			# disable _process for States
			child.set_process(false)
			
	if initial_state:
		initial_state.enter()
		# Enable _process for initial_state
		initial_state.set_process(true)
		current_state = initial_state
	# emits every time the player moves
	Autoload.PlayerMovedSignal.connect(_on_player_moved)

func _on_player_moved():
	if current_state:
		current_state.update()


func _on_child_transition(state, new_state_name): # these two arguments are passed during .emit
	if state != current_state:
		return
	
	# change Node name to lowercase	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.exit()
		# disable _process for State
		current_state.set_process(false)
		
	new_state.enter()
	new_state.set_process(true)
	current_state = new_state
