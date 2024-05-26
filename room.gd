class_name Room
extends Area2D

@onready var camera_2d: Camera2D = $"../../Camera2D"

signal RoomEntered
signal RoomExited
var room_enemies : Array

#-----------------------------------------
# Add an array for enemies for this room
func _ready():
	area_exited.connect(_on_area_exited)
	area_entered.connect(_on_area_entered)

func _on_area_exited(_area: Area2D):
	# Add logic for all current enemies in this room to be set to EnemyIdle State
	print("Exited: Room ", name)
	RoomExited.emit()

func _on_area_entered(area: Area2D):
	print("Entered: Room ", name)
	# This triggers for EVERY room. Attach roomB1.gd script, instead?
	camera_2d.position = position
	RoomEntered.emit()

func activate_room_enemies():
	if room_enemies:
		for enemy in room_enemies:
			enemy.active = true
func deactivate_room_enemies():
	if room_enemies:
		for enemy in room_enemies:
			enemy.enemy_current_state.Transitioned.emit(enemy.enemy_current_state, "EnemyIdle")
			enemy.active = false
			
			
