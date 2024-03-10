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

var _is_moving: bool

func _ready() -> void:
	# Initialize the Autoload.tilemap TileMap
	Autoload.tilemap = $TileMap
	# initialize astargrid2d data
	_init_astargrid2d()
	# initialize enemies
	_init_enemies()
	# initialize ui
	_update_ui()
	# connect PlayerMovedSignal to _update_ui()
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
	if Input.is_action_just_pressed("ui_accept"):
		_select_check()
	
	# Add checks for UP/DOWN/LEFT/RIGHT Attack Animations
	# Begin with just LEFT/RIGHT	
	if Input.is_action_just_pressed("attack"):
		attack()
		
	if _is_moving:
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

func attack():
	## Return if no current enemies
	#print(combat_enemies.size())
	#return
	if combat_enemies.is_empty():
		return
	
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
	
	for i in range(2):
		var next_enemy = spawnable_enemies[0].instantiate()
		all_active_enemies.append(next_enemy)
		if all_active_enemies.size() == 1:
			next_enemy.position.x = 112 
			next_enemy.position.y = 16 
		else:
			next_enemy.position.x = all_active_enemies[i - 1].position.x
			next_enemy.position.y = all_active_enemies[i - 1].position.y + 16
		add_child(next_enemy)
		# Flip enemy sprite
		if next_enemy.position.x >= player.position.x:
			next_enemy.sprite.flip_h = true
		else:
			next_enemy.sprite.flip_h = false
	print(all_active_enemies.size(), " Enemies spawned")

func _select_check() -> void:
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
	# If target_grid_point is an "is_blocked" tile, prevent movement
	if Autoload.grid_data.is_point_solid(target_grid_point):
		return

	Autoload.current_grid_point = target_grid_point
	var target_position = Autoload.grid_data.get_point_position(target_grid_point)
	var tween = player.create_tween()
	tween.tween_property(player, "position", target_position, .10)
	#player.position = target_position
	# Prevents player from moving every in-game frame
	_is_moving = true
	# Start move_timer (player cannot move again until timer = timeout())
	player.move_timer.start()
	# Confirms when the player has finished animating to his position
	# If player lands in combat distance, the enemy will enter combat instead
	# of moving.
	tween.finished.connect(_on_tween_finished)
	# emit signal
	Autoload.PlayerMovedSignal.emit()
	
	
func _on_tween_finished():
	# After moving, check surrounding to see if Enemy is in combat range
	# (Consider moving this logic to Player.gd)
	for area in player.interactable_detection_area.get_overlapping_areas():
		if area is Body:
			var target_enemy = area.get_parent()
			combat_enemies.append(target_enemy)
			enemy_cursor.global_position = target_enemy.global_position
			enemy_cursor.animation_player.play("CursorBlink")
			# Store the index of the enemy in combat_enemies[]
			target_enemy.enemy_index = combat_enemies.size() - 1
			selected_enemy = target_enemy

# connect enemy death signal to this function
# combat_enemies.remove(target_enemy)
func _on_enemy_slain(enemy_index: int):
	print("THE ENEMY HAS BEEN SLAIN")
	combat_enemies.remove_at(enemy_index)
	enemy_cursor.animation_player.stop()
	enemy_cursor.global_position = enemy_cursor.reset_position
	
func _update_ui():
	player_coords.text = str(player.position / Autoload.grid_data.cell_size)
	player_hp.text = str(player.health)	

func _reset_timer():
	_is_moving = false
	
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
