extends State
class_name EnemyFollow

@onready var animation_player = $"../../AnimationPlayer"
@onready var sprite = $"../../EnemySprite2D"

var player: Node2D
var enemy: Node2D

#var current_grid_point: Vector2i
var current_id_path: Array[Vector2i]
var _target_coordinate: Vector2i
var current_enemy_coordinate: Vector2i

func enter():
	print("Enemy following player!")
	animation_player.play("Surprised")
	player = get_tree().get_first_node_in_group("Player")
	enemy = get_node("../..")
	enemy.AreaExited.connect(_on_area_exited)
	current_enemy_coordinate = Autoload.tilemap.local_to_map(enemy.global_position)
	#randomize()

# Called on every PlayerMovedSignal emit (state_machine.gd)
func update():
	_update_target_coordinate()
	if _target_coordinate == Autoload.current_grid_point:
		print("Cannot collide with player")
		return
		
	if Autoload.grid_data.is_point_solid(_target_coordinate):
		print("Point is solid!")
		return
	
	var target_position = Autoload.grid_data.get_point_position(_target_coordinate)
	enemy.position = target_position
	# Flip horizonal sprite
	if Autoload.current_grid_point.x > current_enemy_coordinate.x:
		print("Target.x = " + str(_target_coordinate.x) + ", current.x = " + str(current_enemy_coordinate.x))
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	# Update current coordinate
	current_enemy_coordinate = _target_coordinate
	print("Enemy Coord = ", current_enemy_coordinate)
	
func _update_target_coordinate():
	#if event.is_action_pressed("move") == false:
		#return
	
	# slice(1) removes the first value in the id_path (enemy's current grid point)
	var id_path = Autoload.grid_data.get_id_path(
		Autoload.tilemap.local_to_map(enemy.global_position),
		Autoload.tilemap.local_to_map(player.global_position)
	).slice(1)
	print(id_path)		
	
	if id_path.is_empty() == false:
		current_id_path = id_path
		# Set the EnemyFollow.target_coordinate to the first coordinate int he ID path
		_target_coordinate = current_id_path.front()

func _on_area_exited():
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("Confused")
	Transitioned.emit(self, "EnemyIdle")
