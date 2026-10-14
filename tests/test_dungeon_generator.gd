extends SceneTree

const Generator = preload("res://scripts/dungeon_generator.gd")


func _initialize() -> void:
	var generator = Generator.new()
	for seed_value in range(1, 101):
		var result: Dictionary = generator.generate(seed_value)
		assert(result.get("ok", false), "Mapa inválido para seed %d: %s" % [seed_value, result.get("error", "erro desconhecido")])
		assert(result["width"] == 48)
		assert(result["height"] == 28)
		assert(result["grid"].size() == 28)
		for row in result["grid"]:
			assert(row.size() == 48)
		assert(generator.is_floor(result["grid"], result["start"]))
		assert(generator.is_floor(result["grid"], result["exit"]))
		assert(result["reachable_count"] > 0)

	print("OK: 100 seeds geraram mapas 48x28 com entrada e saída conectadas.")
	quit()
