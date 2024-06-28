extends TileMap
@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var fog = $"."

# Called when the node enters the scene tree for the first time.
func _ready():
	Autoload.PlayerMoved.connect(erase_fog)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func erase_fog():
	# Erase Player cell fog
	set_cell(0, Autoload.current_grid_point, -1)
	# Erase Player interactable detection cell fog
	for interactable_cell in player.interactable_detection_area.get_children():
		var coord: Vector2 = fog.local_to_map(interactable_cell.global_position)
		# Erase fog at coord : Vector2
		set_cell(0, coord, -1)
