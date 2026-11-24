class_name SkyRules
extends RefCounted
## Regras puras do céu provisório: quanto do amanhecer já chegou e onde está a lua.


## Mistura entre o céu da noite (0) e o do amanhecer (1). Começa a subir na fração
## [param dawn_start] da noite e chega a 1 às 06:00, com suavização nas pontas.
static func dawn_blend(night_progress: float, dawn_start: float) -> float:
	if dawn_start >= 1.0:
		return 1.0 if night_progress >= 1.0 else 0.0
	return smoothstep(dawn_start, 1.0, night_progress)


## Posição da lua em radianos: x = elevação, y = azimute (0 = +Z, positivo para +X).
## Nasce a leste (+X) em [param min_elevation], passa por +Z no ponto mais alto
## ([param max_elevation]) no meio da noite e se põe a oeste (-X).
static func moon_angles(
	night_progress: float, min_elevation: float, max_elevation: float
) -> Vector2:
	var progress: float = clampf(night_progress, 0.0, 1.0)
	var elevation: float = lerpf(min_elevation, max_elevation, sin(PI * progress))
	var azimuth: float = lerpf(PI / 2.0, -PI / 2.0, progress)
	return Vector2(elevation, azimuth)
