# Mãos

## Propósito
Garantir que o jogador faça uma coisa por vez com as mãos: usar a ferramenta (vara; arma no M5), ler o diário ou carregar um item com as duas mãos (peixe, galão, lâmpada de reposição).

## Componentes
- `player/hands_state.gd`: `HandsState` (`RefCounted`), regras puras dos modos e do item carregado.
- `player/hands.gd`: `Hands`, filho da `Camera3D` do jogador (nome único `%Hands`).
  - Trata o Tab (`toggle_journal`) e o G (`drop_item`).
  - Abre e fecha o `Journal` (por `@export`, decisão 0006) e mostra o `CarriedItemModel` com a malha do item carregado.
  - Ao largar, procura o convés 0,7 m à frente com uma consulta de raio; sem convés ali (além da amurada), larga aos pés.
- `player/journal.gd`: passivo, com `open()` e `close()`.
- `items/item_data.gd`: `ItemData` (Resource), tudo o que pode ser carregado: `id`, `display_name` e `held_mesh`, a malha mostrada nas mãos e no convés. `FishData` estende `ItemData`.
- `config/physics_layers.gd`: `PhysicsLayers`, máscaras das camadas de física usadas em consultas de raio.
- `components/interactable.gd`: `Interactable` (`Area3D`, camada `interactable`). Base de tudo com que o jogador interage:
  - `get_prompt(hands)` devolve a ação disponível com estas mãos (vazio = nenhuma);
  - `interact(hands)` executa a ação;
  - `focus_exited()` é chamado quando a mira sai do objeto.
- `player/interactor.gd`: `Interactor` (RayCast de 2,2 m na `Camera3D`, camadas `world` e `interactable`, detecta áreas). A cada frame de física manda a ação do `Interactable` na mira para o HUD (`prompt_changed`) e avisa o alvo anterior com `focus_exited()` quando a mira muda. Com E (`interact`), executa a ação. Paredes bloqueiam a mira.
- `boat/freezer.tscn` / `freezer.gd`: `Freezer` (`Interactable`), com um `StaticBody3D` que bloqueia o jogador. A área é 5 cm maior que o corpo para a mira achá-la primeiro. Só oferece ação carregando um peixe ("Store X"); outros itens não entram.
- `items/dropped_item.tscn` / `dropped_item.gd`: `DroppedItem` (`Interactable`), item no convés, criado pela `Night` em `Items`, com a base da malha apoiada no chão. Só oferece ação com as mãos livres ("Pick up X").

## Regras
- Modos: `TOOL` (ferramenta pronta), `JOURNAL` (diário aberto) e `CARRYING` (item nas duas mãos).
- `tool_busy` (linha na água) impede abrir o diário e pegar coisas até a ferramenta parar. Quem liga e desliga é a ferramenta (`FishingRod`).
- O diário só abre no modo `TOOL` com a ferramenta parada; Tab de novo fecha.
- Carregar um item exige o modo `TOOL` com a ferramenta parada. Carregando, não dá para usar a ferramenta nem abrir o diário.
- O jogador carrega um "pacote" de um item, com quantidade (a carta lendária de duplicar peixe gera 2).
- Com G, o item carregado vai para o convés, seja qual for.

## Sinais
- `HandsState.changed` → `Hands._on_state_changed`: atualiza o diário e o modelo carregado e reemite `Hands.changed`.
- `Hands.changed`: a ferramenta escuta para se esconder fora do modo `TOOL`.
- `Hands.item_dropped(item, amount, at)` → `Night._on_hands_item_dropped`: cria o `DroppedItem` em `Items`.
- `Freezer.fish_stored(fish, amount)` → `Night._on_freezer_fish_stored`: `order.deliver()`.
- Pelo canal `HudEvents`: `prompt_changed`, emitido pelo `Interactor`.

## Testes
- `test/unit/hands_state_test.gd`: modo inicial, diário abre e fecha, diário bloqueado com linha na água ou carregando, carregar exige mãos livres, carregar bloqueia a ferramenta, item ou quantidade inválidos, comparação do item carregado, soltar libera as mãos e cada mudança é anunciada.
- `test/scenes/freezer_delivery_test.gd`: com um Mackerel nas mãos, mirando o freezer, E entrega o peixe ao pedido e esvazia as mãos. Também confirma que a mira do Jolt detecta `Area3D`.
- Largar e pegar de novo foi conferido com captura de tela.
