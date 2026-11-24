class_name RunState
extends RefCounted
## Estado de uma run: noite atual, pedidos falhados, passe livre, resultado da última noite,
## morte do jogador, cartas (pool restante, equipadas e rerolls) e o que vale pontos no fim.
## Pertence à cena Run, que é recriada a cada run nova (decisão 0013).

## Falhas que encerram a run. Não precisam ser em noites seguidas.
const MAX_FAILURES := 3
const CARD_SLOTS := 3
const REROLLS_PER_RUN := 3

var night_number: int = 1
var failures: int = 0
var free_pass_used: bool = false
var last_outcome: RunRules.Outcome = RunRules.Outcome.NONE
var died: bool = false
## Cartas que ainda podem aparecer nas seleções. Carta escolhida sai e não volta.
var card_pool: Array[CardData] = []
var equipped: Array[CardData] = []
var rerolls_left: int = REROLLS_PER_RUN
## Noites cumpridas (com passe livre) e peixes entregues: viram pontos no fim da run.
var nights_completed: int = 0
var fish_delivered: int = 0


## A run acaba na terceira falha ou com a morte do jogador.
func is_over() -> bool:
	return failures >= MAX_FAILURES or died


func lives_left() -> int:
	return maxi(MAX_FAILURES - failures, 0)


## Fecha a noite com o que faltou entregar. Se a run continua, passa para a próxima noite.
func finish_night(missing_fish: int) -> RunRules.Outcome:
	var outcome: RunRules.Outcome = RunRules.evaluate_night(missing_fish, not free_pass_used)
	if outcome == RunRules.Outcome.FREE_PASS:
		free_pass_used = true
	elif outcome == RunRules.Outcome.FAILED:
		failures += 1
	if outcome != RunRules.Outcome.FAILED:
		nights_completed += 1
	last_outcome = outcome
	if not is_over():
		night_number += 1
	return outcome


## O jogador morreu durante a noite: a run acaba sem avaliar o pedido.
func die() -> void:
	died = true


## Começa a run com uma cópia das cartas do pool.
func start_card_pool(cards: Array[CardData]) -> void:
	card_pool = cards.duplicate()


func slots_full() -> bool:
	return equipped.size() >= CARD_SLOTS


## Equipa a carta num slot livre e a tira do pool. Devolve false com os slots cheios ou se a
## carta não está no pool.
func choose(card: CardData) -> bool:
	if slots_full() or not card_pool.has(card):
		return false
	equipped.append(card)
	card_pool.erase(card)
	return true


## Troca uma carta equipada pela nova. A nova sai do pool e a antiga não volta para ele.
func replace(old_card: CardData, new_card: CardData) -> bool:
	var slot: int = equipped.find(old_card)
	if slot == -1 or not card_pool.has(new_card):
		return false
	equipped[slot] = new_card
	card_pool.erase(new_card)
	return true


## Recusar a seleção só vale com os slots cheios. A carta recusada continua no pool.
func can_refuse() -> bool:
	return slots_full()


## Gasta um reroll. Devolve false quando acabaram.
func use_reroll() -> bool:
	if rerolls_left <= 0:
		return false
	rerolls_left -= 1
	return true


## Peixes guardados no freezer numa noite, inclusive a noite em que a run acabou.
func add_delivered_fish(count: int) -> void:
	fish_delivered += maxi(count, 0)


## Pontos de meta-progressão ganhos até agora.
func points() -> int:
	return MetaRules.run_points(nights_completed, fish_delivered)


## Bônus das cartas equipadas somados aos dos upgrades permanentes, para a próxima noite.
func player_stats(upgrade_percents: Dictionary[StatModifier.Stat, float] = {}) -> PlayerStats:
	return PlayerStats.from_sources(equipped, upgrade_percents)
