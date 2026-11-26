class_name FlyerBrain
extends RefCounted
## Comportamento do voador da tempestade, sem cena: chega voando, circula o barco, avisa e
## mergulha num alvo (o jogador ou uma lâmpada), volta para cima e repete. Vai embora quando a
## tempestade acaba. O nó Flyer se move, conta quando chegou a cada ponto e aplica o golpe.

signal state_changed(state: State)

enum State { ARRIVING, CIRCLING, WARNING, DIVING, RETURNING, LEAVING, DEAD }
enum Target { NONE, PLAYER, BULB }

var state: State = State.ARRIVING
## Alvo do mergulho atual, escolhido no fim do círculo.
var target: Target = Target.NONE
## Aviso antes do mergulho: a janela para o jogador se proteger ou atirar.
var warning_seconds: float = 0.6

var _state_seconds: float = 0.0
var _circle_seconds: float = 0.0


## Alvo do mergulho: o jogador ou uma lâmpada boa, se estiverem à vista. Com os dois à vista,
## [param roll] (de 0 a 1) abaixo de [param player_chance] escolhe o jogador.
static func pick_target(
	player_visible: bool, bulb_visible: bool, roll: float, player_chance: float
) -> Target:
	if player_visible and bulb_visible:
		return Target.PLAYER if roll < player_chance else Target.BULB
	if player_visible:
		return Target.PLAYER
	if bulb_visible:
		return Target.BULB
	return Target.NONE


## Passa o tempo. No fim do círculo escolhe o alvo; sem alvo à vista, continua circulando.
func update(
	delta: float, player_visible: bool, bulb_visible: bool, roll: float, player_chance: float
) -> void:
	if state == State.DEAD:
		return
	_state_seconds += delta
	match state:
		State.CIRCLING:
			if _state_seconds >= _circle_seconds:
				target = pick_target(player_visible, bulb_visible, roll, player_chance)
				if target == Target.NONE:
					_state_seconds = 0.0
				else:
					_enter(State.WARNING)
		State.WARNING:
			if _state_seconds >= warning_seconds:
				_enter(State.DIVING)


## Chegou ao círculo sobre o barco: circula por [param circle_seconds].
func arrived(circle_seconds: float) -> void:
	if state == State.ARRIVING:
		_start_circling(circle_seconds)


## O mergulho terminou, tendo acertado ou não: volta para cima.
func dive_finished() -> void:
	if state == State.DIVING:
		_enter(State.RETURNING)


## Voltou à altura do círculo: circula de novo por [param circle_seconds].
func returned(circle_seconds: float) -> void:
	if state == State.RETURNING:
		_start_circling(circle_seconds)


## A tempestade acabou: vai embora de onde estiver.
func leave() -> void:
	if state != State.LEAVING and state != State.DEAD:
		_enter(State.LEAVING)


## Morre, de qualquer estado.
func kill() -> void:
	if state != State.DEAD:
		_enter(State.DEAD)


## Passa a circular por circle_seconds, sem alvo escolhido.
func _start_circling(circle_seconds: float) -> void:
	_circle_seconds = circle_seconds
	target = Target.NONE
	_enter(State.CIRCLING)


## Entra no estado, zera o tempo nele e avisa pelo sinal state_changed.
func _enter(new_state: State) -> void:
	state = new_state
	_state_seconds = 0.0
	state_changed.emit(new_state)
