extends Marker2D

@export var block: PackedScene
@export var max_blocks: int
@export var grid_size: int

var current_block_number = 0


signal instance_node(node, location)

func _ready():
	if Global.world != null:
		connect("instance_node", Global.world)

func _process(delta):
	if current_block_number < max_blocks:
		global_position.x += grid_size
		emit_signal("instance_node", block, global_position)
		current_block_number += 1
	else:
		queue_free()
