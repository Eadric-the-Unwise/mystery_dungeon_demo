extends Node2D

@onready var animation_player = $AnimationPlayer
#@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("damage")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
