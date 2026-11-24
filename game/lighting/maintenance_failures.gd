class_name MaintenanceFailures
extends Node
## Sorteia as falhas de manutenção: o gerador quebra enquanto funciona e as lâmpadas acesas
## queimam. A tempestade (M6) e a dificuldade de cada noite (M7) vão mexer nestes intervalos.

## Intervalo médio, em segundos de funcionamento, entre quebras do gerador. 0 desliga.
@export var generator_mean_seconds: float = 240.0
## Vida média de cada lâmpada, em segundos acesa. 0 desliga.
@export var bulb_mean_seconds: float = 720.0

var _generator: Generator
var _bulbs: Array[Bulb] = []
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


func _process(delta: float) -> void:
	if _generator == null:
		return
	var breakdown_chance: float = LightingRules.failure_chance(delta, generator_mean_seconds)
	if _generator.is_running() and _rng.randf() < breakdown_chance:
		_generator.break_down()
	var burnout_chance: float = LightingRules.failure_chance(delta, bulb_mean_seconds)
	for bulb: Bulb in _bulbs:
		if bulb.is_lit() and _rng.randf() < burnout_chance:
			bulb.burn_out()


## Passa a sortear falhas para este gerador e estas lâmpadas. Chamado pelo BoatLighting.
func watch(generator: Generator, bulbs: Array[Bulb]) -> void:
	_generator = generator
	_bulbs = bulbs
