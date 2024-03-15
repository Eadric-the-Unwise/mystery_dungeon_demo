extends Node2D

@onready var move_timer := $MoveTimer
@onready var teleport_detection_area: Area2D = $TeleportDetectionArea
@onready var sprite := $Sprite
@onready var interactable_detection_area: Area2D = $InteractableDetectionArea
@onready var animation_player = $AnimationPlayer

var health := 10

func _ready() -> void:
	pass
	
func take_damage(attack_damage: int):
	health -= attack_damage
	print(str(name) + "took " + str(attack_damage) + " damage!")
	
	if health <= 0:
		print("GAME OVER")

func _move_player():
	pass

