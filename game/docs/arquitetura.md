# Arquitetura

Visão do projeto como ele está **agora**. Atualize no mesmo passo de qualquer mudança nos itens abaixo.

## Visão geral
Roguelite noturno de pesca e sobrevivência em primeira pessoa, para Windows, com Forward+ (decisão 0010). A cada noite (23:00 às 06:00, 7 min reais) o jogador cumpre um pedido de peixes num barco ancorado, mantém a iluminação e sobrevive a inimigos. Entre as noites, escolhe cartas de boost. A run acaba com 3 pedidos falhos ou com a morte.

- Escopo, regras combinadas e roteiro de marcos: `docs/escopo-mvp.md`.
- Estado da run: decisão 0013. Navegação dos inimigos: decisão 0014. Meta-progressão: decisão 0015. Mar e céu por addons: decisão 0016. Câmera e balanço do barco: decisão 0008. Visual retrô em baixa resolução: decisão 0009. Assets e registro de IA: decisão 0011 e `docs/assets.md`. Comunicação do mundo com o HUD: decisão 0012.

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
- `main/main.tscn` (cena principal) → `Main` (`Node`) → `MainMenu` e `UpgradesScreen` (ver `docs/sistemas/meta.md`). Abre no menu principal, cria a `Run` a partir de `run_scene` (`@export`), troca por uma nova ou volta ao menu quando o jogador pede e controla a captura do mouse. Com um menu aberto (seleção de cartas ou fim de run), o clique não recaptura o mouse.
- `run/run.tscn` → `Run` (`Node`, dona do `RunState`; decisão 0013; ver `docs/sistemas/run.md`), com filhos nesta ordem:
  - `Hud`, primeiro, para conectar o canal antes do `_ready` do mundo (decisão 0012);
  - `LowResView` (`SubViewportContainer`, `stretch_shrink` 2, filtro nearest) → `SubViewport` (áudio 3D ligado), onde a `Run` cria cada `Night`. O 3D renderiza em 576×324, porque o stretch `canvas_items` fixa a base lógica em 1152×648, e é ampliado sem filtro (decisão 0009);
  - `TransitionOverlay`;
  - `CardSelectionScreen` (camada 2), a seleção de cartas;
  - `PauseMenu` (camada 2, processa com o jogo pausado), a pausa;
  - `RunOverScreen` (camada 2).

  A interface (`Hud` e overlays) fica fora do `SubViewport`, em resolução nativa.
- `ui/hud/hud.tscn` → `Hud` (`CanvasLayer`) → `DamageFlash`, `Crosshair`, `Prompt`, `HoldBar`, `Hint`, `Bait`, `Ammo`, `Health` e `Battery` (rótulo e barra), `HintTimer`, `FishingMinigameView` e `NotePanel`. `reset()` limpa o que sobrou de uma noite. Recebe tudo pelo canal `HudEvents` (decisão 0012).
- `ui/run_over/run_over_screen.tscn` → `RunOverScreen` (`CanvasLayer`) → `Background` → `Content` com título, `%Message`, `%Nights` e `%NewRunButton`.
- `ui/transition_overlay/transition_overlay.tscn` → `TransitionOverlay` (`CanvasLayer`) → `Shade` (`ColorRect`) e `Message` (`Label`). Transições que podem ser aguardadas com `await`: `play_dawn()` escurece a tela e mostra "6:00 AM / The night is over."; `cover()` cobre de preto; `reveal(title)` mostra um título e revela a cena.
- `player/player.tscn` → `Player` (`CharacterBody3D`) → `Health` (vida; ver `docs/sistemas/combate.md`) e `Head` (`MouseLook`):
  - `Journal`, página com `Label3D`;
  - `Camera3D` → `Hands` (`%Hands`) → `CarriedItemModel`;
  - `Camera3D` → `FishingRod` → `Model`, `Aim` (RayCast) e `Bobber` (`top_level`);
  - `Camera3D` → `Interactor` (RayCast de interação);
  - `Camera3D` → `Flashlight` (`flashlight/flashlight.tscn`), a lanterna da mão esquerda, com `Model`, `Beam` (`SpotLight3D`) e `LightStun` (`ShapeCast3D` que atordoa);
  - `Camera3D` → `Revolver` (`weapons/revolver.tscn`), a arma da mão direita, com `Aim` (RayCast), `Model` e `MuzzleFlash`.

  Jogador em primeira pessoa (ver `docs/sistemas/movimento.md`). `Player.apply_stats(stats)` aplica os bônus das cartas aos componentes (`%FishingRod`, `%Revolver`, `%Flashlight`, `Health`). Mãos em `docs/sistemas/maos.md`, diário em `docs/sistemas/pedido.md`, vara em `docs/sistemas/pesca.md` e lanterna em `docs/sistemas/iluminacao.md`.
- `boat/boat.tscn` → `Boat` (`Node3D`) → `Hull` e `Cabin` (`CSGCombiner3D` com colisão, camada `world`). Barco greybox de 14×5 m com o convés em y = 1. A cabine fica na proa, com a porta voltada para a popa. Dentro dela ficam a mesa (caixa CSG; decisão 0011), o `Freezer` (cena `boat/freezer.tscn`, `Interactable`) e, dos dois lados da porta, as caixas `FuelCans` e `SpareBulbs` (`SupplyCrate`). Na mesa fica a `BatteryBox`, a caixa de pilhas da lanterna. O `Hull` tem 4 postes nas amuradas para as lâmpadas. O `Boat` está no grupo `boat_navigation`, e o filho `Navigation` (`BoatNavigation`) monta a malha de navegação ao carregar (decisão 0014; ver `docs/sistemas/inimigos.md`). O filho `Lighting` (`lighting/boat_lighting.tscn`) tem o gerador na popa, as 6 lâmpadas, as luzes de emergência e o sorteio de falhas (ver `docs/sistemas/iluminacao.md`).
- `night/night.tscn` → `Night` (`Node3D`, gera o pedido, aplica os bônus das cartas e a curva de dificuldade (`difficulty`) e encerra a noite; ver `docs/sistemas/noite.md` e `docs/sistemas/dificuldade.md`):
  - `NightClock`, o tempo da noite;
  - `Storm`, a tempestade sorteada para a noite, e `StormWeather`, a chuva e os relâmpagos (ver `docs/sistemas/tempestade.md`);
  - `Sky3D` (addon, decisão 0016) com `night/sky_environment.tres` e o `SkyDriver`, que o guia pelo `NightClock` e pela tempestade: estrelas, lua, amanhecer e céu fechado;
  - `Boat`;
  - `WallClock`, o relógio de ponteiros da cabine, ligado ao `NightClock`;
  - `TableNote`, o bilhete dos clientes na mesa (ver `docs/sistemas/run.md`);
  - `Actors`, com tudo o que congela no amanhecer: o `Player`, que começa na cabine olhando para a porta, o `FishmanSpawner` (`ClimbPoints` e os peixes-homens criados) e o `FlyerSpawner` (voadores da tempestade); ver `docs/sistemas/inimigos.md`;
  - `Items`, itens largados no convés (`DroppedItem`);
  - `OutsideWorld` (`BoatSway`), com `Sea` (plano escuro provisório), `Water` (`WaterSurface`, a física da superfície) e o `Environment` do céu girando junto (`sky_rotation`). Tudo o que fica fora do barco entra aqui (decisão 0008; ver `docs/sistemas/balanco.md`).

## Autoloads
_Nenhum._

## Sinais entre sistemas
- `NightClock.dawn_reached` → `Night._on_night_clock_dawn_reached` — congela `Actors` e a `Lighting` do barco e encerra a noite.
- `Night.night_finished(order)` → `Run._on_night_night_finished` — amanhecer, avaliação do pedido e próxima noite ou fim de run.
- `Player.health.died` → `Night._on_player_health_died` → `Night.player_died` → `Run._on_night_player_died` — a morte congela a noite e encerra a run com "YOU DIED".
- `Run.run_over` e `Run.menu_opened` → `Main._open_menu` — solta o mouse para a seleção de cartas e o fim de run; `Run.menu_closed` → `Main._close_menu` o recaptura.
- `CardSelectionScreen.card_chosen`, `card_replaced`, `refused` e `reroll_requested` → `Run` — a `Run` aplica no `RunState` e segue para a noite.
- `RunOverScreen.new_run_requested` → `Run.new_run_requested` → `Main._on_run_new_run_requested` — troca a `Run` por uma nova. `RunOverScreen.main_menu_requested` → `Run.main_menu_requested` → `Main._on_run_main_menu_requested` — libera a `Run` e volta ao menu.
- `PauseMenu.toggle_requested`, `resume_requested` e `quit_requested` → `Run` — pausa, continua ou sai; `Run.quit_to_menu_requested` → `Main` volta ao menu.
- `MainMenu.new_run_requested`, `upgrades_requested` e `quit_requested` e `UpgradesScreen.back_requested` → `Main`.
- `Storm.strength_changed(strength)` → `Night._on_storm_strength_changed` — a `Night` repassa a intensidade ao céu (`SkyDriver`), ao balanço, ao clima (`StormWeather`) e às falhas de manutenção.
- `NightOrder.changed` → `Journal._refresh` — o diário reescreve o texto a cada entrega. A ligação é feita em `Journal.display()`, que a `Night` chama via `Player.journal`.
- `Freezer.fish_stored(fish, amount)` → `Night._on_freezer_fish_stored` — entrega o peixe ao pedido.
- `Hands.item_dropped(item, amount, at)` → `Night._on_hands_item_dropped` — cria o item no convés, em `Items`.
- `Generator.running_changed(running)` → `BoatLighting._on_generator_running_changed` — energia das lâmpadas, luz de emergência e nível de luz.
- `Bulb.changed` → `BoatLighting._refresh_light_level` — lâmpada queimou ou foi trocada.
- `BoatLighting.light_level_changed(level)` → `FishmanSpawner._on_lighting_light_level_changed` — com a luz de volta, os peixes-homens fogem. O spawner também lê `light_level` a cada frame para o intervalo de surgimento.
- `Fishman.removed` → `FishmanSpawner._on_fishman_removed` — libera a vaga do peixe-homem que fugiu ou morreu.
- `Storm.started` e `Storm.ended` → `FlyerSpawner` — voadores só durante a tempestade. `Flyer.removed` → `FlyerSpawner._on_flyer_removed`.
- `Hands.changed` → `FishingRod._on_hands_changed` e `Revolver._on_hands_changed` — cada ferramenta só aparece pronta na mão; a vara cancela a pesca e o revólver a recarga ao sair da mão.
- `FishingAttempt.state_changed(state)` → `FishingRod._on_attempt_state_changed` — boia, mensagens, minijogo e peixe para as mãos.

### Canal `HudEvents` (`ui/hud/hud_events.tres`, decisão 0012)
Só apresentação, do mundo para o `Hud`. Quem emite e o `Hud` recebem o `.tres` por `@export`.
- `prompt_changed(text)` — ação disponível no que está na mira; texto vazio esconde. O `Hud` acrescenta "[E]".
- `hold_progress_changed(ratio)` — progresso da ação que exige segurar E; 0 esconde a `HoldBar`.
- `hint_requested(text, seconds)` — mensagem embaixo da tela; com `seconds` 0, fica até a próxima.
- `bait_changed(bait_name)` — isca atual.
- `minigame_started(minigame)` e `minigame_finished` — o `FishingMinigameView` desenha o minijogo lendo o modelo enquanto ele dura.
- `note_opened(text)` e `note_closed` — o `NotePanel` mostra o bilhete da mesa.
- `health_changed(current, maximum)` e `player_damaged` — vida do jogador na barra `Health` e clarão do `DamageFlash`; emitidos pelo `Health` do jogador.
- `ammo_changed(loaded, capacity, reloading)` — munição do revólver no rótulo `Ammo`.
- `battery_changed(ratio)` — carga da lanterna na barra `Battery`; a `Flashlight` só emite quando o percentual inteiro muda.

## Input map
| Ação | Teclas | Uso |
|---|---|---|
| `move_forward`, `move_back`, `move_left`, `move_right` | WASD (tecla física) e setas | Movimento do jogador |
| `toggle_journal` | Tab | Abre e fecha o diário (tratada pelo `Hands`) |
| `drop_item` | G | Larga o item carregado no convés |
| `primary_action` | Botão esquerdo | Com a vara: lançar, fisgar e (segurando) puxar a linha. Com o revólver: atirar |
| `secondary_action` | Botão direito | Recolher a linha ou desistir do peixe |
| `cycle_bait` | Q | Trocar a isca (com a linha fora d'água) |
| `interact` | E | Interagir com o que está na mira; algumas ações exigem segurar |
| `toggle_flashlight` | F (tecla física) | Liga e desliga a lanterna |
| `equip_rod`, `equip_revolver` | 1, 2 (tecla física) | Troca a ferramenta da mão direita (tratadas pelo `Hands`) |
| `reload` | R (tecla física) | Recarrega o revólver |
| `pause` | Esc | Abre e fecha o menu de pausa durante a noite (tratada pelo `PauseMenu`) |

## Camadas de colisão
- 1 — `world` — barco e cenário / detectada pelo jogador.
- 2 — `player` — jogador / colide com `world` e `enemy`; os peixes-homens colidem com ele.
- 3 — `interactable` — objetos com que o jogador interage / detectada pela mira de interação (M2).
- 4 — `water` — superfície do mar / detectada pela mira da vara e pela boia (M2).
- 5 — `enemy` — corpos dos inimigos / o `Fishman` colide com `world`, `player` e `enemy`; o `Flyer` só com `world`.
- 6 — `hurtbox` — áreas que recebem tiros (`Hurtbox` dos inimigos) / detectada pela mira do revólver.
- 7 — `light_sensor` — áreas que percebem a lanterna (`LightSensor` no rosto do peixe-homem) / detectada pelo `LightStun`.

As máscaras dessas camadas estão em `config/physics_layers.gd` (`PhysicsLayers`), para as consultas de raio.
