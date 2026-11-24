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
- `main/main.tscn` (cena principal) → `Main` (`Node`, captura o mouse) → `LowResView` (`SubViewportContainer`, `stretch_shrink` 2, filtro nearest) → `SubViewport` (áudio 3D ligado) → `Night` (`%Night`). O 3D renderiza em 576×324, porque o stretch `canvas_items` fixa a base lógica em 1152×648, e é ampliado sem filtro (decisão 0009). A interface fica em irmãs de `LowResView`, em resolução nativa; hoje só `DawnOverlay`.
- `ui/dawn_overlay/dawn_overlay.tscn` → `DawnOverlay` (`CanvasLayer`) → `Shade` (`ColorRect`) e `Message` (`Label`). `play()` escurece a tela e mostra "6:00 AM / The night is over.".
- `player/player.tscn` → `Player` (`CharacterBody3D`) → `Head` (`MouseLook`) → `Camera3D`. Jogador em primeira pessoa (ver `docs/sistemas/movimento.md`).
- `boat/boat.tscn` → `Boat` (`Node3D`) → `Hull` e `Cabin` (`CSGCombiner3D` com colisão, camada `world`). Barco greybox de 14×5 m com o convés em y = 1. A cabine fica na proa, com a porta voltada para a popa, e dentro dela há caixas no lugar do freezer, da mesa e do relógio (decisão 0011).
- `night/night.tscn` → `Night` (`Node3D`, gera o pedido e encerra a noite; ver `docs/sistemas/noite.md`):
  - `NightClock`, o tempo da noite;
  - `WorldEnvironment` com `night/night_environment.tres` (céu procedural noturno e neblina);
  - `Boat`;
  - `Actors`, com tudo o que congela no amanhecer. Por enquanto só o `Player`, que começa na cabine olhando para a porta;
  - `TempLights`, luzes provisórias até o M4;
  - `OutsideWorld` (`BoatSway`), com `Sea` (plano escuro provisório) e `Moon` (`DirectionalLight3D`). Tudo o que fica fora do barco entra aqui (decisão 0008; ver `docs/sistemas/balanco.md`).

## Autoloads
_Nenhum._

## Sinais entre sistemas
- `NightClock.dawn_reached` → `Night._on_night_clock_dawn_reached` — congela `Actors` e encerra a noite.
- `Night.night_finished(order)` → `Main._on_night_night_finished` — toca o `DawnOverlay`.

## Input map
| Ação | Teclas | Uso |
|---|---|---|
| `move_forward`, `move_back`, `move_left`, `move_right` | WASD (tecla física) e setas | Movimento do jogador |
| `pause` | Esc | Solta o mouse (o menu de pausa assume no M8) |

## Camadas de colisão
- 1 — `world` — barco e cenário / detectada pelo jogador.
- 2 — `player` — jogador / ninguém detecta ainda.
