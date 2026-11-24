class_name DifficultyRules
extends RefCounted
## Regra pura da dificuldade por noite.


## Valor de [param scaling] na noite [param night] (a primeira é 1), sem passar do limite.
static func value(scaling: ScalingValue, night: int) -> float:
	var raw: float = scaling.first_night_value + scaling.per_night * maxi(night - 1, 0)
	if scaling.per_night >= 0.0:
		return minf(raw, scaling.limit)
	return maxf(raw, scaling.limit)
