extends State
class_name EnemyIdle

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var enemy: Node2D = $"../.."

@onready var raycast = $"../../RayCast2D"

func enter():
	print("Enemy now idle")
	print(get_parent().current_state)
	enemy.AreaEntered.connect(_on_area_entered)
	
func _process(delta):
	# RayCast
	var raycast_target_position = player.global_position - enemy.global_position
	raycast.target_position = raycast_target_position

func update():
	pass
	#print("Enemy Idle State")

func _on_area_entered():
	if !player.is_in_range:
		player.is_in_range = true
	#if raycast.is_colliding():
		#return
	Transitioned.emit(self, "EnemyFollow")

