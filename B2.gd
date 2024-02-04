extends "res://game.gd"


# Called when the node enters the scene tree for the first time.
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
	message.text = "Welcome to B1!"
	player.move_timer.timeout.connect(_reset_timer)


