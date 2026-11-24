# Meta-progressão

## Propósito
Dar ao jogador progresso entre as runs: pontos ganhos no fim de cada run compram upgrades permanentes.

## Componentes
- `meta/upgrade_data.gd` + `meta/upgrades/{health,damage,rod_power}.tres`: `UpgradeData` (Resource), um upgrade permanente: atributo (`StatModifier.Stat`), percentual por nível, nível máximo e custo base.
- `meta/meta_rules.gd`: `MetaRules`, regras puras dos pontos da run e do custo dos upgrades.
- `meta/meta_state.gd`: `MetaState` (`RefCounted`), pontos e níveis, com compra, percentual por atributo e save em `ConfigFile`.

- `autoload/meta_progress.gd`: autoload `MetaProgress` (decisão 0015). Carrega o save no início, grava a cada mudança e expõe os upgrades do MVP. `use_save_path(path)` troca o arquivo (usado pelos testes).

## Regras
- Pontos da run: 10 por noite cumprida e 1 por peixe entregue.
- Upgrades: vida, dano e poder da vara. Cada nível dá +10% no atributo, até o nível 5. O nível N custa 20 × N (20, 40, 60, 80, 100; 300 para completar um).
- Save: `ConfigFile` com a seção `meta` (`version`, `points`) e a seção `levels` (nível por id de upgrade). Arquivo ausente, de outra versão ou inválido começa do zero, sem travar.

## Testes
- `test/unit/meta_rules_test.gd`: pontos da run, custo crescente, compra só com pontos e abaixo do máximo, e os 3 upgrades do MVP abrindo com os atributos certos.
- `test/unit/meta_state_test.gd`: comprar gasta pontos e sobe o nível, percentual por atributo, nível para no máximo, save e load mantêm pontos e níveis, arquivo ausente ou estragado começa do zero.
