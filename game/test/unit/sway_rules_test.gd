extends GdUnitTestSuite
## Regra do balanço do barco.

const PITCH_AMPLITUDE := 0.03
const PITCH_PERIOD := 9.0
const ROLL_AMPLITUDE := 0.05
const ROLL_PERIOD := 7.0
const TOLERANCE := 0.0001


func test_angles_stay_within_amplitude() -> void:
	var intensity := 2.0
	for step in 300:
		var sway: Vector3 = _angles(step * 0.1, intensity)
		assert_float(absf(sway.x)).is_less_equal(PITCH_AMPLITUDE * intensity + TOLERANCE)
		assert_float(absf(sway.z)).is_less_equal(ROLL_AMPLITUDE * intensity + TOLERANCE)
		assert_float(sway.y).is_equal(0.0)


func test_zero_intensity_keeps_boat_still() -> void:
	for step in 50:
		var sway: Vector3 = _angles(step * 0.37, 0.0)
		assert_vector(sway).is_equal_approx(Vector3.ZERO, Vector3.ONE * TOLERANCE)


func test_each_axis_repeats_after_its_period() -> void:
	var time := 2.3

	var pitch_now: float = _angles(time, 1.0).x
	var pitch_later: float = _angles(time + PITCH_PERIOD, 1.0).x
	var roll_now: float = _angles(time, 1.0).z
	var roll_later: float = _angles(time + ROLL_PERIOD, 1.0).z

	assert_float(pitch_later).is_equal_approx(pitch_now, TOLERANCE)
	assert_float(roll_later).is_equal_approx(roll_now, TOLERANCE)


func test_non_positive_period_keeps_axis_still() -> void:
	var sway: Vector3 = SwayRules.angles(3.0, PITCH_AMPLITUDE, 0.0, ROLL_AMPLITUDE, -1.0, 1.0)

	assert_vector(sway).is_equal(Vector3.ZERO)


func _angles(time: float, intensity: float) -> Vector3:
	return SwayRules.angles(
		time, PITCH_AMPLITUDE, PITCH_PERIOD, ROLL_AMPLITUDE, ROLL_PERIOD, intensity
	)
