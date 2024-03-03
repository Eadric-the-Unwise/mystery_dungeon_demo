extends State
class_name EnemyCombat

@onready var enemy = $"."
@onready var animation_player = $"../../AnimationPlayer"
@onready var sprite = $"../../EnemySprite2D"



func enter():
	print("Enemy in combat!")
	# Turn enemy red
	sprite.modulate = Color(0.871, 0, 0.024)
	#animation_player.play("Surprised")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update():
	print("ATTACK OF OPPORTUNITY")
