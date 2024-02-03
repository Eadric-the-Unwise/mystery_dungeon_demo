extends Area2D

@onready var sprite := $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(_node: Node2D):
	print("body entered lever's area2d")
	if Input.is_action_pressed("ui_accept"):
		sprite.frame = 19
