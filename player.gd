extends CharacterBody2D

@onready var move_timer := $MoveTimer

var cell_size := 32
var unit_size := 64

var health := 10

func _ready() -> void:
	Autoload.player = self
	move_timer.start(0.0)

func _physics_process(delta: float) -> void:
	if move_timer.time_left == 0.0:
		_move_player()
	
	
func _move_player():
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("move_left","move_right")
	direction.y = Input.get_axis("move_up","move_down")
	
	if direction != Vector2.ZERO:
		move_and_collide(direction * unit_size)
		# Corrects float amounts returned in move_and_collide
		position = position.round()
		#position += direction * unit_size
		move_timer.start()
		print(position)
