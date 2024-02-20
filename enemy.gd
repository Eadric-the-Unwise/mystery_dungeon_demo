extends Node2D

@onready var area2d = $Area2D

@onready var state_machine = $StateMachine
@onready var idle = $StateMachine/EnemyIdle
@onready var follow = $StateMachine/EnemyFollow

#var current_grid_point: Vector2i
var current_id_path: Array[Vector2i]

signal AreaEntered
signal AreaExited

# Called when the node enters the scene tree for the first time.
func _ready():
	area2d.area_entered.connect(_on_area_entered)
	area2d.area_exited.connect(_on_area_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Used simply for troubleshooting pathfinding algorithm
# Click with mouse anywhere on stage to create a path
# (Runs at all times)
func _input(event):
	if event.is_action_pressed("move") == false:
		return
	
	# slice(1) removes the first value in the id_path (enemy's current grid point)
	var id_path = Autoload.grid_data.get_id_path(
		Autoload.tilemap.local_to_map(global_position),
		Autoload.tilemap.local_to_map(get_global_mouse_position())
	).slice(1)
	print(id_path)		
	
	if id_path.is_empty() == false:
		current_id_path = id_path
		# Set the EnemyFollow.target_coordinate to the first coordinate int he ID path
		$StateMachine/EnemyFollow.target_coordinate = current_id_path.front()

func _on_area_entered(area: Area2D):
	print("Enemy area entered!")
	AreaEntered.emit()
	
func _on_area_exited(area: Area2D):
	print("Enemy area exited!")
	AreaExited.emit()

		
	

