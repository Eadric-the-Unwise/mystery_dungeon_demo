extends Room
#-----------------------------------------
@onready var spawn_map = $"Spawn Map"
var goblin_regular := preload("res://enemy/goblin_regular.tscn")
var goblin_green := preload("res://enemy/goblin_green.tscn")
# Array of enemies for this room
var spawn_enemies: Array = [
	goblin_regular, goblin_regular
]

