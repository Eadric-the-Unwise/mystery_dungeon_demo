extends Room
#-----------------------------------------
var goblin_enemy := preload("res://enemy.tscn")
# Add an array for enemies for this room
var room_enemies: Array = [
	goblin_enemy, goblin_enemy
]
var enemy_x = 16
var enemy_y = 320
