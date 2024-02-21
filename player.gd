extends Node2D

@onready var move_timer := $MoveTimer
@onready var teleport_detection_area: Area2D = $TeleportDetectionArea
@onready var sprite := $Sprite
@onready var interactable_detection_area: Area2D = $InteractableDetectionArea

var health := 10

func _ready() -> void:
	pass

func _move_player():
	pass

