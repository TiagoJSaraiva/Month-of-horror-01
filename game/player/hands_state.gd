class_name HandsState
extends RefCounted
## O que as mãos do jogador estão fazendo, uma coisa por vez: a ferramenta (vara; arma no
## M5), o diário aberto ou um item carregado com as duas mãos (peixe, galão, lâmpada).

signal changed

enum Mode { TOOL, JOURNAL, CARRYING }

var mode: Mode = Mode.TOOL
## A ferramenta está em uso (linha na água): nada mais pode ocupar as mãos até ela parar.
var tool_busy: bool = false
var carried_item: ItemData
var carried_amount: int = 0


func can_use_tool() -> bool:
	return mode == Mode.TOOL


## Pegar algo com as duas mãos exige a ferramenta parada.
func can_take_item() -> bool:
	return mode == Mode.TOOL and not tool_busy


func is_carrying() -> bool:
	return mode == Mode.CARRYING


func is_carrying_item(item: ItemData) -> bool:
	return is_carrying() and item != null and carried_item == item


## Abre ou fecha o diário. Devolve false quando as mãos estão ocupadas.
func toggle_journal() -> bool:
	if mode == Mode.JOURNAL:
		_set_mode(Mode.TOOL)
		return true
	if mode == Mode.TOOL and not tool_busy:
		_set_mode(Mode.JOURNAL)
		return true
	return false


## Passa a carregar um item. Devolve false quando as mãos não estão livres.
func start_carrying(item: ItemData, amount: int) -> bool:
	if not can_take_item() or item == null or amount <= 0:
		return false
	carried_item = item
	carried_amount = amount
	_set_mode(Mode.CARRYING)
	return true


## Esvazia as mãos. Quem chama lê [member carried_item] e [member carried_amount] antes.
func stop_carrying() -> void:
	if mode != Mode.CARRYING:
		return
	carried_item = null
	carried_amount = 0
	_set_mode(Mode.TOOL)


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	changed.emit()
