# Gerador procedural de masmorras

Protótipo isolado para Godot 4, escrito em GDScript puro e pensado para desenvolvimento pelo Android.

## Executar a demonstração

1. Abra a pasta do projeto no editor Godot 4 para Android; ela deve conter `project.godot`.
2. Execute a cena principal.
3. Toque em **Gerar mapa** para criar outra masmorra.
4. Informe uma seed inteira para repetir o mesmo mapa; deixe o campo vazio para uma seed aleatória.

A demonstração desenha uma grade de 48 × 28 células. Verde indica entrada; vermelho indica saída.

## Testes

Com uma versão Godot 4 que ofereça execução por linha de comando:

```sh
godot --headless --path . --script res://tests/test_dungeon_generator.gd
```

O teste verifica 100 seeds, dimensões, entrada/saída no chão e a validação de conectividade.

## Limitações atuais

- O visual é provisório, desenhado por código; ainda não usa os tilesets do projeto.
- Não inclui inimigos, baús, portas, armadilhas, salas temáticas ou balanceamento.
- O teste automatizado e a abertura no runtime Godot 4 ainda precisam ser executados; a simulação equivalente em Python não substitui essa verificação.
