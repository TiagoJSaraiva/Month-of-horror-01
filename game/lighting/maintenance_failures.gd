class_name MaintenanceFailures
extends Node
## Sorteia as falhas de manutenção: o gerador quebra enquanto funciona e as lâmpadas acesas
## queimam. A tempestade encurta os intervalos; a dificuldade de cada noite (M7) vai mexer
## nos valores base.

## Intervalo médio, em segundos de funcionamento, entre quebras do gerador. 0 desliga.
@export var generator_mean_seconds: float = 240.0
## Vida média de cada lâmpada, em segundos acesa. 0 desliga.
@export var bulb_mean_seconds: float = 720.0
## Quantas vezes mais frequentes as falhas ficam no pico da tempestade.
@export var storm_failure_multiplier: float = 3.0

var _generator: Generator
var _bulbs: Array[Bulb] = []
var _storm_strength: float = 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


func _process(delta: float) -> void:
	if _generator == null:
		return
	var generator_mean: float = LightingRules.storm_mean(
		generator_mean_seconds, _storm_strength, storm_failure_multiplier
	)
	var breakdown_chance: float = LightingRules.failure_chance(delta, generator_mean)
	if _generator.is_running() and _rng.randf() < breakdown_chance:
		_generator.break_down()
	var bulb_mean: float = LightingRules.storm_mean(
		bulb_mean_seconds, _storm_strength, storm_failure_multiplier
	)
	var burnout_chance: float = LightingRules.failure_chance(delta, bulb_mean)
	for bulb: Bulb in _bulbs:
		if bulb.is_lit() and _rng.randf() < burnout_chance:
			bulb.burn_out()


## Passa a sortear falhas para este gerador e estas lâmpadas. Chamado pelo BoatLighting.
func watch(generator: Generator, bulbs: Array[Bulb]) -> void:
	_generator = generator
	_bulbs = bulbs


## Intensidade da tempestade, de 0 a 1.
func set_storm_strength(strength: float) -> void:
	_storm_strength = clampf(strength, 0.0, 1.0)
