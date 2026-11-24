# Cartas

## Propósito
Dar ao jogador boosts escolhidos ao longo da run, que mudam atributos do jogador e do barco.

## Componentes
- `cards/stat_modifier.gd`: `StatModifier` (Resource), um bônus percentual sobre um atributo (`enum Stat`).
- `cards/card_data.gd`: `CardData` (Resource), com nome, descrição, raridade (`COMMON`, `RARE`, `LEGENDARY`) e os `modifiers`.
- `cards/data/*.tres`: as 9 cartas do MVP.
- `cards/card_pool.gd` + `cards/card_pool.tres`: `CardPool` (Resource), as cartas com que cada run começa, as chances de raridade (60% comum, 30% rara, o resto lendária) e o tamanho da seleção (3).
- `cards/card_rules.gd`: `CardRules`, regras puras do sorteio de raridade, da montagem da seleção e da soma dos percentuais.
- `run/run_state.gd`: o `RunState` guarda o pool restante (`card_pool`), as cartas equipadas (`equipped`, 3 slots) e os rerolls (`rerolls_left`, 3 por run), com `choose()`, `replace()`, `can_refuse()` e `use_reroll()`.
- `run/player_stats.gd`: `PlayerStats` (`RefCounted`), os bônus somados por atributo; dá o valor final de cada atributo a partir do valor base.

## Cartas do MVP
| Raridade | Carta | Efeito |
|---|---|---|
| Comum | Tough Skin | +20% de vida máxima |
| Comum | Steady Hands | +15% de poder de pesca |
| Comum | Hollow Points | +15% de dano da arma |
| Rara | Spare Cells | +50% de capacidade da bateria da lanterna |
| Rara | Extended Cylinder | +50% de balas no tambor |
| Rara | Sea Legs | +20% de velocidade de movimento |
| Lendária | Double Catch | 50% de chance de o peixe pescado vir em dobro |
| Lendária | Quick Fix | -50% no tempo de trocar lâmpada, consertar e reabastecer o gerador |
| Lendária | Gunslinger | -20% no tempo de recarga e +20% na cadência de tiro |

## Regras
- Seleção: cada uma das 3 cartas tem a raridade sorteada à parte. Nenhuma carta se repete na mesma seleção.
- Se a raridade sorteada não tem cartas no pool, vale a próxima disponível: primeiro as de baixo (lendária → rara → comum), depois as de cima. Com menos de 3 cartas no pool, a seleção fica menor; com o pool vazio, fica vazia.
- Bônus do mesmo atributo somam: +20% e +10% dão +30%. Tempos usam percentuais negativos, e o valor final nunca fica negativo. A chance de peixe em dobro é o percentual lido como fração (50% = 0,5).

- Slots e pool:
  - escolher uma carta a equipa num slot livre e a tira do pool;
  - com os 3 slots cheios, a nova carta substitui uma equipada ou a seleção é recusada;
  - a carta substituída não volta ao pool; a recusada continua nele;
  - recusar só vale com os slots cheios: com slot livre, escolher é obrigatório.
- 3 rerolls por run, cada um sorteia a seleção inteira de novo.

## Testes
- `test/unit/card_rules_test.gd`: raridade pelas chances, 3 cartas diferentes, raridade sem cartas cai para a próxima, ordem da troca de raridade, pool pequeno ou vazio, soma dos percentuais e o pool do MVP com 3 cartas de cada raridade.
- `test/unit/player_stats_test.gd`: sem cartas fica o valor base, cartas somam, percentual negativo encurta um tempo, valor nunca negativo, chance em fração.
- `test/unit/run_cards_test.gd`: escolher equipa e tira do pool, 3 slots no máximo, recusar só com os slots cheios, a substituída não volta, substituir exige carta equipada e carta do pool, 3 rerolls, o pool da run é uma cópia.
