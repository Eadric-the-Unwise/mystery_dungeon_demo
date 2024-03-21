extends State
class_name EnemyCombat

@onready var enemy = $"../.."
@onready var animation_player = $"../../AnimationPlayer"
@onready var sprite = $"../../EnemySprite2D"
@onready var combat_area = $"../../CombatArea"
@onready var player: Node2D = get_tree().get_first_node_in_group("Player")


func enter():
	#print("Enter enemy_combat")
	enemy.EnemyEnteredCombat.emit(enemy)
	# Turn enemy red
	sprite.modulate = Color(0.871, 0, 0.024)
	#animation_player.play("Surprised")
func exit():
	#print("Exit enemy_combat")
	enemy.EnemyExitedCombat.emit(enemy)
	sprite.modulate = Color(1, 1, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy.EnemyAttackTurn.connect(_on_enemy_attack_turn)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func update():
	for shape in combat_area.get_children():
		var combat_area_grid_coord: Vector2i
		combat_area_grid_coord.x = int(shape.global_position.x / Autoload.grid_data.cell_size.x)
		combat_area_grid_coord.y = int(shape.global_position.y / Autoload.grid_data.cell_size.y)
		# Can this even be reached, ever?
		if combat_area_grid_coord == Autoload.current_grid_point:
			print("HEY THIS PRINTED SO CHECK ENEMY_COMBAT.GD UPDATE LOOP")
			return
		else:
			# Switch back to EnemyFollow State
			# self = EnemyCombat
			Transitioned.emit(self, "EnemyFollow")
			print("ATTACK OF OPPORTUNITY")
			return

func _on_enemy_attack_turn():
	await player.animation_player.animation_finished
	animation_player.play("AttackLeft")

