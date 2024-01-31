extends CharacterBody2D

@onready var move_timer := $MoveTimer
var cell_size := 32
var unit_size := 64

func _ready() -> void:
	move_timer.start(0.0)

func _physics_process(delta: float) -> void:
	if move_timer.time_left == 0.0:
		move_player()
	
	
func move_player():
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("move_left","move_right")
	direction.y = Input.get_axis("move_up","move_down")
	
	if direction != Vector2.ZERO:
		position += direction * unit_size
		move_timer.start()
		print(position / unit_size)
