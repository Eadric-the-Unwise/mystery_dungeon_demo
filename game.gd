extends Node2D


@onready var player_coords: Label = $"CanvasLayer/Debug UI/Debug/Position =/Coords"
@onready var player_hp: Label = $"CanvasLayer/Game UI/HP/Health"
@onready var enemy_cursor := $EnemyCursor
@onready var message := $"CanvasLayer/Debug UI/Message"


#----------------------------------------------------------
@onready var button_damage := $Buttons/Damage
@onready var button_heal := $Buttons/Heal
###
@onready var button_reset := $Buttons/Reset
#----------------------------------------------------------
@onready var player := $Player

var enemy := preload("res://enemy.tscn")
# Full list of all RNG Spawnable Enemies
var spawnable_enemies: Array = [
		enemy
]
# All active enemies in game
var all_active_enemies: Array = []
# All enemies within melee combat distance of Player
var combat_enemies: Array = []
# Updated on selection during combat
var selected_enemy: Node2D
# remove this?
var _move_tween_timer: bool

func _ready() -> void:
	# Initialize the Autoload.tilemap TileMap
	Autoload.tilemap = $TileMap
	# Initialize astargrid2d data
	_init_astargrid2d()
	# Initialize enemies
	_init_enemies()
	# Initialize ui
	_update_ui()
	# Connect PlayerMovedSignal to _update_ui()
	Autoload.PlayerMovedSignal.connect(_update_ui)
	Autoload.EnemySlain.connect(_on_enemy_slain)
	# Reset move_timer to wait_time
	player.move_timer.timeout.connect(_reset_timer)
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
		# Check for tile for TileSet Custom Data
		if tile_data.get_custom_data("is_blocked"):
			# Sets this grid cell to be "solid", preventing player or enemies from moving into it
			Autoload.grid_data.set_point_solid(tile_coord, true)

	# Set _current_grid_point coordinates
	Autoload.current_grid_point.x = int(player.position.x / Autoload.grid_data.cell_size.x)
	Autoload.current_grid_point.y = int(player.position.y / Autoload.grid_data.cell_size.y)
	# Update player position to the position of _current_grid_point coordinate
	player.position = Autoload.grid_data.get_point_position(Autoload.current_grid_point)

func _init_enemies():
	var enemy_spawn_x = 48
	var enemy_spawn_y = 48
	for column in range(3):
		for i in range(3):
			var next_enemy = spawnable_enemies[0].instantiate()
			all_active_enemies.append(next_enemy)
			
			next_enemy.position.x = enemy_spawn_x
			next_enemy.position.y = enemy_spawn_y
			
			add_child(next_enemy)
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
			enemy_spawn_y += 16
		enemy_spawn_x += 16
		enemy_spawn_y = 48
	print(all_active_enemies.size(), " Enemies spawned")

func _on_enemy_entered_combat():
	pass
	#_update_combat_enemies()
			

func _select_check() -> void:
	# Attack if there is any enemy selected
	if combat_enemies:
		melee_attack()
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
			print("The door opened!")
			var target_cell: Vector2i = Autoload.tilemap.local_to_map(area.global_position)
			var tile_data = Autoload.tilemap.get_cell_tile_data(0, target_cell)
			if tile_data.get_custom_data("is_blocked"):
				Autoload.grid_data.set_point_solid(target_cell, false)
			# set the atlas tile in place of the door
			# 5 is source id ???
			# Vector21(1,0) is the Atlas coords	
			Autoload.tilemap.set_cell(0, target_cell, 5, Vector2i(1,0))

func _move_to_coord(move_direction: Vector2i) -> void:
	var target_grid_point = Autoload.current_grid_point + move_direction
	# If there is an enemy within melee_combat range on this tile, select the enemy instead of moving
	if is_in_combat(target_grid_point):
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
	Autoload.PlayerMovedSignal.emit()
	# Confirms when the player has finished animating to his position
	# If player lands in combat distance, the enemy will enter combat instead
	# of moving.
	tween.finished.connect(_on_tween_finished)
	
	
func _on_tween_finished():
	# After moving, check surrounding to see if Enemy is in combat range
	# (Consider moving this logic to Player.gd)
	#_reset_cursor()
	#combat_enemies.clear()
	_update_combat_enemies()
			
func is_in_combat(target_grid_point: Vector2i):
	for e in combat_enemies:
		if e.current_enemy_coordinate == target_grid_point:
			enemy_cursor.global_position = e.global_position
			selected_enemy = e
			return true
	return false
# connect enemy death signal to this function
# combat_enemies.remove(target_enemy)
func _on_enemy_slain():
	print("THE ENEMY HAS BEEN SLAIN")
	await player.animation_player.animation_finished
	#############################
	_update_combat_enemies()
	################################

func _update_combat_enemies():
	_reset_cursor()
	combat_enemies.clear()
	for area in player.interactable_detection_area.get_overlapping_areas():
		if area is EnemyBody:
			var target_enemy = area.get_parent()
			combat_enemies.append(target_enemy)
			enemy_cursor.global_position = target_enemy.global_position
			enemy_cursor.animation_player.play("CursorBlink")
			# Store the index of the enemy in combat_enemies[]
			selected_enemy = target_enemy
	print(combat_enemies.size())		
	
	

func _reset_cursor():
	enemy_cursor.animation_player.stop()
	enemy_cursor.global_position = enemy_cursor.reset_position

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
