class_name LightingRules
extends RefCounted
## Regras puras da iluminação do barco: o nível de luz e o sorteio de falhas.


## Nível de luz de 0 a 1: a fração de lâmpadas boas com o gerador funcionando. Sem o gerador
## sobra só a luz de emergência, que não conta.
static func light_level(good_bulbs: int, total_bulbs: int, powered: bool) -> float:
	if not powered or total_bulbs <= 0:
		return 0.0
	return clampf(float(good_bulbs) / float(total_bulbs), 0.0, 1.0)


## Chance de uma falha acontecer num passo de [param delta] segundos, dado o intervalo médio
## entre falhas. Não depende da taxa de quadros: dois passos de 0,5 s valem um de 1 s.
## Intervalo médio zero ou negativo desliga a falha.
static func failure_chance(delta: float, mean_seconds: float) -> float:
	if delta <= 0.0 or mean_seconds <= 0.0:
		return 0.0
	return 1.0 - exp(-delta / mean_seconds)
