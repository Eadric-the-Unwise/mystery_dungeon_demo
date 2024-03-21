extends Node2D

# currently a bit messy. This time starts, and ends, turning off and on a _tween_move_timer bool in Game.gd
@onready var move_timer := $MoveTimer
# Determines how long to wait after Tween animation to check for combat_enemies and select one with cursor
@onready var cursor_timer = $CursorTimer
@onready var teleport_detection_area: Area2D = $TeleportDetectionArea
@onready var sprite := $Sprite
@onready var interactable_detection_area: Area2D = $InteractableDetectionArea
@onready var interactable_detection_area_right = $InteractableDetectionArea/RIGHT
@onready var animation_player = $AnimationPlayer
@onready var right = $InteractableDetectionArea/RIGHT
@onready var left = $InteractableDetectionArea/LEFT


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

