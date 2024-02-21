extends Node2D

@onready var area2d = $Area2D

@onready var state_machine = $StateMachine
@onready var idle = $StateMachine/EnemyIdle
@onready var follow = $StateMachine/EnemyFollow

signal AreaEntered
signal AreaExited

# Called when the node enters the scene tree for the first time.
func _ready():
	area2d.area_entered.connect(_on_area_entered)
	area2d.area_exited.connect(_on_area_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area: Area2D):
	print("Enemy area entered!")
	AreaEntered.emit()
	
func _on_area_exited(area: Area2D):
	print("Enemy area exited!")
	AreaExited.emit()

		
	

