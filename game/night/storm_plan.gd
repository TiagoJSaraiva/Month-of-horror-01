class_name StormPlan
extends RefCounted
## Tempestade sorteada para uma noite: se haverá uma, quando começa e quanto dura, em segundos
## desde o início da noite.

var has_storm: bool = false
var start_seconds: float = 0.0
var duration_seconds: float = 0.0


func end_seconds() -> float:
	return start_seconds + duration_seconds
