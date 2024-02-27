extends Node2D

@onready var area2d = $Area2D
@onready var raycast = $Area2D/CollisionShape2D/RayCast2D

@onready var state_machine = $StateMachine
@onready var idle = $StateMachine/EnemyIdle
@onready var follow = $StateMachine/EnemyFollow

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")

# emited when Area is entered
signal AreaEntered
# emited when Area is exited
signal AreaExited

var _is_in_line_of_sight: bool = false
var _is_in_range: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	area2d.area_entered.connect(_on_area_entered)
	area2d.area_exited.connect(_on_area_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#print(raycast.is_colliding())

func _on_area_entered(area: Area2D):
	print("Enemy area entered!")
	AreaEntered.emit()
	
func _on_area_exited(area: Area2D):
	print("Enemy area exited!")
	AreaExited.emit()

		
	

