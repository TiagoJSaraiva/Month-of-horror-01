class_name BoatSway
extends Node3D
## Balanço visual do barco (decisão 0008). O barco fica parado na física; este nó, que
## contém tudo o que está fora do barco, gira com o inverso do balanço, e o céu acompanha.

## Environment da cena, para o céu girar junto com o mar.
@export var environment: Environment
@export var pitch_amplitude_degrees: float = 1.5
@export var pitch_period: float = 9.0
@export var roll_amplitude_degrees: float = 3.0
@export var roll_period: float = 7.0
## Multiplica o balanço fora da tempestade.
@export var intensity: float = 1.0
## Multiplicador do balanço no pico da tempestade.
@export var storm_intensity: float = 3.0

var _time: float = 0.0
var _storm_strength: float = 0.0


## Avisa se falta o Environment, sem o qual o céu não acompanha o balanço.
func _ready() -> void:
	if environment == null:
		push_warning("BoatSway sem Environment: o céu não vai acompanhar o balanço.")


## Gira o mundo de fora, e o céu junto, no sentido oposto ao balanço do barco.
func _process(delta: float) -> void:
	_time += delta
	var pitch_amplitude: float = deg_to_rad(pitch_amplitude_degrees)
	var roll_amplitude: float = deg_to_rad(roll_amplitude_degrees)
	var sway: Vector3 = SwayRules.angles(
		_time, pitch_amplitude, pitch_period, roll_amplitude, roll_period, effective_intensity()
	)
	# Quando o barco inclina para um lado, quem está a bordo vê o mundo inclinar para o outro.
	rotation = -sway
	if environment != null:
		environment.sky_rotation = -sway


## Intensidade da tempestade, de 0 a 1: leva o balanço de [member intensity] até
## [member storm_intensity]. Só a amplitude muda, para o movimento não dar saltos.
func set_storm_strength(strength: float) -> void:
	_storm_strength = clampf(strength, 0.0, 1.0)


## Intensidade do balanço agora: a normal, subindo até a da tempestade conforme ela cresce.
func effective_intensity() -> float:
	return lerpf(intensity, storm_intensity, _storm_strength)
