extends GdUnitTestSuite
## Nível de luz pelas lâmpadas boas e pelo gerador, e chance de falha independente dos quadros.


func test_all_bulbs_with_power_is_full_light() -> void:
	assert_float(LightingRules.light_level(6, 6, true)).is_equal_approx(1.0, 0.001)


func test_broken_bulbs_lower_the_light() -> void:
	assert_float(LightingRules.light_level(4, 6, true)).is_between(0.66, 0.67)


func test_no_power_is_darkness() -> void:
	assert_float(LightingRules.light_level(6, 6, false)).is_equal(0.0)


func test_no_bulbs_is_darkness() -> void:
	assert_float(LightingRules.light_level(0, 0, true)).is_equal(0.0)


func test_no_time_or_no_mean_never_fails() -> void:
	assert_float(LightingRules.failure_chance(0.0, 60.0)).is_equal(0.0)
	assert_float(LightingRules.failure_chance(1.0, 0.0)).is_equal(0.0)
	assert_float(LightingRules.failure_chance(1.0, -5.0)).is_equal(0.0)


func test_failure_chance_grows_with_time() -> void:
	var short_step: float = LightingRules.failure_chance(0.1, 60.0)
	var long_step: float = LightingRules.failure_chance(1.0, 60.0)

	assert_float(short_step).is_greater(0.0)
	assert_float(long_step).is_greater(short_step)
	assert_float(long_step).is_less(1.0)


func test_failure_over_one_mean_interval() -> void:
	# Num intervalo médio inteiro, a chance de pelo menos uma falha é 1 - 1/e.
	assert_float(LightingRules.failure_chance(60.0, 60.0)).is_between(0.63, 0.64)


func test_failure_chance_does_not_depend_on_frame_rate() -> void:
	var half: float = LightingRules.failure_chance(0.5, 60.0)
	var two_halves: float = 1.0 - (1.0 - half) * (1.0 - half)

	assert_float(two_halves).is_equal_approx(LightingRules.failure_chance(1.0, 60.0), 0.0001)


func test_no_storm_keeps_the_mean() -> void:
	assert_float(LightingRules.storm_mean(240.0, 0.0, 3.0)).is_equal_approx(240.0, 0.001)


func test_storm_peak_divides_the_mean_by_the_multiplier() -> void:
	assert_float(LightingRules.storm_mean(240.0, 1.0, 2.0)).is_equal_approx(120.0, 0.001)
	assert_float(LightingRules.storm_mean(240.0, 0.5, 3.0)).is_equal_approx(120.0, 0.001)


func test_disabled_failure_stays_disabled_in_the_storm() -> void:
	assert_float(LightingRules.storm_mean(0.0, 1.0, 3.0)).is_equal(0.0)
