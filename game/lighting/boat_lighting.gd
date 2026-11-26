class_name BoatLighting
extends Node3D
## Iluminação do barco: liga as lâmpadas à energia do gerador, acende a luz de emergência
## quando ele para e calcula o nível de luz que os inimigos do escuro (M5) consultam.
## O sorteio de falhas fica no filho MaintenanceFailures.

signal light_level_changed(level: float)

## Nível de luz de 0 a 1 (LightingRules.light_level).
var light_level: float = 0.0

var _bulbs: Array[Bulb] = []

@onready var _generator: Generator = $Generator
@onready var _bulbs_root: Node3D = $Bulbs
@onready var _emergency_lights: Node3D = $EmergencyLights
@onready var _failures: MaintenanceFailures = $MaintenanceFailures


## Reúne as lâmpadas da cena, liga os sinais e aplica o estado atual do gerador.
func _ready() -> void:
	for child: Node in _bulbs_root.get_children():
		var bulb := child as Bulb
		if bulb != null:
			_bulbs.append(bulb)
			bulb.changed.connect(_refresh_light_level)
	_generator.running_changed.connect(_on_generator_running_changed)
	_failures.watch(_generator, _bulbs)
	_on_generator_running_changed(_generator.is_running())


## Lâmpadas do barco, na ordem da cena. Os voadores da tempestade escolhem entre elas.
func bulbs() -> Array[Bulb]:
	return _bulbs


## Multiplica os tempos de manutenção do gerador e das lâmpadas (bônus da run).
func set_maintenance_time_multiplier(multiplier: float) -> void:
	_generator.hold_multiplier = multiplier
	for bulb: Bulb in _bulbs:
		bulb.hold_multiplier = multiplier


## Dificuldade da noite: falhas [param multiplier] vezes mais frequentes.
func set_failure_frequency(multiplier: float) -> void:
	_failures.set_frequency_multiplier(multiplier)


## Intensidade da tempestade, de 0 a 1: as falhas ficam mais frequentes.
func set_storm_strength(strength: float) -> void:
	_failures.set_storm_strength(strength)


## Liga ou corta a energia das lâmpadas e acende a luz de emergência quando o gerador para.
func _on_generator_running_changed(running: bool) -> void:
	for bulb: Bulb in _bulbs:
		bulb.set_powered(running)
	_emergency_lights.visible = not running
	_refresh_light_level()


## Recalcula o nível de luz e avisa pelo sinal light_level_changed quando ele muda.
func _refresh_light_level() -> void:
	var good_bulbs: int = 0
	for bulb: Bulb in _bulbs:
		if not bulb.is_broken():
			good_bulbs += 1
	var level: float = LightingRules.light_level(good_bulbs, _bulbs.size(), _generator.is_running())
	if not is_equal_approx(level, light_level):
		light_level = level
		light_level_changed.emit(level)
