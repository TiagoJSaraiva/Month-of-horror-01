class_name FishingAttempt
extends RefCounted
## Uma tentativa de pesca, do lançamento ao fim (regras puras): espera a mordida, dá uma
## janela curta para fisgar e, fisgado o peixe, roda o minijogo.

signal state_changed(state: State)

enum State { WAITING, BITING, REELING, CAUGHT, ESCAPED, CANCELLED }

## Tempo para fisgar depois da mordida, em segundos.
const HOOK_WINDOW_SECONDS := 1.2

var state: State = State.WAITING
var fish: FishData
## Existe só a partir da fisgada.
var minigame: FishingMinigame

var _fishing_power: float
var _rng: RandomNumberGenerator
var _time_left: float


## Cria a tentativa para o peixe da isca e sorteia a espera até a mordida.
func _init(target_fish: FishData, fishing_power: float, rng: RandomNumberGenerator) -> void:
	fish = target_fish
	_fishing_power = fishing_power
	_rng = rng
	_time_left = _rng.randf_range(fish.bite_delay_min, fish.bite_delay_max)


## A tentativa acabou: o peixe foi pescado, escapou ou o jogador desistiu.
func is_finished() -> bool:
	return state in [State.CAUGHT, State.ESCAPED, State.CANCELLED]


## Avança a tentativa. [param reeling] indica se o jogador segura o botão no minijogo.
func update(delta: float, reeling: bool) -> void:
	match state:
		State.WAITING:
			_time_left -= delta
			if _time_left <= 0.0:
				_time_left = HOOK_WINDOW_SECONDS
				_set_state(State.BITING)
		State.BITING:
			_time_left -= delta
			if _time_left <= 0.0:
				_set_state(State.ESCAPED)
		State.REELING:
			minigame.update(delta, reeling)
			if minigame.state == FishingMinigame.State.CAUGHT:
				_set_state(State.CAUGHT)
			elif minigame.state == FishingMinigame.State.ESCAPED:
				_set_state(State.ESCAPED)


## Clique principal: fisga durante a mordida; antes da mordida, só recolhe a linha.
func hook() -> void:
	if state == State.BITING:
		minigame = FishingMinigame.new(fish, _fishing_power, _rng)
		_set_state(State.REELING)
	elif state == State.WAITING:
		_set_state(State.CANCELLED)


## Desistir: recolhe a linha. Durante a puxada, o peixe escapa.
func cancel() -> void:
	if state == State.REELING:
		_set_state(State.ESCAPED)
	elif state == State.WAITING or state == State.BITING:
		_set_state(State.CANCELLED)


## Troca o estado e avisa pelo sinal state_changed.
func _set_state(new_state: State) -> void:
	state = new_state
	state_changed.emit(state)
