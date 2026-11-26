class_name SwayRules
extends RefCounted
## Regra pura do balanço do barco ao longo do tempo.


## Ângulos do balanço em radianos: x = arfagem (proa sobe e desce), z = rolagem (bordo a bordo).
## Cada eixo é uma senoide com período próprio, para o movimento não parecer mecânico.
## Período zero ou negativo deixa o eixo parado.
static func angles(
	time: float,
	pitch_amplitude: float,
	pitch_period: float,
	roll_amplitude: float,
	roll_period: float,
	intensity: float,
) -> Vector3:
	var pitch: float = _wave(time, pitch_amplitude * intensity, pitch_period)
	var roll: float = _wave(time, roll_amplitude * intensity, roll_period)
	return Vector3(pitch, 0.0, roll)


## Senoide do balanço no instante dado. Período zero ou negativo deixa parado.
static func _wave(time: float, amplitude: float, period: float) -> float:
	if period <= 0.0:
		return 0.0
	return amplitude * sin(TAU * time / period)
