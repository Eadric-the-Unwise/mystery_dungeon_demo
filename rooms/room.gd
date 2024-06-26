class_name Room
extends Area2D

@onready var camera: Camera2D = $"../../Camera2D"

signal RoomEntered
signal RoomExited
var room_enemies : Array

#-----------------------------------------
# Add an array for enemies for this room
func _ready():
	area_exited.connect(_on_area_exited)
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D):
	print("Entered: Room ", name)
	# This triggers for EVERY room. Attach roomB1.gd script, instead?
	#camera.position = position
	camera.transition_to_room(self)
	RoomEntered.emit()

func _on_area_exited(_area: Area2D):
	# Add logic for all current enemies in this room to be set to EnemyIdle State
	print("Exited: Room ", name)
	RoomExited.emit()

func activate_room_enemies():
	if room_enemies:
		for enemy in room_enemies:
			#Activate Enemies' State Machines
			enemy.active = true
func deactivate_room_enemies():
	
	if room_enemies:
		for enemy in room_enemies:
			var enemy_current_state = enemy.enemy_current_state
			#Switch from EnemyFollow etc to EnemyIdle when player leaves room
			enemy_current_state.Transitioned.emit(enemy_current_state, "EnemyIdle")
			#Disable Enemy State Machines
			enemy.active = false
			
			
