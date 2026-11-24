# Noite

## Propósito
Controlar o tempo de uma noite (23:00 às 06:00), gerar o pedido no início e encerrar a ação dos personagens ao amanhecer ou com a morte do jogador.

## Componentes
- `night/night.tscn` / `night/night.gd`: `Night`. No `_ready`, gera o pedido (`OrderRules`, `NightOrder`). Ao amanhecer, desliga o processamento de `Actors` e emite `night_finished(order)`.
- `night/night_clock.gd`: `NightClock`. Avança o tempo, expõe `progress` (0 a 1) e `clock_minutes()`, e emite `dawn_reached` uma única vez.
- `night/night_time_rules.gd`: `NightTimeRules`, regras puras de progresso, hora do jogo e ângulos dos ponteiros.
- `night/storm.gd`: `Storm`, a tempestade da noite; a `Night` sorteia e repassa a intensidade (ver `docs/sistemas/tempestade.md`).
- `Actors` (nó da cena da noite): tudo o que deve congelar no amanhecer (jogador e, nos próximos marcos, inimigos).
- `night/wall_clock.tscn` / `night/wall_clock.gd`: `WallClock`, relógio de ponteiros na parede da frente da cabine. Lê o `NightClock` por `@export` (decisão 0006). É a única forma de saber a hora: o diário não mostra.
- `Sky3D` (nó do addon Sky3D, um `WorldEnvironment`; decisão 0016): céu com sol, lua com fases, estrelas, nuvens e neblina. Cria sozinho os filhos `SunLight`, `MoonLight`, `SkyDome` e `TimeOfDay` ao entrar na árvore. Usa `night/sky_environment.tres`, um `Environment` sem céu próprio (o addon monta o material), compartilhado com o `BoatSway`.
- `night/sky_driver.gd`: `SkyDriver`, a ponte entre o jogo e o Sky3D. Desliga o relógio do addon, escreve o horário do `NightClock` em `Sky3D.current_time` a cada frame e aplica a tempestade (`set_storm_strength`).

## Regras
- A noite dura 7 min reais (`duration_seconds` = 420 no `NightClock`), que valem as 7 horas do jogo. Para testar, reduza esse valor no inspetor.
- `night_number` (`@export` na `Night`, 1 por padrão) define o tamanho do pedido. A `Run` preenche esse valor, o bilhete da mesa (`table_note_text`, `table_note_pin`) e os bônus das cartas (`player_stats`, ver `docs/sistemas/cartas.md`) antes de a noite entrar na árvore.
- `fish_species` (`@export` na `Night`) lista as espécies sorteáveis no pedido.
- Amanhecer: `Actors` e a `Lighting` do barco passam a `PROCESS_MODE_DISABLED`, então o jogador para de andar e de olhar. Mar, céu e balanço continuam.
- Morte do jogador: o mesmo congelamento, e o `NightClock` também para. Só o primeiro fim vale: depois da morte não há amanhecer, e vice-versa.
- Céu (provisório, decisão 0016): o horário do jogo (23:00 a 06:00) vira o horário do Sky3D. O céu é calculado para o equador, longitude 0, sem fuso, em 14/03/2025 (lua cheia perto do equinócio): a lua cheia cruza a noite toda, passa perto do zênite e o sol nasce perto das 06:00. As estrelas e a Via Láctea giram com a hora; o céu clareia e avermelha a partir de cerca das 05:30.
## Sinais
- `NightClock.dawn_reached` → `Night._on_night_clock_dawn_reached`.
- `Night.night_finished(order: NightOrder)` → `Run._on_night_night_finished`: amanhecer, avaliação do pedido e próxima noite (ver `docs/sistemas/run.md`).
- `Player.health.died` → `Night._on_player_health_died` → `Night.player_died` → `Run._on_night_player_died`: fim de run por morte.

## Testes
- `test/unit/night_time_rules_test.gd`: progresso e limites, duração zero, 23:00, 02:30 e 06:00, ponteiros às 06:00 e às 23:30.
- Céu conferido com captura de tela: estrelas às 23:00, 00:30 e 03:00, lua cheia no alto, amanhecer às 05:30 e 05:55, e a tempestade sem estrelas.
- `test/scenes/night_dawn_test.gd`: com a noite de 0,5 s, `night_finished` é emitido com um pedido de 3 peixes, e o jogador não anda mais depois do amanhecer.
