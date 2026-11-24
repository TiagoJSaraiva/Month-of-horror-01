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


## Intensidade da tempestade, de 0 a 1: as falhas ficam mais frequentes.
func set_storm_strength(strength: float) -> void:
	_failures.set_storm_strength(strength)


func _on_generator_running_changed(running: bool) -> void:
	for bulb: Bulb in _bulbs:
		bulb.set_powered(running)
	_emergency_lights.visible = not running
	_refresh_light_level()


func _refresh_light_level() -> void:
	var good_bulbs: int = 0
	for bulb: Bulb in _bulbs:
		if not bulb.is_broken():
			good_bulbs += 1
	var level: float = LightingRules.light_level(good_bulbs, _bulbs.size(), _generator.is_running())
	if not is_equal_approx(level, light_level):
		light_level = level
		light_level_changed.emit(level)
