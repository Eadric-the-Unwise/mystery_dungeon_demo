extends Area2D

@onready var enemy = $"."

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy.area_entered.connect(_on_area_entered)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area: Area2D):
	print("Enemy area entered!")

