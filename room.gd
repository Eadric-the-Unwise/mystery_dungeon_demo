class_name Room
extends Area2D

@onready var enemy_sprite_2d = $EnemySprite2D

@onready var camera_2d: Camera2D = $"../Camera2D"


func _on_area_exited(_area: Area2D) -> void:
	print("Exited: Room ", name)

func _on_area_entered(_area: Area2D) -> void:
	print("Entered: Room ", name)
	camera_2d.position = position


