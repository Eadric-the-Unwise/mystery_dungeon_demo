extends Node2D

@onready var move_timer := $MoveTimer
@onready var interactable_detection_area: Area2D = $InteractableDetectionArea

var health := 10

func _ready() -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	pass

	
func _move_player():
	pass

