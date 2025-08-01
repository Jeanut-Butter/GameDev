extends Node2D

@export var room_scenes: Array[PackedScene]
@export var corridor_scene: PackedScene
@export var start_room_scene: PackedScene
var occupied_positions = {}

func _ready():
	generate_level(Vector2i.ZERO)
	
func generate_level(start_pos: Vector2i):
	var rooms_to_generate = 5
	var current_pos = start_pos

	place_room(start_room_scene, current_pos)

	for i in range(rooms_to_generate):
		var dir = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN].pick_random()
		var next_pos = current_pos + dir

		while occupied_positions.has(next_pos):
			dir = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN].pick_random()
			next_pos = current_pos + dir

		var new_room = room_scenes.pick_random()
		place_room(new_room, next_pos)
		connect_rooms(current_pos, next_pos)
		current_pos = next_pos

func place_room(scene: PackedScene, grid_pos: Vector2i):
	var room = scene.instantiate()
	room.position = Vector2(grid_pos) * Vector2(512, 288)
	add_child(room)
	occupied_positions[grid_pos] = room

func connect_rooms(pos1: Vector2i, pos2: Vector2i):
	var corridor = corridor_scene.instantiate()
	var offset = Vector2(pos2 - pos1) * Vector2(256, 144)
	corridor.position = Vector2(pos1) * Vector2(512, 288) + offset

	add_child(corridor)
