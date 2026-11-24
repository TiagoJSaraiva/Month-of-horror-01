class_name FishingMinigame
extends RefCounted
## Minijogo de pesca "mantenha o peixe dentro da barra" (regras puras).
## Posições vão de 0 (fundo do trilho) a 1 (topo). Segurar o botão acelera a barra para cima;
## soltar deixa ela cair. Com o peixe dentro da barra a captura enche; fora, esvazia.

enum State { RUNNING, CAUGHT, ESCAPED }

## Altura da barra, em fração do trilho.
const BAR_SIZE := 0.25
## Aceleração da barra, em trilhos/s²: para cima segurando, para baixo soltando.
const REEL_ACCELERATION := 3.0
const BAR_GRAVITY := 2.5
## A captura começa acima de zero para o peixe não escapar no primeiro instante.
const START_PROGRESS := 0.3
## Enchimento por segundo com poder de pesca 1, e esvaziamento por segundo.
const FILL_RATE := 0.3
const DRAIN_RATE := 0.2

var state: State = State.RUNNING
var fish: FishData
## Base da barra no trilho; a barra ocupa de [member bar_position] até + [constant BAR_SIZE].
var bar_position: float = 0.0
var bar_velocity: float = 0.0
var fish_position: float = 0.0
## Captura de 0 (escapou) a 1 (pescado).
var progress: float = START_PROGRESS

var _fishing_power: float
var _fish_target: float
var _rng: RandomNumberGenerator


func _init(hooked_fish: FishData, fishing_power: float, rng: RandomNumberGenerator) -> void:
	fish = hooked_fish
	_fishing_power = fishing_power
	_rng = rng
	fish_position = _rng.randf()
	_fish_target = fish_position


func is_fish_inside_bar() -> bool:
	return fish_position >= bar_position and fish_position <= bar_position + BAR_SIZE


## Avança o minijogo. [param reeling] indica se o jogador está segurando o botão.
func update(delta: float, reeling: bool) -> void:
	if state != State.RUNNING:
		return
	_move_bar(delta, reeling)
	_move_fish(delta)
	var rate: float = FILL_RATE * _fishing_power if is_fish_inside_bar() else -DRAIN_RATE
	progress = clampf(progress + rate * delta, 0.0, 1.0)
	if progress >= 1.0:
		state = State.CAUGHT
	elif progress <= 0.0:
		state = State.ESCAPED


func _move_bar(delta: float, reeling: bool) -> void:
	var acceleration: float = REEL_ACCELERATION if reeling else -BAR_GRAVITY
	bar_velocity += acceleration * delta
	bar_position += bar_velocity * delta
	var top: float = 1.0 - BAR_SIZE
	# Nas pontas do trilho a barra para, em vez de quicar.
	if bar_position <= 0.0:
		bar_position = 0.0
		bar_velocity = maxf(bar_velocity, 0.0)
	elif bar_position >= top:
		bar_position = top
		bar_velocity = minf(bar_velocity, 0.0)


func _move_fish(delta: float) -> void:
	if _rng.randf() < fish.direction_changes_per_second * delta:
		_fish_target = _rng.randf()
	fish_position = move_toward(fish_position, _fish_target, fish.swim_speed * delta)
