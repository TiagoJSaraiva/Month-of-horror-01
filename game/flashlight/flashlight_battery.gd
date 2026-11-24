class_name FlashlightBattery
extends RefCounted
## Carga da bateria da lanterna, em segundos de luz. Só gasta com a lanterna acesa e só
## recarrega de uma vez, com pilhas novas (sem recarga gradual no MVP).

var capacity_seconds: float
var charge_seconds: float


func _init(capacity: float) -> void:
	capacity_seconds = maxf(capacity, 0.0)
	charge_seconds = capacity_seconds


func is_empty() -> bool:
	return charge_seconds <= 0.0


func is_full() -> bool:
	return charge_seconds >= capacity_seconds


func ratio() -> float:
	if capacity_seconds <= 0.0:
		return 0.0
	return charge_seconds / capacity_seconds


## Gasta [param delta] segundos de luz. Devolve true só no passo em que a carga acaba.
func drain(delta: float) -> bool:
	if is_empty() or delta <= 0.0:
		return false
	charge_seconds = maxf(charge_seconds - delta, 0.0)
	return is_empty()


## Pilhas novas: a carga volta ao máximo.
func recharge() -> void:
	charge_seconds = capacity_seconds
