extends State
class_name EnemyIdle

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var enemy: Node2D = $"../.."
@onready var raycasts = $"../../Raycasts"
@onready var sprite = $"../../EnemySprite2D"
@onready var animation_player = $"../../AnimationPlayer"
@onready var combat_area = $"../../CombatArea"

func enter():
	#print("Enemy now idle")
	enemy.AreaEntered.connect(_on_area_entered)
	enemy.AreaExited.connect(_on_area_exited)
	# Initialize Raycast positions from default Node position to Player's global position
	# This prevents is_in_line_of_sight from being true on frame 1, due to defaults Node position
	# thinking that player is in view because they are likely unblocked from runtime
	init_raycasts()

func _process(_delta):
	_check_for_combat()
	# Loop all RayCast2D's to see if the player is visible
	check_line_of_sight()
	# Check if the Player's Line of Sight isn't blocked by any wall or object
	if enemy.is_in_line_of_sight:
		# Transition to Follow State
		Transitioned.emit(self, "EnemyFollow")
		animation_player.play("Surprised")

func init_raycasts():
	# RayCast
	var raycast_target_position = player.global_position - enemy.global_position
	for raycast in raycasts.get_children():
		raycast.target_position = raycast_target_position

func update():
	pass

func _check_for_combat():
	for shape in combat_area.get_children():
		var combat_area_grid_coord: Vector2i
		combat_area_grid_coord.x = int(shape.global_position.x / Autoload.grid_data.cell_size.x)
		combat_area_grid_coord.y = int(shape.global_position.y / Autoload.grid_data.cell_size.y)
		#
		if combat_area_grid_coord == Autoload.current_grid_point:
			#print("Transition to combat")
			_flip_sprite()
			Transitioned.emit(self, "EnemyCombat")
			return true
			
func check_line_of_sight():
	# RayCast
	var raycast_target_position = player.global_position - enemy.global_position
	for raycast in raycasts.get_children():
		raycast.target_position = raycast_target_position
		# Determine Line of Sight
		if raycast.is_colliding():
			# Line of Sight is Blocked
			enemy.is_in_line_of_sight = false
			
		else:
			# Player is in Enemy's Line of Sight
			enemy.is_in_line_of_sight = true
			return #DO NOT DELETE THIS! 
			# IT WILL OVERRIDE THE BOOL IF YOU LET THE LOOP CONTINUE
			
# ------------------------------------------------------------------------------
func _flip_sprite():# Flip horizonal sprite
	if Autoload.current_grid_point.x > enemy.current_enemy_coordinate.x:
		#print("Target.x = " + str(_target_coordinate.x) + ", current.x = " + str(enemy.current_enemy_coordinate.x))
		enemy.sprite.flip_h = true
	else:
		enemy.sprite.flip_h = false

func _on_area_entered():
	pass
	## Enemy is in range of Player
	#if !enemy.is_in_range:
		#enemy.is_in_range = true

func _on_area_exited():
	pass
	## Enemy is out of range of Player
	#if enemy.is_in_range:
		#enemy.is_in_range = false

