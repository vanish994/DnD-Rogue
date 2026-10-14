# Gerador procedural de masmorras

Protótipo isolado para Godot 4, escrito em GDScript puro e pensado para ser editável pelo Android.

## Arquivos

- `scripts/dungeon_generator.gd`: geração da grade lógica, salas, corredores e verificação de conectividade.
- `tests/test_dungeon_generator.gd`: teste de fumaça para 100 seeds determinísticas.

## Uso

O script é independente de cenas e tilesets. Pode ser carregado por outro script:

```gdscript
const DungeonGenerator = preload("res://scripts/dungeon_generator.gd")

func build_dungeon() -> void:
	var generator = DungeonGenerator.new()
	var dungeon: Dictionary = generator.generate(12345)
	if not dungeon["ok"]:
		push_error(dungeon["error"])
		return

	var grid: Array = dungeon["grid"]
	var start: Vector2i = dungeon["start"]
	var exit: Vector2i = dungeon["exit"]
	# 0 = parede; 1 = chão.
	# Converta grid para TileMapLayer no sistema de renderização do jogo.
```

Passe uma seed inteira para reproduzir um mapa. Omitir a seed (ou usar um valor negativo) gera uma seed nova.

## Decisões de projeto

- Grade fixa: 48 colunas × 28 linhas.
- Salas retangulares separadas por pelo menos uma célula de parede quando posicionadas.
- Salas conectadas em sequência por corredores ortogonais.
- Entrada na sala mais à esquerda; saída na sala mais à direita.
- Busca em largura (BFS) confirma que a saída é alcançável.
- A lógica não depende de texturas, tiles, cenas, plugins ou extensões nativas.

## Testes

Com Godot 4 instalado, na raiz do projeto:

```sh
godot --headless --path . --script res://tests/test_dungeon_generator.gd
```

No Android, abra o projeto no editor Godot 4, confira se os caminhos estão corretos e execute o script de teste pelo fluxo de execução de scripts disponível na versão instalada.

## Limitações conhecidas

Este é um protótipo inicial, não um gerador final de níveis. Ainda não inclui salas temáticas, portas, posicionamento de inimigos/baús, colisões do TileMap, balanceamento de encontros ou validação de espaço para combate. Os testes automatizados precisam ser executados no Godot 4 antes de considerar a integração aprovada.
