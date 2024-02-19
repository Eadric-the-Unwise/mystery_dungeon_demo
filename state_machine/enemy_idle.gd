extends State
class_name EnemyIdle

var player: Node2D
var enemy: Area2D

func enter():
	player = get_tree().get_first_node_in_group("Player")

func update(_delta: float):
	pass
	#print("Enemy Idle State")

