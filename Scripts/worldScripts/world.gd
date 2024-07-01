extends Node2D

# Declare some variables
@onready var tile_map : TileMap = $TileMap
@onready var tool_text = $UILayer/ToolText

@export var inv: Inv

@export var is_debugging: bool = false
@export var noise_height_text: NoiseTexture2D
@export var map_seed = 0

@export var grass_threashold: float
@export var flower_threashold: float
@export var tree_threashold: float

@export var growth_speed: float = 5.0

	# Enums for the tool sets
enum FARMING_MODES {SEEDS, DIRT, HARVEST, LOGGING}
var farming_mode_state = FARMING_MODES.DIRT

	# Map & Noise variables
var noise: Noise
var noise_var_array = []
var width: int = 512
var height: int = 512

	# Tilemap source IS
var source_id = 0

	# Environment Layers
var ground_layer = 0
var environment_layer = 1

	# Environment Atlas's
var clear_atlas = Vector2i(8, 1)
var totom_atlas = Vector2i(0,0)
var water_atlas = Vector2i(10, 0)
var land_atlas = Vector2i(2, 0)
var plowed_land_atlas = Vector2i(12, 0)
var seed_land_atlas = Vector2i(11, 1)
var dirt_tiles = []

	# Environment data
var can_place_plowed_custom_data = "can_place_plow"
var can_place_seed_custom_data = "can_place_seeds"
var can_havest_custom_data = "can_havest"
var can_chop_down = "can_chop_down"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set the seed of the map
	map_seed = randi()
	# Set the noise as the texture
	noise_height_text.noise.set_seed(map_seed)
	noise = noise_height_text.noise
	
	# Set the current tool
	farming_mode_state = FARMING_MODES.DIRT
	tool_text.text = "PLOW"
	
	# Call the generate world
	generate_world()

# Handle some debugging
func _process(delta):
	if is_debugging:
		if Input.is_action_just_pressed("reload"):
			get_tree().reload_current_scene()

# Function for generating the world
func generate_world() -> void:
	# Print the seed
	print(map_seed)
	# Generate the world
	for x in range(-width / 2, width / 2):
		for y in range(-height / 2, height / 2):
			# Generate the random land tile
			var land_tile = randi_range(0, 3)
			
			# Load the noise value
			var noise_val = noise.get_noise_2d(x, y)
			noise_var_array.append(noise_val)
			# Handle placment of tiles
			if noise_val >= 0.0:
				tile_map.set_cell(0, Vector2(x,y), source_id, land_atlas)
			elif noise_val < 0.0:
				tile_map.set_cell(0, Vector2(x,y), source_id, water_atlas)

# Handle the input of the game
func _input(event):
	# Toggle the tools
	if Input.is_action_just_pressed("toggleDirt"):
		farming_mode_state = FARMING_MODES.DIRT
		tool_text.text = "PLOW"
	if Input.is_action_just_pressed("toggleSeeds"):
		farming_mode_state = FARMING_MODES.SEEDS
		tool_text.text = "PLANT"
	if Input.is_action_just_pressed("toggleHarvest"):
		farming_mode_state = FARMING_MODES.HARVEST
		tool_text.text = "HARVEST"
	if Input.is_action_just_pressed("toggleLogging"):
		farming_mode_state = FARMING_MODES.LOGGING
		tool_text.text = "LOGGING"
		
	# Handle the placing of tiles
	if Input.is_action_just_pressed("leftClick"):
		# Get the mouse position
		var mouse_pos = get_global_mouse_position()
		var tile_mouse_pos = tile_map.local_to_map(mouse_pos) # Get mouse position local to the tile
		
		# Handle placing the tiles
		if farming_mode_state == FARMING_MODES.SEEDS:
			if retrieving_tilemap_data(tile_mouse_pos, can_place_seed_custom_data, ground_layer):
				# Update the level of the seed
				var level: int = 0
				var final_seed_level: int = 3
				# Set the current cell
				handle_seed(tile_mouse_pos, level, seed_land_atlas, final_seed_level)
		elif farming_mode_state == FARMING_MODES.DIRT:
			if retrieving_tilemap_data(tile_mouse_pos, can_place_plowed_custom_data, ground_layer):
				dirt_tiles.append(tile_mouse_pos)
				tile_map.set_cells_terrain_connect(ground_layer, dirt_tiles, 0, 0)
		elif farming_mode_state == FARMING_MODES.HARVEST:
			if retrieving_tilemap_data(tile_mouse_pos, can_havest_custom_data, environment_layer):
				# NOTE need to implement a check for if the crop is at level trhree
				tile_map.set_cell(environment_layer, tile_mouse_pos, source_id, clear_atlas)
		elif farming_mode_state == FARMING_MODES.LOGGING:
			if retrieving_tilemap_data(tile_mouse_pos, can_chop_down, ground_layer):
				tile_map.set_cell(ground_layer, tile_mouse_pos, source_id, land_atlas)

# Handle retreiving tilemap data
func retrieving_tilemap_data(tile_mouse_pos, custom_data_layer, layer):
	var tile_data : TileData = tile_map.get_cell_tile_data(layer, tile_mouse_pos)
	if tile_data:
		return tile_data.get_custom_data(custom_data_layer)
	else:
		return false

# Handle the growth of the seeds
func handle_seed(tile_map_pos, level, atlas_coord, final_seed_level):
	# Set the cell of the seed
	tile_map.set_cell(environment_layer, tile_map_pos, source_id, atlas_coord)
	# Start the timer in the current tree
	await get_tree().create_timer(growth_speed).timeout
	
	# Check if the plant is at full growth
	if level == final_seed_level:
		return
	else: # Increment the x value of the atlas for the plant 
		var new_atlas: Vector2i = Vector2i(atlas_coord.x + 1, atlas_coord.y)
		handle_seed(tile_map_pos, level + 1, new_atlas, final_seed_level)
