class_name MoonArc
extends DirectionalLight3D
## Lua provisória: cruza o céu de leste a oeste ao longo da noite.
## Fica dentro do OutsideWorld, então o balanço do barco continua valendo por cima.

@export var night_clock: NightClock
@export var min_elevation_degrees: float = 10.0
@export var max_elevation_degrees: float = 55.0


func _ready() -> void:
	if night_clock == null:
		push_warning("MoonArc sem NightClock: a lua fica parada.")
	_apply(0.0)


func _process(_delta: float) -> void:
	if night_clock == null:
		return
	_apply(night_clock.progress)


func _apply(night_progress: float) -> void:
	var angles: Vector2 = SkyRules.moon_angles(
		night_progress, deg_to_rad(min_elevation_degrees), deg_to_rad(max_elevation_degrees)
	)
	var toward_moon := Vector3(
		cos(angles.x) * sin(angles.y), sin(angles.x), cos(angles.x) * cos(angles.y)
	)
	# A luz viaja da lua para o barco, então o -Z da luz aponta para longe da lua.
	basis = Basis.looking_at(-toward_moon, Vector3.UP)
