extends Marker2D

@export var block: PackedScene
@export var max_blocks: int
@export var grid_size: int
@export var platform_length: int

@export var break_in_platform_chance: int
@export var max_break_in_platform_chance: int

@export_range(0, 100000) var amplitude: int = 0

@export var roughness: int
@export var max_roughness: int

@onready var min_block_height = -grid_size * amplitude
@onready var max_block_height = grid_size * amplitude

var current_block_number = 0

signal instance_node(node, location)
signal generation_complete(value)

func _ready():
	print('Generating')
	# Center horizontally based on block count
	var total_width = max_blocks * grid_size
	position.x = (get_viewport_rect().size.x - total_width) / 2

	# Center vertically
	position.y = get_viewport_rect().size.y / 2

func _process(delta):
	if Global.world != null:
		if !is_connected("instance_node", Callable(Global.world, "instance_node")):
			connect("instance_node", Callable(Global.world, "instance_node"))
	if current_block_number < max_blocks:
		var action = round(randf_range(0, max_roughness))
		
		var chance = round(randf_range(0, max_break_in_platform_chance))
		
		var break_size = round(randf_range(2, 4))
		
		if action > 0 and action < roughness:
			global_position.y -= grid_size
			clamp_height()

		elif action < roughness * 2 and action > roughness:
			global_position.y += grid_size
			clamp_height()
		
		if chance < break_in_platform_chance * 2 and chance > break_in_platform_chance:
			global_position.x += grid_size * break_size
			print('break')

		for i in (platform_length):
			global_position.x += grid_size
			emit_signal("instance_node", block, global_position)
			current_block_number += 1
		print('current number of blocks is ', current_block_number, ' and current position is ', global_position)
	else:
		queue_free()
		emit_signal("generation_complete", true)

func clamp_height():
	global_position.y = clamp(global_position.y, min_block_height, max_block_height)
