extends State
class_name EnemyFollow

var player: Node2D
var enemy: Node2D

var target_coordinate: Vector2i

var CELL_SIZE := Autoload.grid_data.cell_size

func enter():
	print("Enemy following player!")
	
	player = get_tree().get_first_node_in_group("Player")
	enemy = get_node("../..")
	enemy.AreaExited.connect(_on_area_exited)
	randomize()
	
func update():

	if target_coordinate == Autoload.current_grid_point:
		print("Cannot collide with player")
		return
		
	if Autoload.grid_data.is_point_solid(target_coordinate):
		print("Point is solid!")
		return
	
	#enemy.current_grid_point.x = int(enemy.position.x / Autoload.grid_data.cell_size.x)
	#enemy.current_grid_point.y = int(enemy.position.y / Autoload.grid_data.cell_size.y)
	print("Enemy Target Grid Point = ",target_coordinate)
	
func _on_area_exited():
	Transitioned.emit(self, "EnemyIdle")
	
func _on_player_moved():
	enemy.position.x = player.position.x - 16
	#target_pos = player.position
