class_name StormRules
extends RefCounted
## Regras puras da tempestade: o sorteio da noite e a intensidade ao longo do tempo.


## Sorteia a tempestade de uma noite de [param night_seconds] segundos. Antes da primeira noite
## permitida não há tempestade. A tempestade sempre acaba antes de latest_end_fraction da
## noite; numa noite curta demais, ela encolhe para caber.
static func plan(
	night_number: int, night_seconds: float, settings: StormSettings, rng: RandomNumberGenerator
) -> StormPlan:
	var storm: StormPlan = StormPlan.new()
	if night_number < settings.first_night or night_seconds <= 0.0:
		return storm
	if rng.randf() >= settings.chance:
		return storm
	var latest_end: float = settings.latest_end_fraction * night_seconds
	var duration: float = rng.randf_range(
		settings.min_duration_seconds, settings.max_duration_seconds
	)
	duration = minf(duration, latest_end)
	var start: float = (
		rng.randf_range(settings.start_window_min, settings.start_window_max) * night_seconds
	)
	start = clampf(start, 0.0, latest_end - duration)
	storm.has_storm = true
	storm.start_seconds = start
	storm.duration_seconds = duration
	return storm


## Intensidade de 0 a 1 aos [param elapsed] segundos da noite: sobe em [param ramp_seconds]
## depois do início, fica no pico e desce nos últimos [param ramp_seconds], com suavização.
static func strength(elapsed: float, storm: StormPlan, ramp_seconds: float) -> float:
	if not storm.has_storm:
		return 0.0
	var since_start: float = elapsed - storm.start_seconds
	if since_start <= 0.0 or since_start >= storm.duration_seconds:
		return 0.0
	var ramp: float = minf(ramp_seconds, storm.duration_seconds / 2.0)
	if ramp <= 0.0:
		return 1.0
	var rising: float = since_start / ramp
	var falling: float = (storm.duration_seconds - since_start) / ramp
	return smoothstep(0.0, 1.0, clampf(minf(rising, falling), 0.0, 1.0))
