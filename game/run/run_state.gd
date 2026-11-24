class_name RunState
extends RefCounted
## Estado de uma run: noite atual, pedidos falhados, passe livre, resultado da última noite e
## morte do jogador.
## Pertence à cena Run, que é recriada a cada run nova (decisão 0013).

## Falhas que encerram a run. Não precisam ser em noites seguidas.
const MAX_FAILURES := 3

var night_number: int = 1
var failures: int = 0
var free_pass_used: bool = false
var last_outcome: RunRules.Outcome = RunRules.Outcome.NONE
var died: bool = false


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
	last_outcome = outcome
	if not is_over():
		night_number += 1
	return outcome


## O jogador morreu durante a noite: a run acaba sem avaliar o pedido.
func die() -> void:
	died = true
