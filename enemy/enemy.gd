extends Node2D
class_name Enemy

#@onready var range_area = $RangeArea
@onready var sprite = $EnemySprite2D
@onready var state_machine = $StateMachine
@onready var enemy_idle = $StateMachine/EnemyIdle
@onready var enemy_follow = $StateMachine/EnemyFollow
@onready var enemy_combat = $StateMachine/EnemyCombat
@onready var enemy_death = $StateMachine/EnemyDeath

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var animation_player = $AnimationPlayer

var enemy_current_state : State
var current_enemy_coordinate: Vector2i

# moved to enemy script 
#var health := 10

# emited when Area is entered
signal AreaEntered
# emited when Area is exited
signal AreaExited
signal EnemyAttackTurn
signal EnemyAttackOpportunity
signal EnemyEnteredCombat
signal EnemyExitedCombat
signal EnemySlain

# Used to track where it lives within Game.gd/combat_enemies[] Array2D
#var combat_enemies_variable: int
var is_in_line_of_sight: bool = false
var active: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	enemy_current_state = state_machine.current_state

func take_damage(attack_damage: int):
	self.health -= attack_damage
	print(str(name) + "took " + str(attack_damage) + " damage!")
	# SLAIN!
	if self.health <= 0:
		#Identify the Enemy's current State. Switch to enemy_death Death State
		var current_state = state_machine.current_state
		current_state.Transitioned.emit(current_state, "EnemyDeath")
	# Will Attack, if able
	else: 
		EnemyAttackTurn.emit()
		
	

func slay_enemy():
		Autoload.grid_data.set_point_solid(current_enemy_coordinate, false)
		EnemySlain.emit(self)
		# add a Death Animation state, so enemy can exit EnemyCombat, removing itself from the combat_enemies array
		# before dying
		######################################
		#EnemyExitedCombat.emit(self)
		######################################
		self.queue_free()
		return
