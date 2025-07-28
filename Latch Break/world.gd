extends Node2D

func _ready():
	print("hello world")
	Global.world = self

func _exit_tree():
	Global.world = null

func instance_node(node, location):
	var node_instance = node.instantiate()
	add_child(node_instance)
	node_instance.global_position = location
