# Arquitetura

Visão do projeto como ele está **agora**. Atualize no mesmo passo de qualquer mudança nos itens abaixo.

## Visão geral
Roguelite noturno de pesca e sobrevivência em primeira pessoa, para Windows, com Forward+ (decisão 0010). A cada noite (23:00 às 06:00, 7 min reais) o jogador cumpre um pedido de peixes num barco ancorado, mantém a iluminação e sobrevive a inimigos. Entre as noites, escolhe cartas de boost. A run acaba com 3 pedidos falhos ou com a morte.

- Escopo, regras combinadas e roteiro de marcos: `docs/escopo-mvp.md`.
- Câmera e balanço do barco: decisão 0008. Visual retrô em baixa resolução: decisão 0009. Assets e registro de IA: decisão 0011 e `docs/assets.md`.

## Organização de pastas
Organização por feature: cada cena fica junto do seu script e dos recursos exclusivos dela.

```
<feature>/          ex.: player/, enemies/, ui/hud/
  <nome>.tscn
  <nome>.gd
components/         componentes reutilizados por mais de uma feature (ex.: health_component)
assets/             arte, áudio e fontes compartilhados
autoload/           singletons (cada um com decisão registrada)
test/unit/          testes de regras puras
test/scenes/        testes de cena (gdUnit4 scene runner)
```

## Cenas principais
- `player/player.tscn` → `Player` (`CharacterBody3D`) → `Head` (`MouseLook`) → `Camera3D`. Jogador em primeira pessoa (ver `docs/sistemas/movimento.md`).

## Autoloads
_Nenhum._

## Sinais entre sistemas
_Nenhum. Formato: `emissor.sinal` → `receptor._handler` — propósito._

## Input map
| Ação | Teclas | Uso |
|---|---|---|
| `move_forward`, `move_back`, `move_left`, `move_right` | WASD (tecla física) e setas | Movimento do jogador |
| `pause` | Esc | Solta o mouse (o menu de pausa assume no M8) |

## Camadas de colisão
- 1 — `world` — barco e cenário / detectada pelo jogador.
- 2 — `player` — jogador / ninguém detecta ainda.
