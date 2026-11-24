class_name NightTimeRules
extends RefCounted
## Regras puras do tempo da noite: progresso, hora do jogo e ponteiros do relógio.

## A noite vai das 23:00 às 06:00.
const START_MINUTES := 23 * 60
const LENGTH_MINUTES := 7 * 60
const MINUTES_PER_DAY := 24 * 60
const MINUTES_PER_HALF_DAY := 12 * 60
const MINUTES_PER_HOUR := 60


## Fração da noite já passada, de 0 (23:00) a 1 (06:00). Duração não positiva já é amanhecer.
static func progress(elapsed_seconds: float, duration_seconds: float) -> float:
	if duration_seconds <= 0.0:
		return 1.0
	return clampf(elapsed_seconds / duration_seconds, 0.0, 1.0)


## Hora do jogo em minutos desde a meia-noite, de 0 a 1439.
static func clock_minutes(night_progress: float) -> float:
	return fposmod(START_MINUTES + night_progress * LENGTH_MINUTES, MINUTES_PER_DAY)


## Ângulos dos ponteiros em radianos, no sentido horário a partir do 12.
## x = ponteiro das horas, y = ponteiro dos minutos.
static func hand_angles(minutes: float) -> Vector2:
	var hour_turn: float = fposmod(minutes, MINUTES_PER_HALF_DAY) / MINUTES_PER_HALF_DAY
	var minute_turn: float = fposmod(minutes, MINUTES_PER_HOUR) / MINUTES_PER_HOUR
	return Vector2(hour_turn * TAU, minute_turn * TAU)
