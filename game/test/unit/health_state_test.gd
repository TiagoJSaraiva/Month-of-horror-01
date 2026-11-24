extends GdUnitTestSuite
## Vida: o dano baixa até zero, a morte acontece uma vez e a regeneração espera um tempo sem
## dano.

const MAX := 100.0
const REGEN_RATE := 5.0
const REGEN_DELAY := 5.0

var _health: HealthState


func before_test() -> void:
	_health = HealthState.new(MAX, REGEN_RATE, REGEN_DELAY)


func test_starts_full() -> void:
	assert_float(_health.current).is_equal(MAX)
	assert_float(_health.ratio()).is_equal_approx(1.0, 0.001)
	assert_bool(_health.is_dead()).is_false()


func test_damage_lowers_health_down_to_zero() -> void:
	_health.damage(30.0)
	assert_float(_health.current).is_equal_approx(70.0, 0.001)

	_health.damage(500.0)
	assert_float(_health.current).is_equal(0.0)
	assert_bool(_health.is_dead()).is_true()


func test_dies_only_once() -> void:
	var deaths: Array[int] = [0]
	_health.died.connect(func() -> void: deaths[0] += 1)

	_health.damage(MAX)
	_health.damage(10.0)

	assert_int(deaths[0]).is_equal(1)


func test_invalid_damage_is_ignored() -> void:
	_health.damage(0.0)
	_health.damage(-10.0)

	assert_float(_health.current).is_equal(MAX)


func test_regeneration_waits_for_the_delay() -> void:
	_health.damage(50.0)

	_health.update(4.0)
	assert_float(_health.current).is_equal_approx(50.0, 0.001)

	_health.update(2.0)
	# Só 1 s do passo ficou depois da espera de 5 s.
	assert_float(_health.current).is_equal_approx(55.0, 0.001)


func test_regeneration_stops_at_maximum() -> void:
	_health.damage(10.0)

	_health.update(30.0)

	assert_float(_health.current).is_equal(MAX)


func test_new_damage_restarts_the_wait() -> void:
	_health.damage(50.0)
	_health.update(4.0)

	_health.damage(10.0)
	_health.update(4.0)

	assert_float(_health.current).is_equal_approx(40.0, 0.001)


func test_zero_rate_never_regenerates() -> void:
	var enemy := HealthState.new(75.0)
	enemy.damage(25.0)

	enemy.update(60.0)

	assert_float(enemy.current).is_equal_approx(50.0, 0.001)


func test_dead_does_not_regenerate() -> void:
	_health.damage(MAX)

	_health.update(60.0)

	assert_float(_health.current).is_equal(0.0)
