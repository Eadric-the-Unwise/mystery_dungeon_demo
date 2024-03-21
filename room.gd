class_name Room
extends Area2D

@onready var camera_2d: Camera2D = $"../Camera2D"
#-----------------------------------------
# Add an array for enemies for this room

func _on_area_exited(_area: Area2D) -> void:
	# Add logic for all current enemies in this room to be set to EnemyIdle State
	print("Exited: Room ", name)
	Autoload.RoomExited.emit()

func _on_area_entered(_area: Area2D) -> void:
	print("Entered: Room ", name)
	camera_2d.position = position


