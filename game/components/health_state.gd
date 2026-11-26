class_name HealthState
extends RefCounted
## Vida de um personagem: dano, morte e regeneração depois de um tempo sem levar dano.

signal changed
signal died

var max_health: float
var current: float
## Vida recuperada por segundo depois de [member regen_delay_seconds] sem dano. 0 desliga.
var regen_per_second: float
var regen_delay_seconds: float

var _since_damage: float = 0.0


## Cria a vida cheia. Valores negativos viram zero.
func _init(maximum: float, regen_rate: float = 0.0, regen_delay: float = 0.0) -> void:
	max_health = maxf(maximum, 0.0)
	current = max_health
	regen_per_second = maxf(regen_rate, 0.0)
	regen_delay_seconds = maxf(regen_delay, 0.0)


## Troca o máximo e enche a vida (bônus aplicados no começo da noite).
func reset_max(maximum: float) -> void:
	max_health = maxf(maximum, 0.0)
	current = max_health
	_since_damage = 0.0
	changed.emit()


## Diz se a vida chegou a zero.
func is_dead() -> bool:
	return current <= 0.0


## Vida atual como fração do máximo, de 0 a 1. Zero se o máximo for zero.
func ratio() -> float:
	if max_health <= 0.0:
		return 0.0
	return current / max_health


## Tira vida. Dano depois da morte, zero ou negativo é ignorado.
func damage(amount: float) -> void:
	if is_dead() or amount <= 0.0:
		return
	current = maxf(current - amount, 0.0)
	_since_damage = 0.0
	changed.emit()
	if is_dead():
		died.emit()


## Passa o tempo: depois da espera sem dano, regenera na taxa definida até o máximo.
func update(delta: float) -> void:
	if is_dead() or regen_per_second <= 0.0 or current >= max_health or delta <= 0.0:
		return
	_since_damage += delta
	# Só conta o trecho do passo que já está depois da espera, para o resultado não depender
	# do tamanho do passo.
	var regen_time: float = minf(delta, _since_damage - regen_delay_seconds)
	if regen_time <= 0.0:
		return
	current = minf(current + regen_per_second * regen_time, max_health)
	changed.emit()
