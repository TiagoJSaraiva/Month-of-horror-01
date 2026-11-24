class_name NightOrder
extends RefCounted
## Pedido de uma noite: quantos peixes de cada espécie foram pedidos e quantos já foram
## guardados no freezer.

signal changed

var _required: Dictionary[FishData, int] = {}
var _delivered: Dictionary[FishData, int] = {}


func _init(required: Dictionary[FishData, int]) -> void:
	_required.assign(required)


## Espécies que fazem parte do pedido.
func species() -> Array[FishData]:
	var result: Array[FishData] = []
	result.assign(_required.keys())
	return result


func required_count(fish: FishData) -> int:
	return _required.get(fish, 0)


func delivered_count(fish: FishData) -> int:
	return _delivered.get(fish, 0)


## Registra peixes guardados no freezer. Peixes a mais ou de espécie fora do pedido também
## ficam registrados, mas não reduzem o que falta.
func deliver(fish: FishData, amount: int = 1) -> void:
	if amount <= 0:
		return
	_delivered[fish] = delivered_count(fish) + amount
	changed.emit()


## Total de peixes guardados no freezer, de qualquer espécie (contam para os pontos da run).
func delivered_total() -> int:
	var total := 0
	for fish: FishData in _delivered:
		total += _delivered[fish]
	return total


## Total de peixes que ainda faltam, somando todas as espécies do pedido.
func missing_total() -> int:
	var missing := 0
	for fish: FishData in _required:
		missing += maxi(required_count(fish) - delivered_count(fish), 0)
	return missing


func is_complete() -> bool:
	return missing_total() == 0
