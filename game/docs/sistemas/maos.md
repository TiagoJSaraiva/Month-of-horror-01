# Mãos

## Propósito
Garantir que o jogador faça uma coisa por vez com as mãos: usar a ferramenta (vara; arma no M5), ler o diário ou carregar um peixe.

## Componentes
- `player/hands_state.gd`: `HandsState` (`RefCounted`), regras puras dos modos e do peixe carregado.
- `player/hands.gd`: `Hands`, filho da `Camera3D` do jogador (nome único `%Hands`).
  - Trata o Tab (`toggle_journal`) e o G (`drop_item`).
  - Abre e fecha o `Journal` (por `@export`, decisão 0006) e mostra o `CarriedFishModel`.
  - Ao largar, procura o convés 0,7 m à frente com uma consulta de raio; sem convés ali (além da amurada), larga aos pés.
- `player/journal.gd`: passivo, com `open()` e `close()`.
- `config/physics_layers.gd`: `PhysicsLayers`, máscaras das camadas de física usadas em consultas de raio.
- `components/interactable.gd`: `Interactable` (`Area3D`, camada `interactable`). Base de tudo com que o jogador interage: `get_prompt(hands)` devolve a ação disponível com estas mãos (vazio = nenhuma) e `interact(hands)` a executa.
- `player/interactor.gd`: `Interactor` (RayCast de 2,2 m na `Camera3D`, camadas `world` e `interactable`, detecta áreas). A cada frame de física manda a ação do `Interactable` na mira para o HUD (`prompt_changed`). Com E (`interact`), executa a ação. Paredes bloqueiam a mira.
- `boat/freezer.tscn` / `freezer.gd`: `Freezer` (`Interactable`), com um `StaticBody3D` que bloqueia o jogador. A área é 5 cm maior que o corpo para a mira achá-la primeiro. Só oferece ação carregando peixe ("Store X").
- `fish/dropped_fish.tscn` / `dropped_fish.gd`: `DroppedFish` (`Interactable`), peixe no convés, criado pela `Night` em `Items`. Só oferece ação com as mãos livres ("Pick up X").

## Regras
- Modos: `TOOL` (ferramenta pronta), `JOURNAL` (diário aberto) e `CARRYING` (peixe nas duas mãos).
- `tool_busy` (linha na água) impede abrir o diário e pegar coisas até a ferramenta parar. Quem liga e desliga é a ferramenta (`FishingRod`).
- O diário só abre no modo `TOOL` com a ferramenta parada; Tab de novo fecha.
- Carregar um peixe exige o modo `TOOL` com a ferramenta parada. Carregando, não dá para usar a ferramenta nem abrir o diário.
- O jogador carrega um "pacote" de uma espécie, com quantidade (a carta lendária de duplicar peixe gera 2).
- No M4, o "peixe carregado" vai precisar virar "item carregado" (galão, lâmpada, pilha).

## Sinais
- `HandsState.changed` → `Hands._on_state_changed`: atualiza o diário e o modelo carregado e reemite `Hands.changed`.
- `Hands.changed`: a ferramenta escuta para se esconder fora do modo `TOOL`.
- `Hands.fish_dropped(fish, amount, at)` → `Night._on_hands_fish_dropped`: cria o `DroppedFish` em `Items`.
- `Freezer.fish_stored(fish, amount)` → `Night._on_freezer_fish_stored`: `order.deliver()`.
- Pelo canal `HudEvents`: `prompt_changed`, emitido pelo `Interactor`.

## Testes
- `test/unit/hands_state_test.gd`: modo inicial, diário abre e fecha, diário bloqueado com linha na água ou carregando, carregar exige mãos livres, carregar bloqueia a ferramenta, peixe ou quantidade inválidos, soltar libera as mãos e cada mudança é anunciada.
- `test/scenes/freezer_delivery_test.gd`: com um Mackerel nas mãos, mirando o freezer, E entrega o peixe ao pedido e esvazia as mãos. Também confirma que a mira do Jolt detecta `Area3D`.
- Largar e pegar de novo foi conferido com captura de tela.
