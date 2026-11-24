# Movimento

## Propósito
Andar e olhar em primeira pessoa no convés e na cabine do barco.

## Componentes
- `player/player.tscn`: `Player` (`CharacterBody3D`) → `CollisionShape3D` (cápsula de 1,8 m), `Head` (`MouseLook`, a 1,6 m) → `Camera3D`.
- `player/player.gd`: lê o input, calcula a velocidade horizontal com `MovementRules`, aplica a gravidade e chama `move_and_slide`.
- `player/mouse_look.gd`: gira o `Head` na horizontal e a câmera na vertical. O corpo nunca gira.
- `player/movement_rules.gd`: regra pura da velocidade horizontal.

## Regras
- Velocidade de caminhada de 3,5 m/s, aceleração de 20 m/s² e frenagem de 25 m/s² (`@export` no `Player`).
- O input diagonal não anda mais rápido: a direção desejada é limitada a comprimento 1.
- Sem pulo e sem corrida. A amurada de 1,1 m impede cair no mar.
- Mouse: 0,15° por pixel e olhar vertical limitado a ±85° (`@export` no `MouseLook`). Usa `screen_relative` para não depender da escala do `SubViewport` (decisão 0009). Só gira com o mouse capturado.

## Sinais
Nenhum.

## Testes
- `test/unit/movement_rules_test.gd`: aceleração, limite de velocidade, diagonal, frenagem, `delta` grande e componente vertical ignorada.
- `test/scenes/player_movement_test.gd`: segurar `move_forward` por 1 s leva o jogador para frente numa faixa de 2 a 4,5 m, sem sair do chão.
