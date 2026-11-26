class_name StormWeather
extends Node3D
## Clima da tempestade: chuva caindo sobre o barco (sem chover dentro da cabine) e relâmpagos.
## A Night define a intensidade de 0 a 1; a chuva acompanha a intensidade, e os relâmpagos só
## caem perto do pico.

## Intensidade mínima da tempestade para cair relâmpago.
@export var lightning_min_strength: float = 0.6
@export var lightning_min_seconds: float = 5.0
@export var lightning_max_seconds: float = 14.0
@export var lightning_energy: float = 2.5

var _strength: float = 0.0
var _until_lightning: float = 0.0
var _flash: Tween
var _rng := RandomNumberGenerator.new()

@onready var _rain: GPUParticles3D = $Rain
@onready var _lightning: DirectionalLight3D = $Lightning


## Sorteia a semente, apaga o relâmpago e começa sem chuva.
func _ready() -> void:
	_rng.randomize()
	_lightning.visible = false
	set_strength(0.0)
	_schedule_lightning()


## Perto do pico da tempestade, conta o intervalo e faz cair um relâmpago.
func _process(delta: float) -> void:
	if _strength < lightning_min_strength:
		return
	_until_lightning -= delta
	if _until_lightning <= 0.0:
		_strike()
		_schedule_lightning()


## Intensidade da tempestade, de 0 a 1: quantidade de chuva e chance de relâmpago.
func set_strength(strength: float) -> void:
	_strength = clampf(strength, 0.0, 1.0)
	_rain.amount_ratio = _strength
	_rain.emitting = _strength > 0.0


## Sorteia quanto falta para o próximo relâmpago.
func _schedule_lightning() -> void:
	_until_lightning = _rng.randf_range(lightning_min_seconds, lightning_max_seconds)


## Clarão duplo, como um relâmpago de verdade, e depois apaga para não custar sombra à toa.
func _strike() -> void:
	if _flash != null:
		_flash.kill()
	_lightning.visible = true
	_lightning.light_energy = 0.0
	_flash = create_tween()
	_flash.tween_property(_lightning, "light_energy", lightning_energy, 0.05)
	_flash.tween_property(_lightning, "light_energy", lightning_energy * 0.15, 0.08)
	_flash.tween_property(_lightning, "light_energy", lightning_energy * 0.8, 0.05)
	_flash.tween_property(_lightning, "light_energy", 0.0, 0.3)
	_flash.tween_callback(_lightning.hide)
