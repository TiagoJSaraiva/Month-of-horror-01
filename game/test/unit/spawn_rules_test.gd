extends GdUnitTestSuite
## Surgimento no escuro: nada no limiar ou acima, e mais frequente quanto mais escuro.

const THRESHOLD := 0.5
const MIN_SECONDS := 6.0
const MAX_SECONDS := 20.0


func test_no_spawn_at_or_above_the_threshold() -> void:
	assert_float(_interval(THRESHOLD)).is_equal(SpawnRules.NO_SPAWN)
	assert_float(_interval(1.0)).is_equal(SpawnRules.NO_SPAWN)


func test_total_darkness_uses_the_minimum_interval() -> void:
	assert_float(_interval(0.0)).is_equal_approx(MIN_SECONDS, 0.001)


func test_just_below_the_threshold_is_close_to_the_maximum() -> void:
	assert_float(_interval(0.49)).is_between(MAX_SECONDS - 1.0, MAX_SECONDS)


func test_interval_shrinks_as_it_gets_darker() -> void:
	assert_float(_interval(0.2)).is_less(_interval(0.4))


func test_darkness_goes_from_zero_to_one() -> void:
	assert_float(SpawnRules.darkness(THRESHOLD, THRESHOLD)).is_equal(0.0)
	assert_float(SpawnRules.darkness(0.25, THRESHOLD)).is_equal_approx(0.5, 0.001)
	assert_float(SpawnRules.darkness(0.0, THRESHOLD)).is_equal_approx(1.0, 0.001)


func _interval(light_level: float) -> float:
	return SpawnRules.spawn_interval(light_level, THRESHOLD, MIN_SECONDS, MAX_SECONDS)
