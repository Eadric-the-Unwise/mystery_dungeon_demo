extends State
class_name EnemyFollow

@onready var animation_player = $"../../AnimationPlayer"
@onready var sprite = $"../../EnemySprite2D"

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var enemy: Node2D = $"../.."

@onready var raycast = $"../../RayCast2D"

#var current_grid_point: Vector2i
var _current_id_path: Array[Vector2i]
var _target_coordinate: Vector2i
var current_enemy_coordinate: Vector2i

func enter():
	print("Enemy following player!")
	animation_player.play("Surprised")
	enemy.AreaExited.connect(_on_area_exited)
	current_enemy_coordinate = Autoload.tilemap.local_to_map(enemy.global_position)
	#randomize()

func _process(delta):
	# Calculate Racyast
	var target_position = player.global_position - enemy.global_position
	raycast.target_position = target_position
	# Determine Line of Sight
	if raycast.is_colliding():
		# Line of Sight is Blocked
		enemy.is_in_line_of_sight = false
	else:
		# Player is in Enemy's Line of Sight
		enemy.is_in_line_of_sight = true
		
func update(): # Called on every PlayerMovedSignal emit (state_machine.gd)
	# Find next target location in AStarGrid2D
	_update_target_coordinate()
	# Check if _target_coordinate is the Player's coordinate
	if _target_coordinate == Autoload.current_grid_point:
		print("Cannot collide with player")
		return
	# Check if _target_coordinate is the blocked
	if Autoload.grid_data.is_point_solid(_target_coordinate):
		print("Point is solid!")
		return
	# set Enemy position to target coordinate
	enemy.position = Autoload.grid_data.get_point_position(_target_coordinate)
	# Flip Enemy sprite
	_flip_sprite()
	# Update current coordinate
	current_enemy_coordinate = _target_coordinate
	
func _update_target_coordinate():
	var id_path: Array[Vector2i] 
	if enemy.is_in_line_of_sight:
		id_path = Autoload.grid_data.get_id_path(
		Autoload.tilemap.local_to_map(enemy.global_position),
		# slice(1) removes the first value in the id_path (enemy's current grid point)
		Autoload.tilemap.local_to_map(player.global_position)).slice(1)
	else:
		# Remove the first value in array if player is out of line of sight
		id_path = _current_id_path.slice(1)
	
	if id_path.is_empty() == false:
		# Set the current coordinate path
		_current_id_path = id_path
		# Set the EnemyFollow.target_coordinate to the first coordinate in the ID path
		_target_coordinate = _current_id_path.front()
		print("Current ID Path Size: ",_current_id_path.size())
		print(_current_id_path)		
	else:
		animation_player.play("Confused")
		Transitioned.emit(self, "EnemyIdle")

func _flip_sprite():# Flip horizonal sprite
	if Autoload.current_grid_point.x > current_enemy_coordinate.x:
		print("Target.x = " + str(_target_coordinate.x) + ", current.x = " + str(current_enemy_coordinate.x))
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _on_area_exited():
	pass
	#if animation_player.is_playing():
		#animation_player.stop()
	#animation_player.play("Confused")
	#Transitioned.emit(self, "EnemyIdle")
