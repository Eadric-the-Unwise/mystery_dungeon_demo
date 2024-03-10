extends State
class_name EnemyFollow

@onready var animation_player = $"../../AnimationPlayer"

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var enemy: Node2D = $"../.."
@onready var raycasts = $"../../Raycasts"
# Detects if player is trying to move while in the combat "danger zone" of enemy attacks
# If in "danger zone", player will be attacked by Enemy via Attack of Opportunity
@onready var combat_area = $"../../CombatArea"
# Enemy's current coordinate


func enter():
	print("Enemy following player!")
	enemy.current_enemy_coordinate = Autoload.tilemap.local_to_map(enemy.global_position)
	_flip_sprite()

func _process(delta):
	# Loop all RayCast2D's to see if the player is visible
	check_line_of_sight()

func check_line_of_sight():
	# RayCast. Sets is_in_line_of_sight to true if in line of sight
	# This can be updated later for possible 'hiding' mechanics. Currently, these 
	# are not used in EnemyFollow
	var raycast_target_position = player.global_position - enemy.global_position
	for raycast in raycasts.get_children():
		raycast.target_position = raycast_target_position
		# Determine Line of Sight
		if raycast.is_colliding():
			# Line of Sight is Blocked
			enemy.is_in_line_of_sight = false
		else:
			# Player is in Enemy's Line of Sight
			enemy.is_in_line_of_sight = true
		
func update(): # Called on every PlayerMovedSignal emit (state_machine.gd)
	# Find next target location in AStarGrid2D
	var _target_coordinate: Vector2i = _update_target_coordinate()
	# Enemy will hesistate to move if it means colliding with the player
	#if _target_coordinate == Autoload.current_grid_point:
		#print("Enemy can't collide with player. Enter combat!")
		#Transitioned.emit(self, "EnemyCombat")
		#return
	# Check if _target_coordinate is the blocked
	if Autoload.grid_data.is_point_solid(_target_coordinate):
		print("Point is solid!")
		return
	# CALLING THIS TWICE IS WEIRD, CAN WE FIX THIS?
	for shape in combat_area.get_children():
		var combat_area_grid_coord: Vector2i
		combat_area_grid_coord.x = int(shape.global_position.x / Autoload.grid_data.cell_size.x)
		combat_area_grid_coord.y = int(shape.global_position.y / Autoload.grid_data.cell_size.y)
		#
		if combat_area_grid_coord == Autoload.current_grid_point:
			print("I SEE YOU MOTHERFUCKER")
			Transitioned.emit(self, "EnemyCombat")
			return
	
	Autoload.grid_data.set_point_solid(enemy.current_enemy_coordinate, false)
		
	var tween = enemy.create_tween()
	# Tween Move Enemy position to target coordinate
	tween.tween_property(enemy, "position", Autoload.grid_data.get_point_position(_target_coordinate), .10)
	# Flip Enemy sprite, accordingly
	_flip_sprite()
	# Update current coordinate
	enemy.current_enemy_coordinate = _target_coordinate
	Autoload.grid_data.set_point_solid(enemy.current_enemy_coordinate, true)
	# After Enemy moves to tile, check to see if any of the Combat Area2D's are the same as the player's
	# current_grid_point
	await tween.finished
	
	# CALLING THIS TWICE IS WEIRD, CAN WE FIX THIS?
	for shape in combat_area.get_children():
		var combat_area_grid_coord: Vector2i
		combat_area_grid_coord.x = int(shape.global_position.x / Autoload.grid_data.cell_size.x)
		combat_area_grid_coord.y = int(shape.global_position.y / Autoload.grid_data.cell_size.y)
		#
		if combat_area_grid_coord == Autoload.current_grid_point:
			print("I SEE YOU MOTHERFUCKER")
			Transitioned.emit(self, "EnemyCombat")
			return
	#######################################################
	# COMBAT AREA CHECKS, UPDATE THIS COMMENT AND POSSIBLY TURN THIS INTO A FUNC LATER #
	# AWAIT: The for loop doesn't print correctly if called before tween is finished, will call
	# previous position, instead.
	
	#await tween.finished 
	#for shape in combat_area.get_children():
		#var combat_area_grid_coord: Vector2i
		#combat_area_grid_coord.x = int(shape.global_position.x / Autoload.grid_data.cell_size.x)
		#combat_area_grid_coord.y = int(shape.global_position.y / Autoload.grid_data.cell_size.y)
		#print(combat_area_grid_coord)
		
func _update_target_coordinate():
	var id_path: Array[Vector2i] 
	id_path = Autoload.grid_data.get_id_path(
	Autoload.tilemap.local_to_map(enemy.global_position),
	# slice(1) removes the first value in the id_path (enemy's current grid point)
	Autoload.tilemap.local_to_map(player.global_position)).slice(1)
	#_current_id_path = id_path
	return id_path.front()
	
func _flip_sprite():# Flip horizonal sprite
	if Autoload.current_grid_point.x > enemy.current_enemy_coordinate.x:
		#print("Target.x = " + str(_target_coordinate.x) + ", current.x = " + str(enemy.current_enemy_coordinate.x))
		enemy.sprite.flip_h = true
	else:
		enemy.sprite.flip_h = false
		
# --------------------------------------------------------------------------
	# LINE OF SIGHT ARRAY SHRINKING WHEN NOT IN LINE OF SIGHT LOGIC
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



