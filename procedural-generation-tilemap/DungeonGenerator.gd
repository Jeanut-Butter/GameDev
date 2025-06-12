extends Node2D
@onready var tile_map_layer = $TileMapLayer

var floor_tile_bottom := Vector2i(2,3)
var floor_tile_top := Vector2i(0, 2)
var wall_tile_top := Vector2i(0, 0)
var wall_tile_middle := Vector2i(0, 1)
var wall_tile_bottom := Vector2i(8, 0)

const WIDTH = 120
const HEIGHT = 60
const cellSize = 10
const minRoomSize = 5
const maxRoomSize = 10
const maxRooms = 15

var grid = []
var rooms = []

func _ready():
	randomize()
	startDungeon()

func startDungeon():
	initialize_grid()
	generateDungeon()
	draw_dungeon()

func _process(delta):
	if Input.is_action_just_pressed("restartGame"):
		regenDungeon()

func initialize_grid():
	for x in range(WIDTH):
		grid.append([])
		for y in range(HEIGHT):
			grid[x].append(1)

func generateDungeon():
	for i in range(maxRooms):
		var room = generateRoom()
		if placeRoom(room):
			if rooms.size() > 0:
				# Only connect if vertical distance is greater than 3
				if abs(room.position.y - rooms[-1].position.y) > 3:
					connectRooms(rooms[-1], room)
			# Store the room either way
			rooms.append(room)

func generateRoom():
	var width = randi() % (maxRoomSize - minRoomSize + 1) + minRoomSize
	var height = randi() % (maxRoomSize - minRoomSize + 1) + minRoomSize
	var x = randi() % (WIDTH - width - 1) + 1
	var y = randi() % (HEIGHT-height - 1) + 1
	return Rect2(x, y, width, height)

func placeRoom(room):
	# Check for collision with existing rooms AND 3-tile buffer below
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			if grid[x][y] == 0:
				return false

			# Check for 3-tile buffer *below* each tile
			for offset in range(1, 4):
				var y_check = y + offset
				if y_check < HEIGHT and grid[x][y_check] == 0:
					return false

	# No conflict, place room
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			grid[x][y] = 0
	return true

func connectRooms(room1, room2, corridor_width=3):
	var start = Vector2(
		int(room1.position.x + room1.size.x / 2),
		int(room1.position.y + room1.size.y / 2)
	)
	var end = Vector2(
		int(room2.position.x + room2.size.x / 2),
		int(room2.position.y + room2.size.y / 2)
	)

	var current = start

	while current.x != end.x:
		current.x += 1 if end.x > current.x else -1
		for i in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
			for j in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
				if current.y + j >= 0 and current.y + j < HEIGHT and current.x + i >= 0 and current.x + i < WIDTH:
					grid[current.x + i][current.y + j] = 0

	while current.y != end.y:
		current.y += 1 if end.y > current.y else -1
		for i in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
			for j in range (-int(corridor_width / 2), int(corridor_width / 2) + 1):
				if current.x + i >= 0  and current.x + i <= WIDTH and current.y + j >= 0 and current.y + j <= HEIGHT:
					grid[current.x + i][current.y + j] = 0

func draw_dungeon():
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var tile_position = Vector2i(x, y)
			if grid[x][y] == 0:
				tile_map_layer.set_cell(tile_position, 0, floor_tile_bottom)
			elif grid[x][y] == 1:
				if y < HEIGHT - 1 and grid[x][y + 1] == 0:
					tile_map_layer.set_cell(tile_position, 0, wall_tile_middle)
				elif y > 0 and grid[x][y - 1] == 0:
					tile_map_layer.set_cell(tile_position, 0, wall_tile_bottom)
				else:
					tile_map_layer.set_cell(tile_position, 0, Vector2i(-1, -1))
			else:
				tile_map_layer.set_cell(tile_position, 0, Vector2i(-1, -1))

	for x in range(WIDTH):
		for y in range(1, HEIGHT):
			var current_pos = Vector2i(x, y)
			var above_pos =  Vector2i(x, y - 1)

			if tile_map_layer.get_cell_atlas_coords(current_pos) == wall_tile_middle:
				if tile_map_layer.get_cell_source_id(above_pos) == -1:
					tile_map_layer.set_cell(above_pos, 0, wall_tile_top)

func regenDungeon():
	grid.clear()
	rooms.clear()

	for child in get_children():
		if child is ColorRect:
			child.queue_free()

	initialize_grid()
	generateDungeon()
	draw_dungeon()
