extends Node2D

@onready var player_coords := $"CanvasLayer/Debug UI/Coords"

func _physics_process(delta: float) -> void:
	player_coords.text = str(Autoload.player.position)
