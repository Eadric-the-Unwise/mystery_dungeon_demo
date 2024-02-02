extends Node2D


const TILE_SIZE := 32

const LEVEL_SIZES :Array = [
	Vector2(20,18),
	Vector2(40,36)
]

const LEVEL_ROOM_COUNTS := [5, 7]
const MIN_ROOM_DIMENSION := 5
const MAX_ROOM_DIMENSION := 8

# 
enum Tile {Floor, Wall, Water, Door, Dirt, Stone}

# Current Level ------------------------

var level_num := 0
var rooms := []
var map := []
var level_size

# Node Refs ------------------------

@onready var tile_map := $TileMap
@onready var player := $Player

# Game State ------------------------

var player_tile := Vector2.ZERO
var score := 0

func _ready() -> void:
	randomize()
	build_level()
	

func build_level():
	# Start with a blank map
	
	rooms.clear()
	map.clear()
	tile_map.clear()

	level_size = LEVEL_SIZES[level_num]
	for x in range(level_size.x):
		map.append([])
		for y in range(level_size.y):
			# add tile data to y column, on row x
			map[x].append(Vector2i(0, 1))
			tile_map.set_cell(0, Vector2i(x,y), 3, Vector2i(0, 1))
