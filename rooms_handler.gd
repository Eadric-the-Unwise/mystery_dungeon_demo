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
			child.RoomExited.connect(_on_child_room_exited)

func _on_child_room_entered(room_name):
	# Update and keep track of the current room
	current_room = room_name

func _on_child_room_exited():
	pass
