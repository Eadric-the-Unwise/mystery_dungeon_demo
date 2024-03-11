extends State
class_name EnemyCombat

@onready var enemy = $"."
@onready var animation_player = $"../../AnimationPlayer"
@onready var sprite = $"../../EnemySprite2D"
@onready var combat_area = $"../../CombatArea"



func enter():
	print("Enemy in combat!")
	# Turn enemy red
	sprite.modulate = Color(0.871, 0, 0.024)
	#animation_player.play("Surprised")
func exit():
	sprite.modulate = Color(1, 1, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update():
	for shape in combat_area.get_children():
		var combat_area_grid_coord: Vector2i
		combat_area_grid_coord.x = int(shape.global_position.x / Autoload.grid_data.cell_size.x)
		combat_area_grid_coord.y = int(shape.global_position.y / Autoload.grid_data.cell_size.y)
		#
		if combat_area_grid_coord == Autoload.current_grid_point:
			return
		else:
			Transitioned.emit(self, "EnemyFollow")
			print("ATTACK OF OPPORTUNITY")
