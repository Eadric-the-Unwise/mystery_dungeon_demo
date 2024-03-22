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
func exit():
	#print("Exiting Follow Mode")
	pass
	
func _ready():
	pass
	#Autoload.RoomExited.connect(_on_room_exited)

#func _on_room_exited():
	#enemy.queue_free()
	#Transitioned.emit(self, "EnemyIdle")

func _process(_delta):
	# Loop all RayCast2D's to see if the player is visible
	check_line_of_sight()
	#_check_for_combat()

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
	
		##################################################################
	## CHECK ONCE PRIOR TO MOVING
	if _check_for_combat():
		# Prevent Enemy from moving, go to combat State
		return
	################################################################
	# Check if _target_coordinate is the blocked
	if Autoload.grid_data.is_point_solid(_target_coordinate):
		#print("Point is solid!")
		return
	# Flip Enemy sprite, accordingly
	_flip_sprite()
	# Clear current tile for movement
	Autoload.grid_data.set_point_solid(enemy.current_enemy_coordinate, false)
	var tween = enemy.create_tween()
	# Tween Move Enemy position to target coordinate
	tween.tween_property(enemy, "position", Autoload.grid_data.get_point_position(_target_coordinate), .10)
	# Update current coordinate
	enemy.current_enemy_coordinate = _target_coordinate
	# You MUST set this to solid prior to tween animation completing because there are multiple enemies
	# that are loaded sequentially and need to see if the space is solid or blocked
	Autoload.grid_data.set_point_solid(_target_coordinate, true)
	##################################################################
	# After Enemy moves to tile, check to see if any of the Combat Area2D's are the same as the player's
	# current_grid_point
	# CHECK A SECOND TIME 
	tween.finished.connect(_on_tween_finished)
	################################################################
	
func _on_tween_finished():
	_check_for_combat()
	
func _check_for_combat():
	for shape in combat_area.get_children():
		var combat_area_grid_coord: Vector2i
		combat_area_grid_coord.x = int(shape.global_position.x / Autoload.grid_data.cell_size.x)
		combat_area_grid_coord.y = int(shape.global_position.y / Autoload.grid_data.cell_size.y)
		#
		if combat_area_grid_coord == Autoload.current_grid_point:
			#print("Transition to combat")
			Transitioned.emit(self, "EnemyCombat")
			return true
			
		
func _update_target_coordinate():
	var id_path: Array[Vector2i] 
	#var local_enemy_position = enemy.to_local(enemy.global_position)
	#var local_player_position = player.to_local(player.global_position)
	id_path = Autoload.grid_data.get_id_path(
	enemy.current_enemy_coordinate,
	Autoload.tilemap.local_to_map(player.global_position))
	#print(id_path)
	# if no open AStarGrid2D path, stand still
	if id_path.size() <= 1:
		# stand in place
		#print("Nowhere to Enemy to go")
		return enemy.current_enemy_coordinate
	else:
		# Slice(1) removes id_path[0], and returns id_path[1] thru end of array 
		# id_path[0] = (enemy's current standing grid point)
		id_path = id_path.slice(1)
	# .front() returns an error if the array is nill	
	return id_path.front()
	
func _flip_sprite():# Flip horizonal sprite
	if Autoload.current_grid_point.x > enemy.current_enemy_coordinate.x:
		#print("Target.x = " + str(_target_coordinate.x) + ", current.x = " + str(enemy.current_enemy_coordinate.x))
		enemy.sprite.flip_h = true
	else:
		enemy.sprite.flip_h = false
		




