extends Node2D

#@onready var range_area = $RangeArea
@onready var raycast = $Area2D/CollisionShape2D/RayCast2D
@onready var sprite = $EnemySprite2D
@onready var state_machine = $StateMachine
@onready var idle = $StateMachine/EnemyIdle
@onready var follow = $StateMachine/EnemyFollow

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")

var health := 10
var enemy_index: int

# emited when Area is entered
signal AreaEntered
# emited when Area is exited
signal AreaExited
signal EnemySlain

var is_in_line_of_sight: bool = false
#var is_in_range: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#range_area.area_entered.connect(_on_area_entered)
	#range_area.area_exited.connect(_on_area_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
		

func take_damage(attack_damage: int):
	health -= attack_damage
	print(str(name) + "took " + str(attack_damage) + " damage!")
	if health <= 0:
		Autoload.EnemySlain.emit(enemy_index)
		self.queue_free()
		
#func _on_area_entered(area: Area2D):
	#AreaEntered.emit()
	#
#func _on_area_exited(area: Area2D):
	#AreaExited.emit()

		
	

