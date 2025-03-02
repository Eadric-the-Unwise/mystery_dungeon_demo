extends TileMap
@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var fog = $"."
@onready var enemy_container = $"../EnemyContainer"
@onready var rooms_handler = $"../Rooms Handler"



# Called when the node enters the scene tree for the first time.
func _ready():
	Autoload.PlayerMoved.connect(erase_fog)
	Autoload.PlayerMoved.connect(update_enemy_fog_sprite)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func erase_fog():
	# Erase Player cell fog
	#set_cell(0, Autoload.current_grid_point, -1)
	# Erase Player interactable detection cell fog
	for interactable_cell in player.vision_area.get_children():
		var coord: Vector2 = fog.local_to_map(interactable_cell.global_position)
		# Erase fog at coord : Vector2
		set_cell(0, coord, -1)

func update_enemy_fog_sprite():
	# check for Enemy in Fog layer. If Enemy exists, change its sprite to Hidden 
	# enemy sprite.
	## Return a Vector2i array with the positions of all used (fog) cells on given
	## visible layer.
	#var fog_cells: Vector2i = get_used_cells(2)
	
	# ? FIND WHEN THE CURRENT_ROOM IS DEFINED, CURRENTLY NULL ON game.gd 
	# update_enemy_fog_sprite() call. 
	print(rooms_handler.current_room)
	#if rooms_handler.current_room.room_enemies:
		#print("Room Enemies Exist")
	#else:
		#print("Room Enemies DO NOT Exist")
	
	#for enemy in enemy_container.get_children():
		#var coord: Vector2 = fog.local_to_map(enemy.global_position)
		#print(get_cell_source_id(2,coord))
			#print("There's an enemy here!")
	
		

		
