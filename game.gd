extends Node2D

@onready var player_coords := $"CanvasLayer/Debug UI/Coords"
@onready var player_hp := $CanvasLayer/UI/HP/Health
@onready var message := $"CanvasLayer/Debug UI/Message"

@onready var button_damage := $Buttons/Damage
@onready var button_heal := $Buttons/Heal
###
@onready var button_reset := $Buttons/Reset

var cell_size := 32

func _ready() -> void:
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

func _physics_process(_delta: float) -> void:
	pass

func _reset_game():
	Autoload.player.health = Autoload.player.starting_health
	Autoload.player.position = Autoload.player.starting_position
	message.text = "Game Reset"
	_update_ui()
	
func _heal_player(heal: int):
	Autoload.player.health += heal
	message.text = "Player healed by " + str(heal) + "!"
	_update_ui()

func _deal_damage(damage: int):
	Autoload.player.health -= damage
	message.text = "Player took " + str(damage) + " damage!"
	_update_ui()

func _update_ui():
	player_coords.text = str(Autoload.player.position / cell_size)
	player_hp.text = str(Autoload.player.health)
