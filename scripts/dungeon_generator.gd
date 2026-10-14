class_name DungeonGenerator
extends RefCounted
## Gera uma masmorra lógica fixa para Godot 4, sem dependência de tiles ou cenas.
## A grade usa 0 para parede e 1 para chão.

const MAP_WIDTH: int = 48
const MAP_HEIGHT: int = 28
const MIN_ROOMS: int = 5
const MAX_ROOMS: int = 9
const MAX_PLACEMENT_ATTEMPTS: int = 300
const WALL: int = 0
const FLOOR: int = 1

var _rng := RandomNumberGenerator.new()


func generate(seed_value: int = -1) -> Dictionary:
	var actual_seed := seed_value
	if actual_seed < 0:
		actual_seed = randi()
	_rng.seed = actual_seed

	var grid: Array = []
	for y in range(MAP_HEIGHT):
		var row: Array[int] = []
		row.resize(MAP_WIDTH)
		row.fill(WALL)
		grid.append(row)

	var rooms: Array[Rect2i] = []
	var target_rooms := _rng.randi_range(MIN_ROOMS, MAX_ROOMS)
	var attempts := 0

	while rooms.size() < target_rooms and attempts < MAX_PLACEMENT_ATTEMPTS:
		attempts += 1
		var room_width := _rng.randi_range(5, 10)
		var room_height := _rng.randi_range(4, 7)
		var room_x := _rng.randi_range(1, MAP_WIDTH - room_width - 1)
		var room_y := _rng.randi_range(1, MAP_HEIGHT - room_height - 1)
		var candidate := Rect2i(room_x, room_y, room_width, room_height)

		if _overlaps_with_padding(candidate, rooms):
			continue

		rooms.append(candidate)
		_carve_room(grid, candidate)

	# Um mapa com menos de duas salas não atende ao fluxo entrada-saída.
	if rooms.size() < 2:
		return {
			"ok": false,
			"error": "Não foi possível posicionar pelo menos duas salas.",
			"seed": actual_seed,
			"grid": grid,
			"rooms": rooms,
		}

	# Ordenar por X torna a progressão previsível: entrada à esquerda, saída à direita.
	rooms.sort_custom(func(a: Rect2i, b: Rect2i) -> bool:
		return _room_center(a).x < _room_center(b).x
	)

	for i in range(rooms.size() - 1):
		_carve_corridor(grid, _room_center(rooms[i]), _room_center(rooms[i + 1]))

	var start: Vector2i = _room_center(rooms[0])
	var exit: Vector2i = _room_center(rooms[rooms.size() - 1])
	var reachable := _flood_fill(grid, start)
	var valid := reachable.has(exit)

	return {
		"ok": valid,
		"error": "" if valid else "A saída não é alcançável a partir da entrada.",
		"seed": actual_seed,
		"width": MAP_WIDTH,
		"height": MAP_HEIGHT,
		"grid": grid,
		"rooms": rooms,
		"start": start,
		"exit": exit,
		"reachable_count": reachable.size(),
	}


func is_floor(grid: Array, cell: Vector2i) -> bool:
	if cell.x < 0 or cell.x >= MAP_WIDTH or cell.y < 0 or cell.y >= MAP_HEIGHT:
		return false
	return int(grid[cell.y][cell.x]) == FLOOR


func _overlaps_with_padding(candidate: Rect2i, rooms: Array[Rect2i]) -> bool:
	var padded := Rect2i(candidate.position - Vector2i.ONE, candidate.size + Vector2i(2, 2))
	for room in rooms:
		if padded.intersects(room):
			return true
	return false


func _room_center(room: Rect2i) -> Vector2i:
	return room.position + Vector2i(room.size.x / 2, room.size.y / 2)


func _carve_room(grid: Array, room: Rect2i) -> void:
	for y in range(room.position.y, room.end.y):
		for x in range(room.position.x, room.end.x):
			grid[y][x] = FLOOR


func _carve_corridor(grid: Array, from_cell: Vector2i, to_cell: Vector2i) -> void:
	# Alterna a ordem dos eixos para evitar corredores sempre em forma de L igual.
	if _rng.randf() < 0.5:
		_carve_horizontal(grid, from_cell.x, to_cell.x, from_cell.y)
		_carve_vertical(grid, from_cell.y, to_cell.y, to_cell.x)
	else:
		_carve_vertical(grid, from_cell.y, to_cell.y, from_cell.x)
		_carve_horizontal(grid, from_cell.x, to_cell.x, to_cell.y)


func _carve_horizontal(grid: Array, x1: int, x2: int, y: int) -> void:
	for x in range(mini(x1, x2), maxi(x1, x2) + 1):
		grid[y][x] = FLOOR


func _carve_vertical(grid: Array, y1: int, y2: int, x: int) -> void:
	for y in range(mini(y1, y2), maxi(y1, y2) + 1):
		grid[y][x] = FLOOR


func _flood_fill(grid: Array, origin: Vector2i) -> Dictionary:
	var visited: Dictionary = {}
	var queue: Array[Vector2i] = [origin]
	visited[origin] = true
	var cursor := 0
	var directions: Array[Vector2i] = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT,
	]

	while cursor < queue.size():
		var current: Vector2i = queue[cursor]
		cursor += 1
		for direction in directions:
			var next: Vector2i = current + direction
			if next.x < 0 or next.x >= MAP_WIDTH or next.y < 0 or next.y >= MAP_HEIGHT:
				continue
			if visited.has(next) or int(grid[next.y][next.x]) != FLOOR:
				continue
			visited[next] = true
			queue.append(next)

	return visited
