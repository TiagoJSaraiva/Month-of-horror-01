class_name FishmanBrain
extends RefCounted
## Comportamento do peixe-homem, sem cena: sobe a bordo, persegue, prepara e dá o golpe, fica
## atordoado com a lanterna (e imune por um tempo depois), foge quando a luz volta e morre.
## O nó Fishman lê o estado para se mover e aplica o dano quando o golpe acerta.

signal state_changed(state: State)
signal attack_landed

enum State { CLIMBING, CHASING, WINDING_UP, RECOVERING, STUNNED, FLEEING, DEAD }

var state: State = State.CLIMBING
var climb_seconds: float = 1.5
## Distância, em metros, para começar o golpe e para ele acertar.
var attack_range: float = 1.4
## Preparação visível antes do golpe: a janela para o jogador fugir ou atordoar.
var windup_seconds: float = 0.6
var recover_seconds: float = 1.0
var stun_seconds: float = 1.0
## Depois de um atordoamento, a luz no rosto não o atordoa de novo por este tempo.
var stun_immunity_seconds: float = 2.0

var _state_seconds: float = 0.0
var _immunity_left: float = 0.0


## Passa o tempo, com a distância horizontal até o alvo.
func update(delta: float, distance_to_target: float) -> void:
	if state == State.DEAD:
		return
	_immunity_left = maxf(_immunity_left - delta, 0.0)
	_state_seconds += delta
	match state:
		State.CLIMBING:
			if _state_seconds >= climb_seconds:
				_enter(State.CHASING)
		State.CHASING:
			if distance_to_target <= attack_range:
				_enter(State.WINDING_UP)
		State.WINDING_UP:
			if _state_seconds >= windup_seconds:
				# Só acerta se o alvo continua perto: dá para escapar durante a preparação.
				if distance_to_target <= attack_range:
					attack_landed.emit()
				_enter(State.RECOVERING)
		State.RECOVERING:
			if _state_seconds >= recover_seconds:
				_enter(State.CHASING)
		State.STUNNED:
			if _state_seconds >= stun_seconds:
				_immunity_left = stun_immunity_seconds
				_enter(State.CHASING)


## Luz no rosto. Devolve true se atordoou: não vale subindo, fugindo, morto, já atordoado ou
## durante a imunidade.
func stun() -> bool:
	if _immunity_left > 0.0:
		return false
	if state in [State.CLIMBING, State.STUNNED, State.FLEEING, State.DEAD]:
		return false
	_enter(State.STUNNED)
	return true


## A luz do barco voltou: foge para o mar e não volta atrás.
func flee() -> void:
	if state != State.FLEEING and state != State.DEAD:
		_enter(State.FLEEING)


## Vai para DEAD a partir de qualquer estado; sem efeito se já estiver morto.
func kill() -> void:
	if state != State.DEAD:
		_enter(State.DEAD)


## Verdadeiro se está se deslocando: perseguindo ou fugindo.
func is_moving() -> bool:
	return state == State.CHASING or state == State.FLEEING


## Muda para new_state, zera o tempo no estado e emite state_changed.
func _enter(new_state: State) -> void:
	state = new_state
	_state_seconds = 0.0
	state_changed.emit(new_state)
