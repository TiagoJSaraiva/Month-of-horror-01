# Meta-progressão

## Propósito
Dar ao jogador progresso entre as runs: pontos ganhos no fim de cada run compram upgrades permanentes.

## Componentes
- `meta/upgrade_data.gd` + `meta/upgrades/{health,damage,rod_power}.tres`: `UpgradeData` (Resource), um upgrade permanente: atributo (`StatModifier.Stat`), percentual por nível, nível máximo e custo base.
- `meta/meta_rules.gd`: `MetaRules`, regras puras dos pontos da run e do custo dos upgrades.
- `meta/meta_state.gd`: `MetaState` (`RefCounted`), pontos e níveis, com compra, percentual por atributo e save em `ConfigFile`.
- `autoload/meta_progress.gd`: autoload `MetaProgress` (decisão 0015). Carrega o save no início, grava a cada mudança e expõe os upgrades do MVP. `use_save_path(path)` troca o arquivo (usado pelos testes).
- `ui/main_menu/main_menu.tscn` / `.gd`: `MainMenu` (`CanvasLayer`, camada 3). Título (o nome do projeto), pontos e os botões New run, Upgrades e Quit.
- `ui/upgrades/upgrades_screen.tscn` / `.gd`: `UpgradesScreen` (camada 3). Pontos e uma linha por upgrade: nome, nível N/5, bônus atual e `Buy (custo)`; o botão fica desligado sem pontos e vira `Max` no último nível. Back volta ao menu.
- `ui/pause_menu/pause_menu.tscn` / `.gd`: `PauseMenu` (`CanvasLayer`, camada 2, `process_mode` ALWAYS), filho da `Run`. Ouve o Esc (`pause`) e emite `toggle_requested`; tem Resume e Quit to menu, com o aviso de que sair conta como derrota.

## Regras
- Pontos da run: 10 por noite cumprida e 1 por peixe entregue.
- Upgrades: vida, dano e poder da vara. Cada nível dá +10% no atributo, até o nível 5. O nível N custa 20 × N (20, 40, 60, 80, 100; 300 para completar um).
- Save: `ConfigFile` com a seção `meta` (`version`, `points`) e a seção `levels` (nível por id de upgrade). Arquivo ausente, de outra versão ou inválido começa do zero, sem travar.

- Contagem na run (`RunState`): `nights_completed` sobe a cada noite cumprida, inclusive com passe livre; `fish_delivered` soma os peixes guardados no freezer a cada amanhecer e também na noite da morte.
- Pagamento: a `Run` paga `state.points()` no `MetaProgress` uma vez só, no fim da run, e a tela de fim de run mostra "Points earned: N".
- Fluxo: o jogo abre no menu principal. New run cria a `Run`; o fim de run oferece Start a new run ou Main menu.
- Pausa: o Esc só pausa com uma noite em andamento (`Run.can_pause`): não na seleção de cartas, no amanhecer ou no fim de run, porque pausar prenderia as transições. Pausar usa `get_tree().paused` e solta o mouse; Resume ou Esc de novo despausam.
- Quit to menu conta como derrota: soma os peixes entregues na noite, paga os pontos da run e volta ao menu principal (`Run.quit_to_menu_requested`).
- Os níveis comprados somam aos bônus das cartas: `PlayerStats.from_sources(cartas, MetaProgress.upgrade_percents())`.

## Testes
- `test/unit/meta_rules_test.gd`: pontos da run, custo crescente, compra só com pontos e abaixo do máximo, e os 3 upgrades do MVP abrindo com os atributos certos.
- `test/unit/meta_state_test.gd`: comprar gasta pontos e sobe o nível, percentual por atributo, nível para no máximo, save e load mantêm pontos e níveis, arquivo ausente ou estragado começa do zero.
- `test/unit/run_state_test.gd`: pontos contam as noites cumpridas (com passe livre) e os peixes entregues.
- `test/unit/player_stats_test.gd`: cartas e upgrades somam.
- `test/scenes/upgrade_purchase_test.gd`: com 50 pontos, comprar Health sobe para o nível 1, sobra 30, o botão do nível 2 (40) fica desligado e a compra está no arquivo (save de teste).
- `test/scenes/pause_quit_test.gd`: na noite, o Esc pausa e abre o menu; Quit to menu despausa, pede a volta ao menu e paga 1 ponto por peixe entregue (save de teste). Com a árvore pausada, o teste espera por frames, porque os timers do gdUnit4 também param.
- Conferidos com captura de tela: o menu principal, a tela de upgrades, a pausa e o fim de run com os pontos.
- `test/scenes/player_death_test.gd`: com 3 peixes entregues na noite da morte, a run paga 3 pontos (num save de teste).
