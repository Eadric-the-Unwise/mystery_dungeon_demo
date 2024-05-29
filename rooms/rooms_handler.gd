extends Node2D

var current_room : Room
var rooms : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is Room:
			# Add child (state) to States Dictionary (lowercase child Node name)
			rooms[child.name.to_lower()] = child
			# connect the RoomEntered and RoomExited signals that are emitted from Room class (room.gd)
			# Pass the name of the room entered
			child.RoomEntered.connect(_on_child_room_entered.bind(child))
			child.RoomExited.connect(_on_child_room_exited.bind(child))

func _on_child_room_entered(entering_room):
	# Update and keep track of the current room in a list
	current_room = entering_room
	#(In room.gd)
	current_room.activate_room_enemies()
		

func _on_child_room_exited(exiting_room):
	#(In room.gd)
	exiting_room.deactivate_room_enemies() 
