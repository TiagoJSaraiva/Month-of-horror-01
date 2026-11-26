class_name InteractionHold
extends RefCounted
## Progresso de uma ação que exige segurar a tecla de interação (trocar lâmpada, consertar o
## gerador). Quem segura chama [method advance] a cada frame; soltar ou mudar de alvo cancela.

var duration: float = 0.0
var elapsed: float = 0.0

var _active: bool = false


## Começa a contar uma ação que dura seconds, do zero.
func start(seconds: float) -> void:
	duration = maxf(seconds, 0.0)
	elapsed = 0.0
	_active = true


## Cancela a ação e zera o progresso.
func cancel() -> void:
	_active = false
	elapsed = 0.0


## Há uma ação sendo segurada.
func is_active() -> bool:
	return _active


## Soma o tempo segurado. Devolve true uma única vez, no frame em que a ação completa.
func advance(delta: float) -> bool:
	if not _active:
		return false
	elapsed = minf(elapsed + delta, duration)
	if elapsed < duration:
		return false
	_active = false
	return true


## Fração já segurada, de 0 a 1.
func ratio() -> float:
	if duration <= 0.0:
		return 0.0
	return clampf(elapsed / duration, 0.0, 1.0)
