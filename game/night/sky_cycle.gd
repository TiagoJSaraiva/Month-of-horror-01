class_name SkyCycle
extends WorldEnvironment
## Céu provisório: passa da paleta da noite para a do amanhecer conforme o NightClock.
## Escreve sempre valores absolutos das paletas: o Environment é um recurso compartilhado,
## e a próxima noite precisa começar escura.

@export var night_clock: NightClock
@export var night_palette: SkyPalette
@export var dawn_palette: SkyPalette
## Fração da noite em que o céu começa a clarear: 6/7 corresponde às 05:00.
@export var dawn_start: float = 6.0 / 7.0

# Começa negativo para forçar a primeira aplicação.
var _applied_weight: float = -1.0


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
	if is_equal_approx(weight, _applied_weight):
		return
	_applied_weight = weight
	var sky_material := environment.sky.sky_material as ProceduralSkyMaterial
	if sky_material != null:
		sky_material.sky_top_color = night_palette.sky_top.lerp(dawn_palette.sky_top, weight)
		sky_material.sky_horizon_color = night_palette.sky_horizon.lerp(
			dawn_palette.sky_horizon, weight
		)
		sky_material.ground_horizon_color = night_palette.ground_horizon.lerp(
			dawn_palette.ground_horizon, weight
		)
		sky_material.ground_bottom_color = night_palette.ground_bottom.lerp(
			dawn_palette.ground_bottom, weight
		)
	environment.ambient_light_color = night_palette.ambient_color.lerp(
		dawn_palette.ambient_color, weight
	)
	environment.ambient_light_energy = lerpf(
		night_palette.ambient_energy, dawn_palette.ambient_energy, weight
	)
	environment.fog_light_color = night_palette.fog_color.lerp(dawn_palette.fog_color, weight)
