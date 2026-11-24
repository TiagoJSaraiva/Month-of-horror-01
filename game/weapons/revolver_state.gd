class_name RevolverState
extends RefCounted
## Munição, cadência e recarga do revólver. A reserva é infinita: recarregar sempre enche o
## tambor.

signal changed

var capacity: int
var loaded: int
## Segundos mínimos entre dois tiros.
var fire_interval: float
var reload_seconds: float

var _cooldown: float = 0.0
var _reloading: bool = false
var _reload_elapsed: float = 0.0


func _init(cylinder_size: int, interval: float, reload_time: float) -> void:
	capacity = maxi(cylinder_size, 0)
	loaded = capacity
	fire_interval = maxf(interval, 0.0)
	reload_seconds = maxf(reload_time, 0.0)


func is_reloading() -> bool:
	return _reloading


func can_fire() -> bool:
	return loaded > 0 and _cooldown <= 0.0 and not _reloading


## Gasta uma bala. Devolve false quando não dá para atirar agora.
func fire() -> bool:
	if not can_fire():
		return false
	loaded -= 1
	_cooldown = fire_interval
	changed.emit()
	return true


## Começa a recarregar. Devolve false com o tambor cheio ou já recarregando.
func start_reload() -> bool:
	if _reloading or loaded >= capacity:
		return false
	_reloading = true
	_reload_elapsed = 0.0
	changed.emit()
	return true


## Interrompe a recarga (trocou de ferramenta, por exemplo). As balas do tambor ficam.
func cancel_reload() -> void:
	if not _reloading:
		return
	_reloading = false
	changed.emit()


func update(delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)
	if not _reloading:
		return
	_reload_elapsed += delta
	if _reload_elapsed >= reload_seconds:
		_reloading = false
		loaded = capacity
		changed.emit()
