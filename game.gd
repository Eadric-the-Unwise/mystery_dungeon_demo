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
	# deal player damage
	button_damage.pressed.connect(_deal_damage.bind(2))
	button_heal.pressed.connect(_heal_player.bind(4))
	###
	button_reset.pressed.connect(_reset_game)
	message.text = "Welcome to the game!"
	player.move_timer.timeout.connect(_reset_timer)

func _process(_delta: float) -> void:
	if _is_moving:
		return
	if Input.is_action_pressed("move_up"):
		_move_to_coord(Vector2i.UP)
	if Input.is_action_pressed("move_down"):
		_move_to_coord(Vector2i.DOWN)
	if Input.is_action_pressed("move_left"):
		_move_to_coord(Vector2i.LEFT)
	if Input.is_action_pressed("move_right"):
		_move_to_coord(Vector2i.RIGHT)
		
	if Input.is_action_pressed("ui_accept"):
		_select_check()

func _select_check() -> void:
	var tile_data = tilemap.get_cell_tile_data(0, _current_grid_point)
	if tile_data.get_custom_data("is_stairs"):
		get_tree().change_scene_to_file("res://B2.tscn")


func _init_astargrid2d():
	_grid_data = AStarGrid2D.new()
	_grid_data.region = tilemap.get_used_rect()
	_grid_data.cell_size = tilemap.tile_set.tile_size
	_grid_data.update()
	
	# get_used_cells(0) = Layer 0
	for tile_coord in tilemap.get_used_cells(0):
		var tile_data = tilemap.get_cell_tile_data(0, tile_coord)
		if tile_data.get_custom_data("is_blocked"):
			# sets this grid cell to be "solid", now allowing player or enemies to move into it
			_grid_data.set_point_solid(tile_coord, true)
	
	# currently 16x16, may update to 32x32 in future
	_current_grid_point.x = int(player.position.x / _grid_data.cell_size.x)
	_current_grid_point.y = int(player.position.y / _grid_data.cell_size.y)
	player.position = _grid_data.get_point_position(_current_grid_point)
	print(_current_grid_point)

	

func _update_ui():
	player_coords.text = str(player.position / _grid_data.cell_size)
	player_hp.text = str(player.health)

func _move_to_coord(move_direction: Vector2i) -> void:
	var target_grid_point = _current_grid_point + move_direction
	if _grid_data.is_point_solid(target_grid_point):
		return
	
	var target_position = _grid_data.get_point_position(target_grid_point)
	player.position = target_position
	_current_grid_point = target_grid_point
	print(_current_grid_point)
	_is_moving = true
	player.move_timer.start()
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

