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
	# ? FIND WHEN THE CURRENT_ROOM IS DEFINED, CURRENTLY NULL ON game.gd 
	# update_enemy_fog_sprite() call. 
	print("Fog loaded on Room: ", rooms_handler.current_room)
	
	# check for Enemy in Fog layer. If Enemy exists, change its sprite to Hidden 
	# enemy sprite.
	if rooms_handler.current_room.room_enemies:
		print("Room Enemies Exist")
	else:
		print("Room Enemies DO NOT Exist")
	
	## Return a Vector2i array with the positions of all used (fog) cells on given
	## visible layer.
	#var fog_cells: Array = get_used_cells(1)
	
	#Check all enemies in current room and erase their fog
	for enemy in rooms_handler.current_room.room_enemies:
		var coord: Vector2 = fog.local_to_map(enemy.global_position)
		#Decided to just erase the enemey fog, then have Enemy Sprite change to a '?' on Node2D
		set_cell(0, coord, -1)
		#Update enemy sprite to '?' sprite
		enemy.sprite.frame = 3
		
		#print("There's an enemy somewhere in this room!")
		#print(get_cell_source_id(0,coord))
		
		#Set cell to ? tile in fog Tilemap
		#set_cell(0, coord, 0, Vector2i(1,0))
		
		

	
		

		
