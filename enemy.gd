extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Autoload.PlayerMovedSignal.connect(_on_body_entered)
	
func _on_body_entered():
	print("PlayerMovedSignal")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
