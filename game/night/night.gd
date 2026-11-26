class_name Night
extends Node3D
## Uma noite de pesca: gera o pedido, entrega-o ao diário do jogador, põe o bilhete na mesa,
## sorteia a tempestade e repassa a intensidade dela, registra os peixes guardados no freezer e
## encerra a ação dos personagens ao amanhecer ou com a morte do jogador.

signal night_finished(order: NightOrder)
signal player_died

## Número da noite na run. A Run define este valor antes de a noite começar.
@export var night_number: int = 1
@export var fish_species: Array[FishData] = []
## Cena criada no convés quando o jogador larga um item.
@export var dropped_item_scene: PackedScene
## Como a noite fica mais difícil pelo night_number. Sem curva, a noite usa os valores do
## inspetor.
@export var difficulty: DifficultyCurve

var order: NightOrder
## Bilhete dos clientes na mesa. A Run define antes de a noite entrar na árvore; sem texto, a
## mesa fica sem bilhete.
var table_note_text: String = ""
var table_note_pin: RunRules.Pin = RunRules.Pin.BLUE
## Bônus da run (cartas). A Run define antes de a noite entrar na árvore; sem isso, nenhum bônus.
var player_stats: PlayerStats = PlayerStats.new()

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
## A noite já terminou, pelo amanhecer ou pela morte. Só o primeiro fim vale.
var _ended: bool = false

@onready var _clock: NightClock = $NightClock
@onready var _storm: Storm = $Storm
@onready var _weather: StormWeather = $StormWeather
@onready var _sky_driver: SkyDriver = $SkyDriver
@onready var _sway: BoatSway = $OutsideWorld
@onready var _actors: Node3D = $Actors
@onready var _player: Player = $Actors/Player
@onready var _fishman_spawner: FishmanSpawner = $Actors/FishmanSpawner
@onready var _flyer_spawner: FlyerSpawner = $Actors/FlyerSpawner
@onready var _freezer: Freezer = $Boat/Freezer
@onready var _lighting: BoatLighting = $Boat/Lighting
@onready var _items: Node3D = $Items
@onready var _table_note: TableNote = $TableNote


## Gera o pedido e o mostra no diário, põe o bilhete na mesa, liga os sinais, inicia os spawners,
## aplica os bônus e a dificuldade e sorteia a tempestade.
func _ready() -> void:
	_rng.randomize()
	order = NightOrder.new(OrderRules.generate(night_number, fish_species, _rng))
	_player.journal.display(night_number, order)
	_table_note.show_note(table_note_text, table_note_pin)
	_clock.dawn_reached.connect(_on_night_clock_dawn_reached)
	_freezer.fish_stored.connect(_on_freezer_fish_stored)
	_player.hands.item_dropped.connect(_on_hands_item_dropped)
	_player.health.died.connect(_on_player_health_died)
	_fishman_spawner.start(_lighting, _player, _player.health)
	_flyer_spawner.start(_storm, _lighting, _player, _player.health)
	_storm.strength_changed.connect(_on_storm_strength_changed)
	# Bônus antes da dificuldade (a bateria recebe os dois) e os dois antes do sorteio da
	# tempestade, que usa a chance desta noite.
	_apply_player_stats()
	_apply_difficulty()
	_storm.roll(night_number, _rng)


## A noite já terminou, pelo amanhecer ou pela morte.
func is_ended() -> bool:
	return _ended


## Encerra a noite no amanhecer, se ela ainda não acabou, e avisa pelo sinal night_finished.
func _on_night_clock_dawn_reached() -> void:
	if _ended:
		return
	_end()
	night_finished.emit(order)


## Encerra a noite com a morte do jogador, se ela ainda não acabou; para o relógio e avisa pelo
## sinal player_died.
func _on_player_health_died() -> void:
	if _ended:
		return
	_end()
	# O relógio para junto: o amanhecer não pode chegar durante a tela de morte.
	_clock.process_mode = Node.PROCESS_MODE_DISABLED
	player_died.emit()


## Marca a noite como encerrada e para só os personagens, a manutenção e a tempestade: mar, céu e
## balanço continuam como estão. Sem isso, o gerador ainda poderia quebrar na tela do amanhecer.
func _end() -> void:
	_ended = true
	_actors.process_mode = Node.PROCESS_MODE_DISABLED
	_lighting.process_mode = Node.PROCESS_MODE_DISABLED
	_storm.process_mode = Node.PROCESS_MODE_DISABLED
	_weather.process_mode = Node.PROCESS_MODE_DISABLED


## Aplica ao jogador e ao tempo de manutenção os bônus da run.
func _apply_player_stats() -> void:
	_player.apply_stats(player_stats)
	_lighting.set_maintenance_time_multiplier(
		player_stats.apply(StatModifier.Stat.MAINTENANCE_TIME, 1.0)
	)


## Aplica a dificuldade desta noite aos inimigos, à manutenção, à bateria e à tempestade. Sem curva,
## não muda nada.
func _apply_difficulty() -> void:
	if difficulty == null:
		return
	var health: float = DifficultyRules.value(difficulty.enemy_health, night_number)
	var damage: float = DifficultyRules.value(difficulty.enemy_damage, night_number)
	_fishman_spawner.set_difficulty(
		DifficultyRules.value(difficulty.fishman_spawn_interval, night_number), health, damage
	)
	_flyer_spawner.set_difficulty(
		DifficultyRules.value(difficulty.flyer_spawn_interval, night_number), health, damage
	)
	_lighting.set_failure_frequency(
		DifficultyRules.value(difficulty.maintenance_failures, night_number)
	)
	_player.flashlight.set_battery_seconds(
		(
			_player.flashlight.battery_seconds
			* DifficultyRules.value(difficulty.flashlight_battery, night_number)
		)
	)
	# Cópia dos ajustes da tempestade: o .tres é compartilhado entre as noites.
	var storm_settings: StormSettings = _storm.settings.duplicate() as StormSettings
	storm_settings.chance = DifficultyRules.value(difficulty.storm_chance, night_number)
	var duration: float = DifficultyRules.value(difficulty.storm_duration, night_number)
	storm_settings.min_duration_seconds *= duration
	storm_settings.max_duration_seconds *= duration
	_storm.settings = storm_settings


## Repassa a intensidade da tempestade ao céu, ao balanço, ao clima e às falhas de manutenção.
func _on_storm_strength_changed(strength: float) -> void:
	_sky_driver.set_storm_strength(strength)
	_sway.set_storm_strength(strength)
	_weather.set_strength(strength)
	_lighting.set_storm_strength(strength)


## Registra no pedido os peixes guardados no freezer.
func _on_freezer_fish_stored(fish: FishData, amount: int) -> void:
	order.deliver(fish, amount)


## Cria no convés o item que o jogador largou.
func _on_hands_item_dropped(item: ItemData, amount: int, at: Vector3) -> void:
	var dropped: DroppedItem = dropped_item_scene.instantiate() as DroppedItem
	dropped.item = item
	dropped.amount = amount
	_items.add_child(dropped)
	dropped.global_position = at
