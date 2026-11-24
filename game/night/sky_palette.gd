class_name SkyPalette
extends Resource
## Cores do céu procedural, da luz ambiente e da neblina para um momento da noite (noite,
## amanhecer, tempestade).

@export var sky_top: Color = Color.BLACK
@export var sky_horizon: Color = Color.BLACK
@export var ground_horizon: Color = Color.BLACK
@export var ground_bottom: Color = Color.BLACK
@export var ambient_color: Color = Color.BLACK
@export var ambient_energy: float = 1.0
@export var fog_color: Color = Color.BLACK
@export var fog_density: float = 0.025


## Mistura duas paletas: [param weight] 0 devolve as cores de [param a], 1 as de [param b].
static func mix(a: SkyPalette, b: SkyPalette, weight: float) -> SkyPalette:
	var palette := SkyPalette.new()
	palette.sky_top = a.sky_top.lerp(b.sky_top, weight)
	palette.sky_horizon = a.sky_horizon.lerp(b.sky_horizon, weight)
	palette.ground_horizon = a.ground_horizon.lerp(b.ground_horizon, weight)
	palette.ground_bottom = a.ground_bottom.lerp(b.ground_bottom, weight)
	palette.ambient_color = a.ambient_color.lerp(b.ambient_color, weight)
	palette.ambient_energy = lerpf(a.ambient_energy, b.ambient_energy, weight)
	palette.fog_color = a.fog_color.lerp(b.fog_color, weight)
	palette.fog_density = lerpf(a.fog_density, b.fog_density, weight)
	return palette
