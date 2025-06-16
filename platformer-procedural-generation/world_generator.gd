extends Marker2D

@export var block: PackedScene
@export var max_blocks: int
@export var grid_size: int

var current_block_number = 0

signal instance_node(node, location)

func _ready():
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
		global_position.x += grid_size
		emit_signal("instance_node", block, global_position)
		current_block_number += 1
	else:
		queue_free()
