extends GdUnitTestSuite
## Regras de tempo da noite: progresso, hora do jogo e ponteiros.

const TOLERANCE: float = 0.001


func test_progress_goes_from_zero_to_one() -> void:
	assert_float(NightTimeRules.progress(0.0, 420.0)).is_equal_approx(0.0, TOLERANCE)
	assert_float(NightTimeRules.progress(210.0, 420.0)).is_equal_approx(0.5, TOLERANCE)
	assert_float(NightTimeRules.progress(420.0, 420.0)).is_equal_approx(1.0, TOLERANCE)


func test_progress_is_clamped() -> void:
	assert_float(NightTimeRules.progress(-5.0, 420.0)).is_equal_approx(0.0, TOLERANCE)
	assert_float(NightTimeRules.progress(999.0, 420.0)).is_equal_approx(1.0, TOLERANCE)


func test_non_positive_duration_is_already_dawn() -> void:
	assert_float(NightTimeRules.progress(0.0, 0.0)).is_equal_approx(1.0, TOLERANCE)


func test_clock_runs_from_eleven_pm_to_six_am() -> void:
	assert_float(NightTimeRules.clock_minutes(0.0)).is_equal_approx(23 * 60, TOLERANCE)
	assert_float(NightTimeRules.clock_minutes(0.5)).is_equal_approx(2 * 60 + 30, TOLERANCE)
	assert_float(NightTimeRules.clock_minutes(1.0)).is_equal_approx(6 * 60, TOLERANCE)


func test_hands_at_six_am() -> void:
	var angles: Vector2 = NightTimeRules.hand_angles(6 * 60)

	assert_float(angles.x).is_equal_approx(PI, TOLERANCE)
	assert_float(angles.y).is_equal_approx(0.0, TOLERANCE)


func test_hands_at_eleven_thirty_pm() -> void:
	var angles: Vector2 = NightTimeRules.hand_angles(23 * 60 + 30)

	assert_float(angles.x).is_equal_approx(11.5 / 12.0 * TAU, TOLERANCE)
	assert_float(angles.y).is_equal_approx(PI, TOLERANCE)
