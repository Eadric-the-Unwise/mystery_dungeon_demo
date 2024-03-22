extends Node

signal PlayerActionTaken
signal RoomEntered
signal RoomExited


var grid_data: AStarGrid2D

var tilemap: TileMap

var current_grid_point: Vector2i

# Global reference to player
# Defined in player.gd (Godot loads autoload before loading other nodes)
# Keep 'player' inferred but not defined until after Player is loaded
#@onready var player : Node2D
# update this variable before loading into a new Scene to choose new player grid coords
#var player_updated_spawn_coordinates:= Vector2(1,4)
