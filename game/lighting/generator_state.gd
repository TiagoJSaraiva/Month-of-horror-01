class_name GeneratorState
extends RefCounted
## Estado do gerador do barco: combustível e quebra. Ele funciona com combustível e sem
## quebra, e só gasta combustível funcionando.

signal running_changed(running: bool)

## Quantos segundos de funcionamento cabem no tanque cheio.
var capacity_seconds: float
var fuel_seconds: float
var broken: bool = false


func _init(capacity: float) -> void:
	capacity_seconds = maxf(capacity, 0.0)
	fuel_seconds = capacity_seconds


func is_running() -> bool:
	return fuel_seconds > 0.0 and not broken


func fuel_ratio() -> float:
	if capacity_seconds <= 0.0:
		return 0.0
	return fuel_seconds / capacity_seconds


## O tanque aceita combustível sempre que não está cheio.
func needs_fuel() -> bool:
	return fuel_seconds < capacity_seconds


## Gasta o combustível de [param delta] segundos de funcionamento.
func consume(delta: float) -> void:
	if not is_running() or delta <= 0.0:
		return
	fuel_seconds = maxf(fuel_seconds - delta, 0.0)
	if not is_running():
		running_changed.emit(false)


func refuel() -> void:
	var was_running: bool = is_running()
	fuel_seconds = capacity_seconds
	_announce_change(was_running)


func break_down() -> void:
	var was_running: bool = is_running()
	broken = true
	_announce_change(was_running)


func repair() -> void:
	var was_running: bool = is_running()
	broken = false
	_announce_change(was_running)


func _announce_change(was_running: bool) -> void:
	if is_running() != was_running:
		running_changed.emit(is_running())
