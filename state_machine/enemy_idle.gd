extends State
class_name EnemyIdle

var enemy: Node2D

func enter():
	print("Enemy now idle")
	print(get_parent().current_state)
	enemy = get_node("../..")
	enemy.AreaEntered.connect(_on_area_entered)

func update():
	pass
	#print("Enemy Idle State")

func _on_area_entered():
	Transitioned.emit(self, "EnemyFollow")
