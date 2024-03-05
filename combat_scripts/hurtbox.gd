class_name Hurtbox
extends Area2D

func _ready():
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(hitbox: Hitbox):
	# Will return if area entered is not of Hitbox class
	# This practice is to help prevent bugs
	if hitbox == null:
		return
		
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
