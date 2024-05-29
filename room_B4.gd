extends Room
#-----------------------------------------
@onready var spawn_map = $"Spawn Map"
var goblin_enemy := preload("res://goblin_regular.tscn")
# Add an array for enemies for this room
var spawn_enemies: Array = [
	goblin_enemy
]

