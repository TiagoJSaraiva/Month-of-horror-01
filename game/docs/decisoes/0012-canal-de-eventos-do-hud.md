# 0012 — Canal de eventos entre o mundo e o HUD

- **Data**: 2026-11
- **Status**: aceita

## Contexto
O mundo 3D roda dentro de um `SubViewport` de baixa resolução, e a interface fica na `Main`, em resolução nativa (decisão 0009). A partir do M2, componentes do jogador precisam mostrar coisas na tela: ação disponível na mira, dicas, isca atual e o minijogo de pesca. Do M4 em diante entram bateria, vida e munição.

Pela regra "sinal para cima", cada mensagem teria de ser reemitida no `Player` e de novo na `Night` até chegar à `Main`. Seriam vários sinais repetidos em duas camadas, crescendo a cada marco.

## Decisão
- Um Resource compartilhado, `ui/hud/hud_events.tres` (classe `HudEvents`), contém só sinais.
- Quem emite (componentes do mundo) e o `Hud` recebem o mesmo `.tres` por `@export`. Como o Godot carrega um recurso uma vez por caminho, todos usam a mesma instância.
- O canal carrega **apenas apresentação**: o que mostrar na tela. Regras e estado de jogo continuam em sinais e chamadas diretas (por exemplo, o freezer avisa a `Night` da entrega por sinal próprio, e não pelo canal).
- O HUD nunca decide nada de jogo a partir do canal.

## Alternativas descartadas
- **Reemitir sinais no `Player` e na `Night`**: explícito, mas repetitivo e frágil a cada mensagem nova.
- **Autoload de eventos**: dependência global escondida, sem aparecer no inspetor.
- **Passar a referência do HUD para baixo** (`Main` → `Night` → `Player` → componentes): cada componente passaria a depender da classe do HUD e a checar nulo.
- **HUD dentro do `SubViewport`**: dispensaria o canal, mas deixaria o texto em 576×324, contra a decisão 0009.

## Consequências
- A dependência fica visível no inspetor (`hud_events`). Testes podem usar o `.tres` ou um `HudEvents.new()` próprio.
- Risco de o canal virar depósito de tudo. Por isso a regra é só apresentação, e cada sinal novo deve ser documentado em `docs/arquitetura.md`.
