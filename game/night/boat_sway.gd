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
## Multiplica o balanço. A tempestade aumenta este valor.
@export var intensity: float = 1.0

var _time: float = 0.0


func _ready() -> void:
	if environment == null:
		push_warning("BoatSway sem Environment: o céu não vai acompanhar o balanço.")


func _process(delta: float) -> void:
	_time += delta
	var pitch_amplitude: float = deg_to_rad(pitch_amplitude_degrees)
	var roll_amplitude: float = deg_to_rad(roll_amplitude_degrees)
	var sway: Vector3 = SwayRules.angles(
		_time, pitch_amplitude, pitch_period, roll_amplitude, roll_period, intensity
	)
	# Quando o barco inclina para um lado, quem está a bordo vê o mundo inclinar para o outro.
	rotation = -sway
	if environment != null:
		environment.sky_rotation = -sway
