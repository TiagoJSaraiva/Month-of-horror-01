# Noite

## Propósito
Controlar o tempo de uma noite (23:00 às 06:00), gerar o pedido no início e encerrar a ação dos personagens ao amanhecer.

## Componentes
- `night/night.tscn` / `night/night.gd`: `Night`. No `_ready`, gera o pedido (`OrderRules`, `NightOrder`). Ao amanhecer, desliga o processamento de `Actors` e emite `night_finished(order)`.
- `night/night_clock.gd`: `NightClock`. Avança o tempo, expõe `progress` (0 a 1) e `clock_minutes()`, e emite `dawn_reached` uma única vez.
- `night/night_time_rules.gd`: `NightTimeRules`, regras puras de progresso, hora do jogo e ângulos dos ponteiros.
- `Actors` (nó da cena da noite): tudo o que deve congelar no amanhecer (jogador e, nos próximos marcos, inimigos).

## Regras
- A noite dura 7 min reais (`duration_seconds` = 420 no `NightClock`), que valem as 7 horas do jogo. Para testar, reduza esse valor no inspetor.
- `night_number` (`@export` na `Night`, 1 por padrão) define o tamanho do pedido. A Run (M3) vai preencher esse valor.
- `fish_species` (`@export` na `Night`) lista as espécies sorteáveis no pedido.
- Amanhecer: `Actors` passa a `PROCESS_MODE_DISABLED`, então o jogador para de andar e de olhar. Mar, céu e balanço continuam.

## Sinais
- `NightClock.dawn_reached` → `Night._on_night_clock_dawn_reached`.
- `Night.night_finished(order: NightOrder)`: escutado pela `Main` (aviso na tela) e, no M3, pela Run (avaliação do pedido).

## Testes
- `test/unit/night_time_rules_test.gd`: progresso e limites, duração zero, 23:00, 02:30 e 06:00, ponteiros às 06:00 e às 23:30.
- `test/scenes/night_dawn_test.gd`: com a noite de 0,5 s, `night_finished` é emitido com um pedido de 3 peixes, e o jogador não anda mais depois do amanhecer.
