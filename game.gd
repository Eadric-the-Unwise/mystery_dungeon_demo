extends Node2D

@onready var player_coords: Label = $"CanvasLayer/Debug UI/Debug/Position =/Coords"
@onready var player_hp: Label = $"CanvasLayer/Game UI/HP/Health"
@onready var enemy_cursor := $EnemyCursor
@onready var message := $"CanvasLayer/Debug UI/Message"
@onready var enemy_container = $EnemyContainer

#----------------------------------------------------------
@onready var button_damage := $Buttons/Damage
@onready var button_heal := $Buttons/Heal
###
@onready var button_reset := $Buttons/Reset
#----------------------------------------------------------
@onready var player := $Player
#-----------------------------------------------------------
@onready var rooms_handler = $"Rooms Handler"
@onready var b_1 = $"Rooms Handler/B1"
@onready var b_2 = $"Rooms Handler/B2"

# All enemies within melee combat distance of Player
var combat_enemies: Array = []
# Updated on selection during combat
var selected_enemy: Node2D
# remove this?
var _move_tween_timer: bool

func _ready() -> void:
	# Currently only randomizing the init_enemies func
	randomize()
	# Initialize the Autoload.tilemap TileMap
	Autoload.tilemap = $TileMap
	# Initialize astargrid2d data
	_init_astargrid2d()
	# Initialize enemies
	_init_enemies()
	# Initialize ui
	_update_ui()
	# Connect PlayerActionTaken to _update_ui()
	Autoload.PlayerActionTaken.connect(_update_ui)
	# Reset move_timer to wait_time
	player.move_timer.timeout.connect(_reset_timer)
	player.cursor_timer.timeout.connect(_on_cursor_timer_timeout)
	#-----------------------------------------------------------#
	# Temporary UI
	message.text = "Welcome to the game!"
	# Deal player damage
	button_damage.pressed.connect(_deal_damage.bind(2))
	# Heal player
	button_heal.pressed.connect(_heal_player.bind(4))
	# Reset current scene
	button_reset.pressed.connect(_reset_game)

func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		_combat_check()
	if Input.is_action_just_pressed("ui_accept"):
		_select_check()
	# Prevent player from moving until at .25 sec from previous movement input	
	if _move_tween_timer:
		return
	if player.animation_player.is_playing():
		return
	if Input.is_action_pressed("move_up"):
		_move_to_coord(Vector2i.UP)
	elif Input.is_action_pressed("move_down"):
		_move_to_coord(Vector2i.DOWN)
	elif Input.is_action_pressed("move_left"):
		_move_to_coord(Vector2i.LEFT)
		player.sprite.flip_h = true
	elif Input.is_action_pressed("move_right"):
		_move_to_coord(Vector2i.RIGHT)
		player.sprite.flip_h = false

func melee_attack():
	## Return if no current enemies
	if combat_enemies.is_empty():
		return
	if player.animation_player.is_playing():
		return
	if selected_enemy.animation_player.is_playing() == false:
		if selected_enemy.global_position.x > player.global_position.x:
			print("Attack Right!!!!!!!!!!!!!!")
			player.animation_player.play("AttackRight")
		elif selected_enemy.global_position.x < player.global_position.x:
			player.animation_player.play("AttackLeft")
		elif selected_enemy.global_position.y < player.global_position.y:
			player.animation_player.play("AttackUp")
		else:
			player.animation_player.play("AttackDown")

func _init_astargrid2d():
	# Initialize tilemap 2D array
	Autoload.grid_data = AStarGrid2D.new()
	# Define tilemap region
	Autoload.grid_data.region = Autoload.tilemap.get_used_rect()
	# Define tileset cell size
	Autoload.grid_data.cell_size = Autoload.tilemap.tile_set.tile_size
	# Prevents diagonal pathfinding
	Autoload.grid_data.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	# Needs to be called if parameters like region, cell_size or offset are changed
	# (is_dirty() will return true if this is the case and this needs to be called)
	Autoload.grid_data.update()
	
	
	# get_used_cells(0) = TileMap Layer 0
	for tile_coord in Autoload.tilemap.get_used_cells(0):
		# Get tile coordinate
		var tile_data = Autoload.tilemap.get_cell_tile_data(0, tile_coord)
		# Check for TileMap/Tileset Custom Data
		if tile_data.get_custom_data("is_blocked"):
			# Sets this grid cell to be "solid", preventing player or enemies from moving into it
			Autoload.grid_data.set_point_solid(tile_coord, true)

	# Set _current_grid_point coordinates
	Autoload.current_grid_point.x = int(player.position.x / Autoload.grid_data.cell_size.x)
	Autoload.current_grid_point.y = int(player.position.y / Autoload.grid_data.cell_size.y)
	# Update player position to the position of _current_grid_point coordinate
	player.position = Autoload.grid_data.get_point_position(Autoload.current_grid_point)

func _init_enemies():
	#Spawn enemies based on room.room_enemies arrays define in each room script
	for room in rooms_handler.get_children():
		for enemy in room.spawn_enemies:
			var next_enemy = enemy.instantiate()
			next_enemy.position = _randomize_enemy_spawn(room)
			
			next_enemy.active = false
			Autoload.all_active_enemies.append(next_enemy)
			room.room_enemies.append(next_enemy)
			# Placed inside of EnemyContainer in order to control Sprite draw order
			# (enemy cursors etc)
			enemy_container.add_child(next_enemy)

			#####
			next_enemy.EnemyEnteredCombat.connect(_on_enemy_entered_combat)
			next_enemy.EnemyExitedCombat.connect(_on_enemy_exited_combat)
			next_enemy.EnemySlain.connect(_on_enemy_slain)
			#####
			next_enemy.current_enemy_coordinate = next_enemy.position / Autoload.grid_data.cell_size
			# set spawn location to solid, preventing other NPC's from entering this space
			# during AStarGrid2D path calculations
			Autoload.grid_data.set_point_solid(next_enemy.current_enemy_coordinate, true)
			#print(next_enemy.current_enemy_coordinate)D
			# Flip enemy sprite
			if next_enemy.position.x >= player.position.x:
				next_enemy.sprite.flip_h = true
			else:
				next_enemy.sprite.flip_h = false
	# Print all enemies generated at init
	print(Autoload.all_active_enemies.size(), " Enemies spawned")

# Randomize Enemy Spawn based on Spawn Map TileMap for current room
func _randomize_enemy_spawn(Room: Area2D):
	# Get all spawn tiles in the spawn_map
	var spawn_tiles: Array = Room.spawn_map.get_used_cells(0)
	# Calculate spawn tile size
	var tile_size: Vector2i = Room.spawn_map.tile_set.tile_size
	# Calculate the amount of tiles
	var tile_count: int = spawn_tiles.size()
	# Randomized int to help determine which tile to spawn on
	# Subtract 1 because array
	var random_int: int = randi_range(0, tile_count - 1)
	# Create local grid coords for selected tile
	var random_tile_pos: Vector2i = Room.spawn_map.map_to_local(spawn_tiles[random_int])
	# Convert local grid coords to global coords
	# Random Tile's .x and .y are subtracted by tile_size/2 (they default to the center of the tile)
	# If you would like to change this, you can Center the Enemy's Sprite node, but you will have to
	# update the movement logic of the Enemy. Keep at top left for now... 
	var spawn_pos: Vector2i = Room.spawn_map.to_global(random_tile_pos - (tile_size / 2))
	# --- ERASING THE CELL --- 
	# Convert the random_tile's position to grid coordinates
	var random_tile_grid_coordinates = random_tile_pos / tile_size
	# Erase the spawn cell 
	# Setting the source_id to -1 erases the cell
	Room.spawn_map.set_cell(0, random_tile_grid_coordinates, -1)
	return spawn_pos

func _combat_check() -> void:
	# Attack if there is any enemy selected
	if combat_enemies:
		melee_attack()
		return
func _select_check():
	if combat_enemies:
		#Exit function if there are enemies attacking player (must attack)
		return
	# Check for all overlapping areas in Player's Area2D (interactable_detection_area)
	for area in player.teleport_detection_area.get_overlapping_areas():
		if area is Teleporter:
			# Returns the map coordinates of the cell containing the given local_position. 
			var target_coord = Autoload.tilemap.local_to_map(area.target_teleporter.global_position)
			# Update player position to the position of target_coord 
			player.position = Autoload.grid_data.get_point_position(target_coord)
			# Update _current_grid_point coordinates
			Autoload.current_grid_point = target_coord
	
	for area in player.interactable_detection_area.get_overlapping_areas():
		if area is Door:
			#print("The door opened!")
			var target_cell: Vector2i = Autoload.tilemap.local_to_map(area.global_position)
			var tile_data = Autoload.tilemap.get_cell_tile_data(0, target_cell)
			if tile_data.get_custom_data("is_blocked"):
				Autoload.grid_data.set_point_solid(target_cell, false)
			# set the atlas tile in place of the door
			# 5 is source id ???
			# USE GET SOURCE ID INSTEAD OF HARD CODED VALUES IN CASE THEY UPDATE
			# ...AUTIOMATICALLY OVER TIME
			# Vector21(1,0) is the Atlas coords	
			Autoload.tilemap.set_cell(0, target_cell, 5, Vector2i(1,0))
func _move_to_coord(move_direction: Vector2i) -> void:
	var target_grid_point = Autoload.current_grid_point + move_direction
	# If there is an enemy within melee_combat range on this tile, select the enemy instead of moving
	if _is_in_combat_range(target_grid_point):
		return
	# If target_grid_point is an "is_blocked" tile, prevent movement
	if Autoload.grid_data.is_point_solid(target_grid_point):
		return
	_move_tween_timer = true
	# Clear current tile for movement
	Autoload.grid_data.set_point_solid(Autoload.current_grid_point, false)
	# Update current tile to the target grid point
	Autoload.current_grid_point = target_grid_point
	# Set position of the target grid point
	var target_position = Autoload.grid_data.get_point_position(target_grid_point)
	# Prevent enemies from entering your target grid point
	Autoload.grid_data.set_point_solid(target_grid_point, true)
	var tween = player.create_tween()
	tween.tween_property(player, "position", target_position, .10)
	#player.position = target_position
	# Prevents player from moving every in-game frame
	# Start move_timer (player cannot move again until timer = timeout())
	player.move_timer.start()
	# emit signal
	Autoload.PlayerActionTaken.emit()
	# Confirms when the player has finished animating to his position
	# If player lands in combat distance, the enemy will enter combat instead
	# of moving.
	tween.finished.connect(_on_tween_finished)
	
func _on_tween_finished():
	player.cursor_timer.start()
	#_update_cursor()
	#enemy_cursor.animation_player.play("CursorBlink")
	pass
	# After moving, check surrounding to see if Enemy is in combat range
	# (Consider moving this logic to Player.gd)
	#_update_combat_enemies()
	
func _on_enemy_entered_combat(entered_enemy: Node2D):
	# Clear the current combat_enemies[] Array2D
	#combat_enemies.clear()
	combat_enemies.append(entered_enemy)
	selected_enemy = entered_enemy
	#_update_cursor()
	print("Enemies in Combat: ",combat_enemies.size())	
	
func _on_enemy_exited_combat(exited_enemy: Node2D):
	_reset_cursor()
	combat_enemies.erase(exited_enemy)
	print(combat_enemies.size())	

func _on_enemy_slain(slain_enemy: Node2D):
	print("THE ENEMY HAS BEEN SLAIN")
	_reset_cursor()
	await player.animation_player.animation_finished
	#############################
	combat_enemies.erase(slain_enemy)
	#all_active_enemies.erase(slain_enemy)
	
	rooms_handler.current_room.room_enemies.erase(slain_enemy)
	# If there are enemies remaining
	# UPDATE THIS TO BE BETTER
	if combat_enemies:
		selected_enemy = combat_enemies[0]
	_update_cursor()
	print(combat_enemies.size())
	################################
	
func _is_in_combat_range(target_grid_point: Vector2i):
	var old_enemy = selected_enemy
	for e in combat_enemies:
		if e.current_enemy_coordinate == target_grid_point:
			enemy_cursor.global_position = e.global_position
			selected_enemy = e
			# Simply used to print the name of the Selected Enemy ONCE
			if old_enemy != selected_enemy:
				print("Selected Enemy = ", "combat_enemies[",combat_enemies.find(selected_enemy),"]")
			return true
	return false

func _update_cursor():
	if combat_enemies:
		enemy_cursor.global_position = selected_enemy.global_position
		enemy_cursor.animation_player.play("CursorBlink")

func _reset_cursor():
	enemy_cursor.animation_player.stop()
	enemy_cursor.global_position = enemy_cursor.reset_position

func _on_cursor_timer_timeout():
	
	_update_cursor()
	#player.cursor_timer.wait_time ...
# ---------------------------------------------------------------------------------
func _update_ui():
	player_coords.text = str(player.position / Autoload.grid_data.cell_size)
	player_hp.text = str(player.health)	

func _reset_timer():
	_move_tween_timer = false
	
func _reset_game():
	get_tree().reload_current_scene()
	message.text = "Game Reset"
	_update_ui()
	
func _heal_player(heal: int):
	player.health += heal
	message.text = "Player healed by " + str(heal) + "!"
	_update_ui()

func _deal_damage(damage: int):
	player.health -= damage
	message.text = "Player took " + str(damage) + " damage!"
	_update_ui()
