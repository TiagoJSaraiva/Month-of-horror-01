extends GdUnitTestSuite
## Gerador: funciona com combustível e sem quebra, e só gasta combustível funcionando.

const CAPACITY := 100.0

var _generator: GeneratorState
## Cada aviso de running_changed, na ordem. Array para a lambda alterar por referência.
var _announced: Array[bool] = []


func before_test() -> void:
	_generator = GeneratorState.new(CAPACITY)
	_announced = []
	_generator.running_changed.connect(func(running: bool) -> void: _announced.append(running))


func test_starts_full_and_running() -> void:
	assert_bool(_generator.is_running()).is_true()
	assert_float(_generator.fuel_ratio()).is_equal_approx(1.0, 0.001)
	assert_bool(_generator.needs_fuel()).is_false()


func test_running_burns_fuel() -> void:
	_generator.consume(25.0)

	assert_float(_generator.fuel_ratio()).is_equal_approx(0.75, 0.001)
	assert_bool(_generator.needs_fuel()).is_true()
	assert_array(_announced).is_empty()


func test_empty_tank_stops_and_announces_once() -> void:
	_generator.consume(60.0)
	_generator.consume(60.0)
	_generator.consume(60.0)

	assert_bool(_generator.is_running()).is_false()
	assert_float(_generator.fuel_seconds).is_equal(0.0)
	assert_array(_announced).is_equal([false])


func test_refuel_fills_and_restarts() -> void:
	_generator.consume(CAPACITY)

	_generator.refuel()

	assert_bool(_generator.is_running()).is_true()
	assert_float(_generator.fuel_ratio()).is_equal_approx(1.0, 0.001)
	assert_array(_announced).is_equal([false, true])


func test_broken_generator_stops_without_burning_fuel() -> void:
	_generator.break_down()
	_generator.consume(50.0)

	assert_bool(_generator.is_running()).is_false()
	assert_float(_generator.fuel_ratio()).is_equal_approx(1.0, 0.001)
	assert_array(_announced).is_equal([false])


func test_repair_restarts() -> void:
	_generator.break_down()

	_generator.repair()

	assert_bool(_generator.is_running()).is_true()
	assert_array(_announced).is_equal([false, true])


func test_repair_without_fuel_stays_stopped() -> void:
	_generator.consume(CAPACITY)
	_generator.break_down()

	_generator.repair()

	assert_bool(_generator.is_running()).is_false()
	assert_array(_announced).is_equal([false])


func test_zero_capacity_never_runs() -> void:
	var empty := GeneratorState.new(0.0)

	assert_bool(empty.is_running()).is_false()
	assert_float(empty.fuel_ratio()).is_equal(0.0)
