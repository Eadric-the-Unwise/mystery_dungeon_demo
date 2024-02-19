extends State
class_name EnemyFollow

var player: Node2D
var enemy: Node2D

var CELL_SIZE := Autoload.grid_data.cell_size

func enter():
	print("Enemy following player!")
	
	player = get_tree().get_first_node_in_group("Player")
	enemy = get_node("../..")
	enemy.AreaExited.connect(_on_area_exited)
	randomize()
	
func update():
	var distance : Vector2 = player.position - enemy.position
	var current_coordinate : Vector2i = enemy.position / CELL_SIZE
	var direction : Vector2i = sign(distance)
	var target_coordinate : Vector2i = current_coordinate + direction
	print("Target Coordinate = ", target_coordinate)
	var player_coordinates : Vector2i
	player_coordinates.x = int(player.position.x / CELL_SIZE.x)
	player_coordinates.y = int(player.position.y / CELL_SIZE.y)
	if target_coordinate == player_coordinates:
		print("Cannot collide with player")
		return
		
	if Autoload.grid_data.is_point_solid(target_coordinate):
		print("Point is solid!")
		return
		
	#enemy.position.x = (target_coordinate.x * CELL_SIZE.x)
	#enemy.position.y = (target_coordinate.y * CELL_SIZE.y)
	# Check if player is diagonal
	if player_coordinates.x != current_coordinate.x && player_coordinates.y != current_coordinate.y:
			var random_value = randi() % 2
			if random_value == 0:
				# check here if point is solid!
				enemy.position.x = target_coordinate.x * CELL_SIZE.x
			elif random_value == 1:
				enemy.position.y = target_coordinate.y * CELL_SIZE.y
	#elif player.position.x != enemy.position.x:
		#enemy.position.x = target_coordinate.x * CELL_SIZE.x
	#else:
		#enemy.position.y = target_coordinate.y * CELL_SIZE.y
	
	#else:
		#enemy.position = target_position
	
func _on_area_exited():
	Transitioned.emit(self, "EnemyIdle")
	
func _on_player_moved():
	enemy.position.x = player.position.x - 16
	#target_pos = player.position
