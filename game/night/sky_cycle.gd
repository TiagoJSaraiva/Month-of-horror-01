class_name SkyCycle
extends WorldEnvironment
## Céu provisório: passa da paleta da noite para a do amanhecer conforme o NightClock e puxa
## para a paleta da tempestade pelo [member storm_weight].
## Escreve sempre valores absolutos das paletas: o Environment é um recurso compartilhado,
## e a próxima noite precisa começar escura e sem tempestade.

@export var night_clock: NightClock
@export var night_palette: SkyPalette
@export var dawn_palette: SkyPalette
@export var storm_palette: SkyPalette
## Fração da noite em que o céu começa a clarear: 6/7 corresponde às 05:00.
@export var dawn_start: float = 6.0 / 7.0

## Peso da paleta da tempestade, de 0 a 1. A Night define pela intensidade da tempestade.
var storm_weight: float = 0.0:
	set(value):
		storm_weight = clampf(value, 0.0, 1.0)

# Começam negativos para forçar a primeira aplicação.
var _applied_weight: float = -1.0
var _applied_storm_weight: float = -1.0


func _ready() -> void:
	if night_clock == null or night_palette == null or dawn_palette == null:
		push_warning("SkyCycle sem NightClock ou paletas: o céu não muda durante a noite.")
		return
	_apply(0.0)


func _process(_delta: float) -> void:
	if night_clock == null or night_palette == null or dawn_palette == null:
		return
	_apply(night_clock.progress)


func _apply(night_progress: float) -> void:
	var weight: float = SkyRules.dawn_blend(night_progress, dawn_start)
	# Mudar o material do céu refaz a iluminação do céu; só vale a pena quando a mistura muda.
	if (
		is_equal_approx(weight, _applied_weight)
		and is_equal_approx(storm_weight, _applied_storm_weight)
	):
		return
	_applied_weight = weight
	_applied_storm_weight = storm_weight
	var palette: SkyPalette = SkyPalette.mix(night_palette, dawn_palette, weight)
	if storm_palette != null:
		palette = SkyPalette.mix(palette, storm_palette, storm_weight)
	var sky_material := environment.sky.sky_material as ProceduralSkyMaterial
	if sky_material != null:
		sky_material.sky_top_color = palette.sky_top
		sky_material.sky_horizon_color = palette.sky_horizon
		sky_material.ground_horizon_color = palette.ground_horizon
		sky_material.ground_bottom_color = palette.ground_bottom
	environment.ambient_light_color = palette.ambient_color
	environment.ambient_light_energy = palette.ambient_energy
	environment.fog_light_color = palette.fog_color
	environment.fog_density = palette.fog_density
