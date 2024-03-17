extends Sprite2D
class_name Cursor
@onready var animation_player = $AnimationPlayer

var reset_position:= Vector2(-16.0, -16.0)
# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = reset_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
