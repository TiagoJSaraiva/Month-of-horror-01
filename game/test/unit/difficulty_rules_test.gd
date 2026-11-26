extends GdUnitTestSuite
## Dificuldade por noite: a noite 1 usa o valor inicial, o valor muda a cada noite e para no
## limite, para cima ou para baixo.


func test_first_night_uses_the_first_value() -> void:
	assert_float(DifficultyRules.value(_scaling(1.0, 0.2, 2.0), 1)).is_equal_approx(1.0, 0.001)


func test_value_grows_each_night() -> void:
	assert_float(DifficultyRules.value(_scaling(1.0, 0.2, 2.0), 3)).is_equal_approx(1.4, 0.001)


func test_growing_value_stops_at_the_limit() -> void:
	assert_float(DifficultyRules.value(_scaling(1.0, 0.2, 2.0), 20)).is_equal_approx(2.0, 0.001)


func test_falling_value_stops_at_the_limit() -> void:
	var scaling: ScalingValue = _scaling(1.0, -0.1, 0.5)

	assert_float(DifficultyRules.value(scaling, 3)).is_equal_approx(0.8, 0.001)
	assert_float(DifficultyRules.value(scaling, 20)).is_equal_approx(0.5, 0.001)


func test_mvp_curve_changes_nothing_on_the_first_night() -> void:
	var curve: DifficultyCurve = load("res://difficulty/difficulty_curve.tres")

	for scaling: ScalingValue in [
		curve.fishman_spawn_interval,
		curve.flyer_spawn_interval,
		curve.enemy_health,
		curve.enemy_damage,
		curve.maintenance_failures,
		curve.flashlight_battery,
		curve.storm_duration,
	]:
		assert_float(DifficultyRules.value(scaling, 1)).is_equal_approx(1.0, 0.001)
	# Tempestade só a partir da noite 2: a chance base de 50% vale nela.
	assert_float(DifficultyRules.value(curve.storm_chance, 2)).is_equal_approx(0.5, 0.001)


func _scaling(first: float, per_night: float, limit: float) -> ScalingValue:
	var scaling: ScalingValue = ScalingValue.new()
	scaling.first_night_value = first
	scaling.per_night = per_night
	scaling.limit = limit
	return scaling
