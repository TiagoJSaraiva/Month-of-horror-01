class_name FlyerSpawner
extends Node3D
## Traz voadores do mar enquanto a tempestade dura e manda todos embora quando ela acaba.
## Fica dentro de Actors, então congela no amanhecer junto com eles.

@export var flyer_scene: PackedScene
## Segundos entre o começo da tempestade e o primeiro voador.
@export var first_spawn_seconds: float = 4.0
@export var spawn_seconds: float = 12.0
@export var max_alive: int = 2
## Distância horizontal do barco, sobre o mar, de onde eles chegam.
@export var spawn_distance: float = 25.0
@export var spawn_height: float = 10.0

var _player: Node3D
var _player_health: Health
var _lighting: BoatLighting
var _flyers: Array[Flyer] = []
var _active: bool = false
var _until_spawn: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
# Dificuldade da noite (set_difficulty): 1 não muda nada.
var _interval_multiplier: float = 1.0
var _health_multiplier: float = 1.0
var _damage_multiplier: float = 1.0


## Sorteia a semente.
func _ready() -> void:
	_rng.randomize()


## Durante a tempestade, conta o intervalo e traz um voador novo se há vaga.
func _process(delta: float) -> void:
	if not _active:
		return
	_until_spawn -= delta
	if _until_spawn <= 0.0 and _flyers.size() < max_alive:
		_until_spawn = spawn_seconds * _interval_multiplier
		spawn()


## Dificuldade da noite: multiplica o intervalo entre voadores e a vida e o dano de cada um.
func set_difficulty(
	interval_multiplier: float, health_multiplier: float, damage_multiplier: float
) -> void:
	_interval_multiplier = interval_multiplier
	_health_multiplier = health_multiplier
	_damage_multiplier = damage_multiplier


## Começa a ouvir a tempestade. Chamado pela Night.
func start(storm: Storm, lighting: BoatLighting, player: Node3D, player_health: Health) -> void:
	_lighting = lighting
	_player = player
	_player_health = player_health
	storm.started.connect(_on_storm_started)
	storm.ended.connect(_on_storm_ended)


## Faz um voador chegar de um ponto sorteado sobre o mar. Público para os testes.
func spawn() -> Flyer:
	var angle: float = _rng.randf_range(0.0, TAU)
	var flyer: Flyer = flyer_scene.instantiate() as Flyer
	add_child(flyer)
	flyer.global_position = Vector3(
		cos(angle) * spawn_distance, spawn_height, sin(angle) * spawn_distance
	)
	flyer.removed.connect(_on_flyer_removed.bind(flyer))
	flyer.strengthen(_health_multiplier, _damage_multiplier)
	flyer.start(_player, _player_health, _lighting.bulbs())
	_flyers.append(flyer)
	return flyer


## Ativa o surgimento e começa a contagem até o primeiro voador (first_spawn_seconds).
func _on_storm_started() -> void:
	_active = true
	_until_spawn = first_spawn_seconds


## Desativa o surgimento e manda os voadores embora.
func _on_storm_ended() -> void:
	_active = false
	for flyer: Flyer in _flyers:
		flyer.leave()


## Tira da lista o voador que saiu.
func _on_flyer_removed(flyer: Flyer) -> void:
	_flyers.erase(flyer)
