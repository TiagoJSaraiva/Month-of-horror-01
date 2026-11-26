class_name SkyDriver
extends Node
## Liga o céu do addon Sky3D ao jogo (decisão 0016): o horário vem do NightClock, e não do
## relógio do addon, e a tempestade fecha o céu (nuvens, neblina, lua e brilho do céu).
## Os nós do Sky3D só existem depois de ele entrar na árvore, então tudo é ajustado no _ready.

@export var sky_3d: Sky3D
@export var night_clock: NightClock
@export_group("Sky date")
## Data e lugar do céu: lua cheia perto do equinócio, no equador e sem fuso, para a lua cruzar a
## noite toda e o sol nascer perto das 06:00.
@export var year: int = 2025
@export var month: int = 3
@export var day: int = 14
@export_group("Storm")
@export var clear_cloud_coverage: float = 0.25
@export var storm_cloud_coverage: float = 1.0
@export var clear_fog_density: float = 0.0007
@export var storm_fog_density: float = 0.01
## Brilho do céu no pico da tempestade, como fração do brilho normal.
@export var storm_sky_brightness: float = 0.35

## Intensidade da tempestade aplicada agora, de 0 a 1.
var storm_strength: float = 0.0

var _clear_moon_energy: float = 0.0
var _clear_skydome_energy: float = 0.0


## Desliga o relógio próprio do Sky3D, fixa data e lugar e aplica o céu limpo e a hora atual.
func _ready() -> void:
	if sky_3d == null or night_clock == null:
		push_warning("SkyDriver sem Sky3D ou NightClock: o céu não acompanha a noite.")
		set_process(false)
		return
	sky_3d.game_time_enabled = false
	sky_3d.editor_time_enabled = false
	var time_of_day: TimeOfDay = sky_3d.tod
	time_of_day.latitude = 0.0
	time_of_day.longitude = 0.0
	time_of_day.utc = 0.0
	time_of_day.year = year
	time_of_day.month = month
	time_of_day.day = day
	_clear_moon_energy = sky_3d.moon_energy
	_clear_skydome_energy = sky_3d.skydome_energy
	set_storm_strength(0.0)
	_apply_time()


## Atualiza a hora do céu a cada frame.
func _process(_delta: float) -> void:
	_apply_time()


## Environment do céu, para o balanço girar o céu junto com o mar.
func environment() -> Environment:
	return sky_3d.environment


## Intensidade da tempestade, de 0 a 1: mais nuvens e neblina, lua apagada e céu mais escuro.
func set_storm_strength(strength: float) -> void:
	storm_strength = clampf(strength, 0.0, 1.0)
	var dome: SkyDome = sky_3d.sky
	dome.cumulus_coverage = lerpf(clear_cloud_coverage, storm_cloud_coverage, storm_strength)
	dome.fog_density = lerpf(clear_fog_density, storm_fog_density, storm_strength)
	sky_3d.moon_energy = _clear_moon_energy * (1.0 - storm_strength)
	sky_3d.skydome_energy = _clear_skydome_energy * lerpf(1.0, storm_sky_brightness, storm_strength)


## Passa a hora do NightClock (minutos desde a meia-noite; 23:00 = 1380) ao Sky3D, que pede horas.
func _apply_time() -> void:
	sky_3d.current_time = night_clock.clock_minutes() / 60.0
