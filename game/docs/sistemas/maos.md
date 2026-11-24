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
- `Hands.fish_dropped(fish, amount, at)`: a `Night` cria o peixe no convés.

## Testes
- `test/unit/hands_state_test.gd`: modo inicial, diário abre e fecha, diário bloqueado com linha na água ou carregando, carregar exige mãos livres, carregar bloqueia a ferramenta, peixe ou quantidade inválidos, soltar libera as mãos e cada mudança é anunciada.
