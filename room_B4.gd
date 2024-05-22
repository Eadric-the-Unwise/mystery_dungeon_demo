extends Room
#-----------------------------------------
@onready var spawn_map = $"Spawn Map"
var goblin_enemy := preload("res://enemy.tscn")
# Add an array for enemies for this room
var room_enemies: Array = [
	goblin_enemy
]
var enemy_x = 208
var enemy_y = 16
