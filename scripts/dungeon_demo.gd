extends Node2D

const TILE_SIZE: int = 16
const MAP_ORIGIN := Vector2(16, 78)

var generator := DungeonGenerator.new()
var map_data: Dictionary = {}
var seed_input: LineEdit
var status_label: Label
var room_label: Label


func _ready() -> void:
	_build_ui()
	_generate_map()


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var panel := PanelContainer.new()
	panel.position = Vector2(12, 10)
	panel.size = Vector2(776, 58)
	layer.add_child(panel)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)

	var title := Label.new()
	title.text = "D&D ROGUE  |  MASMORRA PROCEDURAL"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(title)

	seed_input = LineEdit.new()
	seed_input.placeholder_text = "Seed (opcional)"
	seed_input.custom_minimum_size = Vector2(130, 0)
	seed_input.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(seed_input)

	var generate_button := Button.new()
	generate_button.text = "Gerar mapa"
	generate_button.custom_minimum_size = Vector2(110, 40)
	generate_button.pressed.connect(_on_generate_pressed)
	row.add_child(generate_button)

	var info_panel := PanelContainer.new()
	info_panel.position = Vector2(12, 528)
	info_panel.size = Vector2(776, 26)
	layer.add_child(info_panel)

	var info_row := HBoxContainer.new()
	info_row.add_theme_constant_override("separation", 16)
	info_panel.add_child(info_row)

	status_label = Label.new()
	status_label.text = "Preparando..."
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_row.add_child(status_label)

	room_label = Label.new()
	room_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	info_row.add_child(room_label)


func _on_generate_pressed() -> void:
	var requested_seed := -1
	var text_value := seed_input.text.strip_edges()
	if not text_value.is_empty():
		if not text_value.is_valid_int():
			status_label.text = "Seed inválida: use um número inteiro."
			return
		requested_seed = int(text_value)
	_generate_map(requested_seed)


func _generate_map(requested_seed: int = -1) -> void:
	map_data = generator.generate(requested_seed)
	if bool(map_data.get("ok", false)):
		status_label.text = "Seed: %s  |  Entrada verde  |  Saída vermelha  |  Mapa conectado" % str(map_data["seed"])
		room_label.text = "Salas: %d  •  Grade: 48 × 28" % map_data["rooms"].size()
	else:
		status_label.text = "Falha ao gerar: %s" % str(map_data.get("error", "erro desconhecido"))
		room_label.text = "Tente gerar novamente"
	queue_redraw()


func _draw() -> void:
	if map_data.is_empty() or not bool(map_data.get("ok", false)):
		return
	var grid: Array = map_data["grid"]
	var map_size := Vector2(DungeonGenerator.MAP_WIDTH * TILE_SIZE, DungeonGenerator.MAP_HEIGHT * TILE_SIZE)
	draw_rect(Rect2(MAP_ORIGIN - Vector2.ONE, map_size + Vector2(2, 2)), Color(0.025, 0.03, 0.04), true)

	for y in range(DungeonGenerator.MAP_HEIGHT):
		for x in range(DungeonGenerator.MAP_WIDTH):
			var rect := Rect2(MAP_ORIGIN + Vector2(x, y) * TILE_SIZE, Vector2(TILE_SIZE - 1, TILE_SIZE - 1))
			if int(grid[y][x]) == DungeonGenerator.FLOOR:
				draw_rect(rect, Color(0.43, 0.40, 0.34), true)
			else:
				draw_rect(rect, Color(0.13, 0.15, 0.18), true)

	_draw_marker(map_data["start"], Color(0.25, 0.9, 0.42))
	_draw_marker(map_data["exit"], Color(0.95, 0.28, 0.25))


func _draw_marker(cell: Vector2i, color: Color) -> void:
	var center := MAP_ORIGIN + Vector2(cell) * TILE_SIZE + Vector2.ONE * TILE_SIZE * 0.5
	draw_circle(center, TILE_SIZE * 0.34, color)
