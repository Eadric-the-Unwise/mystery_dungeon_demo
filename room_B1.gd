extends Room
#-----------------------------------------
var goblin_enemy := preload("res://enemy.tscn")
# Add an array for enemies for this room
var room_enemies: Array = [
	goblin_enemy
]

func _on_room_entered():
	print("_on_room_entered", room_enemies)
#func _ready():
	#RoomExited.connect(_on_room_exited)
	#RoomEntered.connect(_on_room_entered)
#
#func _on_room_exited():
	#print("_on_room_exited ", room_name)
#

#func _on_area_exited(_area: Area2D) -> void:
	## Add logic for all current enemies in this room to be set to EnemyIdle State
	#print("Exited: Room ", name)
	#Autoload.RoomExited.emit()
#
#func _on_area_entered(_area: Area2D) -> void:
	#print("Entered: Room ", name)
	## This triggers for EVERY room. Attach roomB1.gd script, instead?
	#Autoload.RoomEntered.emit()
	#camera_2d.position = position
