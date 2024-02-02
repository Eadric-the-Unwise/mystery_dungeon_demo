extends Node2D

@onready var player_coords := $"CanvasLayer/Debug UI/Coords"
@onready var player_hp := $CanvasLayer/UI/HP/Health

var cell_size := 32

func _ready() -> void:
	Autoload.PlayerMovedSignal.connect(_update_ui)

func _physics_process(delta: float) -> void:
	pass

func _update_ui():
	player_coords.text = str(Autoload.player.position / cell_size)
	player_hp.text = str(Autoload.player.health)
