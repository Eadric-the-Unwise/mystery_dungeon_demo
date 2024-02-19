extends Node2D

@onready var area2d = $Area2D

@onready var state_machine = $StateMachine
@onready var idle = $StateMachine/EnemyIdle
@onready var follow = $StateMachine/EnemyFollow

# Called when the node enters the scene tree for the first time.
func _ready():
	area2d.area_entered.connect(_on_area_entered)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area: Area2D):
	print("Enemy area entered!")
	print(state_machine.current_state)
	follow.Transitioned.emit(idle, "EnemyFollow")
		
	

