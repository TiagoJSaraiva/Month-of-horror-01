# Arquitetura

Visão do projeto como ele está **agora**. Atualize no mesmo passo de qualquer mudança nos itens abaixo.

## Visão geral
Roguelite noturno de pesca e sobrevivência em primeira pessoa, para Windows, com Forward+ (decisão 0010). A cada noite (23:00 às 06:00, 7 min reais) o jogador cumpre um pedido de peixes num barco ancorado, mantém a iluminação e sobrevive a inimigos. Entre as noites, escolhe cartas de boost. A run acaba com 3 pedidos falhos ou com a morte.

- Escopo, regras combinadas e roteiro de marcos: `docs/escopo-mvp.md`.
- Estado da run: decisão 0013. Câmera e balanço do barco: decisão 0008. Visual retrô em baixa resolução: decisão 0009. Assets e registro de IA: decisão 0011 e `docs/assets.md`. Comunicação do mundo com o HUD: decisão 0012.

## Organização de pastas
Organização por feature: cada cena fica junto do seu script e dos recursos exclusivos dela.

```
<feature>/          ex.: player/, enemies/, ui/hud/
  <nome>.tscn
  <nome>.gd
components/         componentes reutilizados por mais de uma feature (ex.: health_component)
config/             constantes globais compartilhadas (ex.: PhysicsLayers)
assets/             arte, áudio e fontes compartilhados
autoload/           singletons (cada um com decisão registrada)
test/unit/          testes de regras puras
test/scenes/        testes de cena (gdUnit4 scene runner)
```

## Cenas principais
- `main/main.tscn` (cena principal) → `Main` (`Node`). Cria a `Run` a partir de `run_scene` (`@export`), troca por uma nova quando o jogador pede e controla a captura do mouse. Com o fim de run aberto, o clique não recaptura o mouse.
- `run/run.tscn` → `Run` (`Node`, dona do `RunState`; decisão 0013; ver `docs/sistemas/run.md`), com filhos nesta ordem:
  - `Hud`, primeiro, para conectar o canal antes do `_ready` do mundo (decisão 0012);
  - `LowResView` (`SubViewportContainer`, `stretch_shrink` 2, filtro nearest) → `SubViewport` (áudio 3D ligado), onde a `Run` cria cada `Night`. O 3D renderiza em 576×324, porque o stretch `canvas_items` fixa a base lógica em 1152×648, e é ampliado sem filtro (decisão 0009);
  - `TransitionOverlay`;
  - `RunOverScreen` (camada 2).

  A interface (`Hud` e overlays) fica fora do `SubViewport`, em resolução nativa.
- `ui/hud/hud.tscn` → `Hud` (`CanvasLayer`) → `Crosshair`, `Prompt`, `Hint`, `Bait`, `HintTimer`, `FishingMinigameView` e `NotePanel`. `reset()` limpa o que sobrou de uma noite. Recebe tudo pelo canal `HudEvents` (decisão 0012).
- `ui/run_over/run_over_screen.tscn` → `RunOverScreen` (`CanvasLayer`) → `Background` → `Content` com título, `%Message`, `%Nights` e `%NewRunButton`.
- `ui/transition_overlay/transition_overlay.tscn` → `TransitionOverlay` (`CanvasLayer`) → `Shade` (`ColorRect`) e `Message` (`Label`). Transições que podem ser aguardadas com `await`: `play_dawn()` escurece a tela e mostra "6:00 AM / The night is over."; `cover()` cobre de preto; `reveal(title)` mostra um título e revela a cena.
- `player/player.tscn` → `Player` (`CharacterBody3D`) → `Head` (`MouseLook`):
  - `Journal`, página com `Label3D`;
  - `Camera3D` → `Hands` (`%Hands`) → `CarriedItemModel`;
  - `Camera3D` → `FishingRod` → `Model`, `Aim` (RayCast) e `Bobber` (`top_level`);
  - `Camera3D` → `Interactor` (RayCast de interação).

  Jogador em primeira pessoa (ver `docs/sistemas/movimento.md`). Mãos em `docs/sistemas/maos.md`, diário em `docs/sistemas/pedido.md` e vara em `docs/sistemas/pesca.md`.
- `boat/boat.tscn` → `Boat` (`Node3D`) → `Hull` e `Cabin` (`CSGCombiner3D` com colisão, camada `world`). Barco greybox de 14×5 m com o convés em y = 1. A cabine fica na proa, com a porta voltada para a popa. Dentro dela ficam a mesa (caixa CSG; decisão 0011) e o `Freezer` (cena `boat/freezer.tscn`, `Interactable`).
- `night/night.tscn` → `Night` (`Node3D`, gera o pedido e encerra a noite; ver `docs/sistemas/noite.md`):
  - `NightClock`, o tempo da noite;
  - `WorldEnvironment` (`SkyCycle`) com `night/night_environment.tres` (céu procedural e neblina), que clareia no amanhecer;
  - `Boat`;
  - `WallClock`, o relógio de ponteiros da cabine, ligado ao `NightClock`;
  - `TableNote`, o bilhete dos clientes na mesa (ver `docs/sistemas/run.md`);
  - `Actors`, com tudo o que congela no amanhecer. Por enquanto só o `Player`, que começa na cabine olhando para a porta;
  - `Items`, itens largados no convés (`DroppedItem`);
  - `TempLights`, luzes provisórias até o M4;
  - `OutsideWorld` (`BoatSway`), com `Sea` (plano escuro provisório), `Water` (`WaterSurface`, a física da superfície) e `Moon` (`DirectionalLight3D` com `MoonArc`). Tudo o que fica fora do barco entra aqui (decisão 0008; ver `docs/sistemas/balanco.md`).

## Autoloads
_Nenhum._

## Sinais entre sistemas
- `NightClock.dawn_reached` → `Night._on_night_clock_dawn_reached` — congela `Actors` e encerra a noite.
- `Night.night_finished(order)` → `Run._on_night_night_finished` — amanhecer, avaliação do pedido e próxima noite ou fim de run.
- `Run.run_over` → `Main._on_run_run_over` — solta o mouse para a tela de fim de run.
- `RunOverScreen.new_run_requested` → `Run.new_run_requested` → `Main._on_run_new_run_requested` — troca a `Run` por uma nova.
- `NightOrder.changed` → `Journal._refresh` — o diário reescreve o texto a cada entrega. A ligação é feita em `Journal.display()`, que a `Night` chama via `Player.journal`.
- `Freezer.fish_stored(fish, amount)` → `Night._on_freezer_fish_stored` — entrega o peixe ao pedido.
- `Hands.item_dropped(item, amount, at)` → `Night._on_hands_item_dropped` — cria o item no convés, em `Items`.
- `Hands.changed` → `FishingRod._on_hands_changed` — a vara só aparece no modo `TOOL`.
- `FishingAttempt.state_changed(state)` → `FishingRod._on_attempt_state_changed` — boia, mensagens, minijogo e peixe para as mãos.

### Canal `HudEvents` (`ui/hud/hud_events.tres`, decisão 0012)
Só apresentação, do mundo para o `Hud`. Quem emite e o `Hud` recebem o `.tres` por `@export`.
- `prompt_changed(text)` — ação disponível no que está na mira; texto vazio esconde. O `Hud` acrescenta "[E]".
- `hint_requested(text, seconds)` — mensagem embaixo da tela; com `seconds` 0, fica até a próxima.
- `bait_changed(bait_name)` — isca atual.
- `minigame_started(minigame)` e `minigame_finished` — o `FishingMinigameView` desenha o minijogo lendo o modelo enquanto ele dura.
- `note_opened(text)` e `note_closed` — o `NotePanel` mostra o bilhete da mesa.

## Input map
| Ação | Teclas | Uso |
|---|---|---|
| `move_forward`, `move_back`, `move_left`, `move_right` | WASD (tecla física) e setas | Movimento do jogador |
| `toggle_journal` | Tab | Abre e fecha o diário (tratada pelo `Hands`) |
| `drop_item` | G | Larga o item carregado no convés |
| `primary_action` | Botão esquerdo | Lançar, fisgar e (segurando) puxar a linha |
| `secondary_action` | Botão direito | Recolher a linha ou desistir do peixe |
| `cycle_bait` | Q | Trocar a isca (com a linha fora d'água) |
| `interact` | E | Interagir com o que está na mira (guardar peixe, pegar peixe) |
| `pause` | Esc | Solta o mouse (o menu de pausa assume no M8) |

## Camadas de colisão
- 1 — `world` — barco e cenário / detectada pelo jogador.
- 2 — `player` — jogador / ninguém detecta ainda.
- 3 — `interactable` — objetos com que o jogador interage / detectada pela mira de interação (M2).
- 4 — `water` — superfície do mar / detectada pela mira da vara e pela boia (M2).

As máscaras dessas camadas estão em `config/physics_layers.gd` (`PhysicsLayers`), para as consultas de raio.
