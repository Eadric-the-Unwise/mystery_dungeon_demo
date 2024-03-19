extends Node2D

#@onready var range_area = $RangeArea
@onready var sprite = $EnemySprite2D
@onready var state_machine = $StateMachine
@onready var idle = $StateMachine/EnemyIdle
@onready var follow = $StateMachine/EnemyFollow
@onready var enemy_combat = $StateMachine/EnemyCombat
@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var animation_player = $AnimationPlayer

var current_enemy_coordinate: Vector2i

var health := 10

# emited when Area is entered
signal AreaEntered
# emited when Area is exited
signal AreaExited
signal EnemyAttackTurn

var is_in_line_of_sight: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func take_damage(attack_damage: int):
	health -= attack_damage
	print(str(name) + "took " + str(attack_damage) + " damage!")
	# SLAIN!
	if health <= 0:
		Autoload.grid_data.set_point_solid(current_enemy_coordinate, false)
		Autoload.EnemySlain.emit()
		self.queue_free()
		return
	# Will Attack, if able
	EnemyAttackTurn.emit()
		
	

