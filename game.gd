extends Node2D

@onready var player_coords: Label = $"CanvasLayer/Debug UI/Debug/Position =/Coords"
@onready var player_hp: Label = $"CanvasLayer/Game UI/HP/Health"
@onready var message := $"CanvasLayer/Debug UI/Message"
#----------------------------------------------------------
@onready var button_damage := $Buttons/Damage
@onready var button_heal := $Buttons/Heal
###
@onready var button_reset := $Buttons/Reset
#----------------------------------------------------------
@onready var tilemap := $TileMap
@onready var player := $Player

var _grid_data: AStarGrid2D
var _current_grid_point: Vector2i
var _is_moving: bool

func _ready() -> void:
	# initialize astargrid2d data
	_init_astargrid2d()
	# initialize ui
	_update_ui()
	# connect PlayerMovedSignal to _update_ui()
	Autoload.PlayerMovedSignal.connect(_update_ui)
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
		


func _init_astargrid2d():
	# Initialize tilemap 2D array
	_grid_data = AStarGrid2D.new()
	# Define tilemap region
	_grid_data.region = tilemap.get_used_rect()
	# Define tileset cell size
	_grid_data.cell_size = tilemap.tile_set.tile_size
	# Needs to be called if parameters like region, cell_size or offset are changed
	# (is_dirty() will return true if this is the case and this needs to be called)
	_grid_data.update()
	
	# get_used_cells(0) = TileMap Layer 0
	for tile_coord in tilemap.get_used_cells(0):
		# Get tile coordinate
		var tile_data = tilemap.get_cell_tile_data(0, tile_coord)
		# Check for tile for TileSet Custom Data
		if tile_data.get_custom_data("is_blocked"):
			# Sets this grid cell to be "solid", preventing player or enemies from moving into it
			_grid_data.set_point_solid(tile_coord, true)
	

	# Set _current_grid_point coordinates
	_current_grid_point.x = int(player.position.x / _grid_data.cell_size.x)
	_current_grid_point.y = int(player.position.y / _grid_data.cell_size.y)
	# Update player position to the position of _current_grid_point coordinate
	player.position = _grid_data.get_point_position(_current_grid_point)
	print(_current_grid_point)


func _select_check() -> void:
	# Check for all overlapping areas in Player's Area2D (interactable_detection_area)
	for area in player.teleport_detection_area.get_overlapping_areas():
		if area is Teleporter:
			# Returns the map coordinates of the cell containing the given local_position. 
			var target_coord = tilemap.local_to_map(area.target_teleporter.global_position)
			# Update player position to the position of target_coord 
			player.position = _grid_data.get_point_position(target_coord)
			# Update _current_grid_point coordinates
			_current_grid_point = target_coord

func _update_ui():
	player_coords.text = str(player.position / _grid_data.cell_size)
	player_hp.text = str(player.health)

func _move_to_coord(move_direction: Vector2i) -> void:
	var target_grid_point = _current_grid_point + move_direction
	# If target_grid_point is an "is_blocked" tile, prevent movement
	if _grid_data.is_point_solid(target_grid_point):
		return
	
	var target_position = _grid_data.get_point_position(target_grid_point)
	player.position = target_position
	_current_grid_point = target_grid_point
	print(_current_grid_point)
	# Prevents player from moving every in-game frame
	_is_moving = true
	# Start move_timer (player cannot move again until timer = timeout())
	player.move_timer.start()
	# Update Temporary UI
	_update_ui()
	

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

