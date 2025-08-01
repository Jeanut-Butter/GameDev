extends Node2D

@export var room_scenes: Array[PackedScene]
@export var corridor_scene: PackedScene
@export var start_room_scene: PackedScene

const ROOM_SIZE = Vector2(512, 288)
var occupied_positions: Dictionary = {}

func _ready():
	generate_level(Vector2i.ZERO)

func generate_level(start_pos: Vector2i):
	var current_pos = start_pos
	var rooms_to_generate = 50

	place_room(start_room_scene, start_pos)

	for i in range(rooms_to_generate):
		var dir = pick_weighted_direction()
		var next_pos = current_pos + dir

		if occupied_positions.has(next_pos):
			continue

		var new_room = room_scenes.pick_random()
		place_room(new_room, next_pos)
		current_pos = next_pos

func pick_weighted_direction() -> Vector2i:
	var direction_pool = [
		Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT,
		Vector2i.LEFT, Vector2i.LEFT,
		Vector2i.UP,
		Vector2i.DOWN
	]
	return direction_pool.pick_random()

func place_room(scene: PackedScene, grid_pos: Vector2i):
	var room = scene.instantiate()
	room.position = Vector2(grid_pos) * ROOM_SIZE
	add_child(room)
	occupied_positions[grid_pos] = room

	draw_debug_outline(room.position, Color.GREEN)

func draw_debug_outline(position: Vector2, color: Color):
	var rect = ColorRect.new()
	rect.size = ROOM_SIZE
	rect.position = position
	rect.color = color
	rect.modulate.a = 0.25
	add_child(rect)
