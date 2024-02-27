extends State
class_name EnemyIdle

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var enemy: Node2D = $"../.."
@onready var raycast = $"../../RayCast2D"


func enter():
	print("Enemy now idle")
	enemy.AreaEntered.connect(_on_area_entered)
	enemy.AreaExited.connect(_on_area_exited)

func _process(delta):
	# RayCast
	var raycast_target_position = player.global_position - enemy.global_position
	raycast.target_position = raycast_target_position
	# Determine Line of Sight
	if raycast.is_colliding():
		# Line of Sight is Blocked
		enemy._is_in_line_of_sight = false
	else:
		# Player is in Enemy's Line of Sight
		enemy._is_in_line_of_sight = true
		
	# Check if enemy is both in range of the Player and if the Player's Line of Sight isn't blocked
	# by any wall or object
	if enemy._is_in_range && enemy._is_in_line_of_sight:
		# Transition to Follow State
		Transitioned.emit(self, "EnemyFollow")
func update():
	pass

func _on_area_entered():
	# Enemy is in range of Player
	if !enemy._is_in_range:
		enemy._is_in_range = true
	print("Player in range!")

func _on_area_exited():
	# Enemy is out of range of Player
	if enemy._is_in_range:
		enemy._is_in_range = false
	print("Player OUT OF RANGE")

