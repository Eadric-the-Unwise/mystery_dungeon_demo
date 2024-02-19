extends State
class_name EnemyFollow

var player: Node2D
var enemy: Node2D

func enter():
	player = get_tree().get_first_node_in_group("Player")
	enemy = get_node("../..")
	
	print("Now following player!")
	
	
func physics_update(delta: float):
	enemy.position.x = player.position.x - 16
	
