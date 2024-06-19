extends State

@onready var animation_player = $"../../AnimationPlayer"

func _ready():
	pass 

func _process(delta):
	pass

func enter():
	print("Death State")
	animation_player.play("Death")
	
func exit():
	pass
	
func update():
	pass

func _on_room_exited():
	pass
