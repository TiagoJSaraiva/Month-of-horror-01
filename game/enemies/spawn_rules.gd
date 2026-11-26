class_name SpawnRules
extends RefCounted
## Regras puras do surgimento dos inimigos do escuro.

## Intervalo devolvido quando a luz está no limiar ou acima: ninguém sobe a bordo.
const NO_SPAWN: float = -1.0


## Escuridão de 0 (luz no limiar ou acima) a 1 (sem luz nenhuma).
static func darkness(light_level: float, threshold: float) -> float:
	if threshold <= 0.0 or light_level >= threshold:
		return 0.0
	return clampf((threshold - light_level) / threshold, 0.0, 1.0)


## Segundos entre um surgimento e o próximo: o máximo logo abaixo do limiar, caindo até o
## mínimo no escuro total. [constant NO_SPAWN] com a luz no limiar ou acima.
static func spawn_interval(
	light_level: float, threshold: float, min_seconds: float, max_seconds: float
) -> float:
	if light_level >= threshold:
		return NO_SPAWN
	return lerpf(max_seconds, min_seconds, darkness(light_level, threshold))
