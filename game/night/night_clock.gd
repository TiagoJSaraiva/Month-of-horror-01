class_name NightClock
extends Node
## Relógio da noite: vai de 23:00 a 06:00 em [member duration_seconds] reais e avisa quando
## amanhece.

signal dawn_reached

## Duração da noite em segundos reais: 7 min reais valem as 7 horas do jogo.
@export var duration_seconds: float = 420.0

## Fração da noite já passada, de 0 a 1.
var progress: float = 0.0

var _elapsed: float = 0.0
var _finished: bool = false


func _process(delta: float) -> void:
	if _finished:
		return
	_elapsed += delta
	progress = NightTimeRules.progress(_elapsed, duration_seconds)
	if progress >= 1.0:
		_finished = true
		dawn_reached.emit()


## Hora do jogo em minutos desde a meia-noite.
func clock_minutes() -> float:
	return NightTimeRules.clock_minutes(progress)
