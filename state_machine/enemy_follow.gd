extends State
class_name EnemyFollow

@onready var animation_player = $"../../AnimationPlayer"

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var enemy: Node2D = $"../.."
@onready var raycasts = $"../../Raycasts"

#var current_grid_point: Vector2i
var _current_id_path: Array[Vector2i]
var _target_coordinate: Vector2i
var current_enemy_coordinate: Vector2i

func enter():
	print("Enemy following player!")
	animation_player.play("Surprised")
	enemy.AreaExited.connect(_on_area_exited)
	current_enemy_coordinate = Autoload.tilemap.local_to_map(enemy.global_position)
	_flip_sprite()
	#randomize()

func _process(delta):
	# Loop all RayCast2D's to see if the player is visible
	if check_line_of_sight():
		enemy.is_in_line_of_sight = true
	else:
		enemy.is_in_line_of_sight = false
		
	if Input.is_action_just_pressed("ui_select"):
		Transitioned.emit(self, "EnemyCombat")

func check_line_of_sight():
	# RayCast
	# Return true if in line of sight
	var raycast_target_position = player.global_position - enemy.global_position
	for raycast in raycasts.get_children():
		raycast.target_position = raycast_target_position
		# Determine Line of Sight
		if raycast.is_colliding():
			pass
			## Line of Sight is Blocked
			#enemy.is_in_line_of_sight = false
		else:
			## Player is in Enemy's Line of Sight
			#enemy.is_in_line_of_sight = true
			return true
		
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
	
	var tween = enemy.create_tween()
	# set Enemy position to target coordinate
	tween.tween_property(enemy, "position", Autoload.grid_data.get_point_position(_target_coordinate), .10)
	#enemy.position = Autoload.grid_data.get_point_position(_target_coordinate)
	# Flip Enemy sprite
	_flip_sprite()
	# Update current coordinate
	current_enemy_coordinate = _target_coordinate
	
func _update_target_coordinate():
	var id_path: Array[Vector2i] 
	id_path = Autoload.grid_data.get_id_path(
	Autoload.tilemap.local_to_map(enemy.global_position),
		# slice(1) removes the first value in the id_path (enemy's current grid point)
	Autoload.tilemap.local_to_map(player.global_position)).slice(1)
	_current_id_path = id_path
	_target_coordinate = _current_id_path.front()
	
	# LINE OF SIGHT ARRAY SHRINK LOGIC
	# --------------------------------------------------------------------------
	#if enemy.is_in_line_of_sight:
		#id_path = Autoload.grid_data.get_id_path(
		#Autoload.tilemap.local_to_map(enemy.global_position),
		## slice(1) removes the first value in the id_path (enemy's current grid point)
		#Autoload.tilemap.local_to_map(player.global_position)).slice(1)
	#else:
		## Remove the first value in array if player is out of line of sight
		#id_path = _current_id_path.slice(1)
	
	#if id_path.is_empty() == false:
		## Set the current coordinate path
		#_current_id_path = id_path
		## Set the EnemyFollow.target_coordinate to the first coordinate in the ID path
		#_target_coordinate = _current_id_path.front()
		#print("Current ID Path Size: ",_current_id_path.size())
		#print(_current_id_path)		
	#else:
		#animation_player.play("Confused")
		#Transitioned.emit(self, "EnemyIdle")

func _flip_sprite():# Flip horizonal sprite
	if Autoload.current_grid_point.x > current_enemy_coordinate.x:
		print("Target.x = " + str(_target_coordinate.x) + ", current.x = " + str(current_enemy_coordinate.x))
		enemy.sprite.flip_h = true
	else:
		enemy.sprite.flip_h = false

func _on_area_exited():
	pass
	#if animation_player.is_playing():
		#animation_player.stop()
	#animation_player.play("Confused")
	#Transitioned.emit(self, "EnemyIdle")
