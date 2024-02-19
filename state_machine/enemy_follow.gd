extends State
class_name EnemyFollow

var player: Node2D
var enemy: Node2D

var CELL_SIZE := 16

func enter():
	print("Enemy following player!")
	
	player = get_tree().get_first_node_in_group("Player")
	enemy = get_node("../..")
	enemy.AreaExited.connect(_on_area_exited)
	randomize()
	
func update():
	var distance : Vector2 = player.position - enemy.position
	var target_position : Vector2 = enemy.position + (sign(distance) * CELL_SIZE)
	var target_coordinate : Vector2i = target_position / CELL_SIZE
	print("Target Coordinate = ", target_coordinate)
	if target_position == player.position:
		return
		
	if Autoload.grid_data.is_point_solid(target_coordinate):
		print("Point is solid!")
		return
		
	if player.position.x != enemy.position.x && player.position.y != enemy.position.y:
			var random_value = randi() % 2
			if random_value == 0:
				enemy.position.x = target_position.x
			elif random_value == 1:
				enemy.position.y = target_position.y
	elif player.position.x != enemy.position.x:
		enemy.position.x = target_position.x
	else:
		enemy.position.y = target_position.y
	
	print("Enemy Position = " + str(enemy.position))
	#else:
		#enemy.position = target_position
	
func _on_area_exited():
	Transitioned.emit(self, "EnemyIdle")
	
func _on_player_moved():
	enemy.position.x = player.position.x - 16
	#target_pos = player.position
