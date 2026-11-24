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
- `night/sky_cycle.gd`: `SkyCycle`, script do `WorldEnvironment`. Mistura as `SkyPalette` da noite e do amanhecer e depois puxa para a da tempestade por `storm_weight`. Escreve as cores do céu procedural, a luz ambiente e a cor e a densidade da neblina.
- `night/sky_palette.gd` + `night/sky_palettes/{night,dawn}.tres`: `SkyPalette` (Resource), com as cores e a neblina de um momento da noite, e `SkyPalette.mix(a, b, weight)`. A tempestade usa `night/sky_palettes/storm.tres`.
- `night/moon_arc.gd`: `MoonArc`, script da `Moon` (`DirectionalLight3D`). Orienta a luz pelo arco da lua e a apaga com `cloud_cover` (nuvens da tempestade).
- `night/sky_rules.gd`: `SkyRules`, regras puras da mistura do amanhecer e do arco da lua.

## Regras
- A noite dura 7 min reais (`duration_seconds` = 420 no `NightClock`), que valem as 7 horas do jogo. Para testar, reduza esse valor no inspetor.
- `night_number` (`@export` na `Night`, 1 por padrão) define o tamanho do pedido. A `Run` preenche esse valor e o bilhete da mesa (`table_note_text`, `table_note_pin`) antes de a noite entrar na árvore.
- `fish_species` (`@export` na `Night`) lista as espécies sorteáveis no pedido.
- Amanhecer: `Actors` e a `Lighting` do barco passam a `PROCESS_MODE_DISABLED`, então o jogador para de andar e de olhar. Mar, céu e balanço continuam.
- Morte do jogador: o mesmo congelamento, e o `NightClock` também para. Só o primeiro fim vale: depois da morte não há amanhecer, e vice-versa.
- Céu provisório até o M9: fica na paleta da noite até as 05:00 (`dawn_start` = 6/7) e chega à do amanhecer às 06:00, com suavização. O `SkyCycle` só reescreve o céu quando a mistura muda, porque cada mudança refaz a iluminação do céu. Ele escreve valores absolutos, já que o `Environment` é compartilhado entre noites.
- Lua: nasce a leste (+X) a 10° de elevação, passa pela popa (+Z) a 55° no meio da noite e se põe a oeste (-X), de novo a 10°. Ainda não há estrelas.

## Sinais
- `NightClock.dawn_reached` → `Night._on_night_clock_dawn_reached`.
- `Night.night_finished(order: NightOrder)` → `Run._on_night_night_finished`: amanhecer, avaliação do pedido e próxima noite (ver `docs/sistemas/run.md`).
- `Player.health.died` → `Night._on_player_health_died` → `Night.player_died` → `Run._on_night_player_died`: fim de run por morte.

## Testes
- `test/unit/night_time_rules_test.gd`: progresso e limites, duração zero, 23:00, 02:30 e 06:00, ponteiros às 06:00 e às 23:30.
- `test/unit/sky_rules_test.gd`: mistura zero antes das 05:00, um às 06:00 e nunca decrescente; lua baixa a leste e a oeste e no ponto mais alto no meio da noite.
- `test/scenes/night_dawn_test.gd`: com a noite de 0,5 s, `night_finished` é emitido com um pedido de 3 peixes, e o jogador não anda mais depois do amanhecer.
