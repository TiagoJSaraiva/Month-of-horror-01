extends GdUnitTestSuite
## Regras do céu provisório: amanhecer e caminho da lua.

const DAWN_START := 6.0 / 7.0
const MIN_ELEVATION := 0.2
const MAX_ELEVATION := 1.0
const TOLERANCE := 0.0001


func test_dawn_blend_is_zero_before_dawn_starts() -> void:
	assert_float(SkyRules.dawn_blend(0.0, DAWN_START)).is_equal_approx(0.0, TOLERANCE)
	assert_float(SkyRules.dawn_blend(DAWN_START, DAWN_START)).is_equal_approx(0.0, TOLERANCE)


func test_dawn_blend_is_one_at_six_am() -> void:
	assert_float(SkyRules.dawn_blend(1.0, DAWN_START)).is_equal_approx(1.0, TOLERANCE)


func test_dawn_blend_never_decreases() -> void:
	var previous := 0.0
	for step in 101:
		var blend: float = SkyRules.dawn_blend(step / 100.0, DAWN_START)
		assert_float(blend).is_greater_equal(previous - TOLERANCE)
		previous = blend


func test_dawn_start_at_end_only_blends_at_six_am() -> void:
	assert_float(SkyRules.dawn_blend(0.99, 1.0)).is_equal_approx(0.0, TOLERANCE)
	assert_float(SkyRules.dawn_blend(1.0, 1.0)).is_equal_approx(1.0, TOLERANCE)


func test_moon_rises_east_and_sets_west_low() -> void:
	var rise: Vector2 = SkyRules.moon_angles(0.0, MIN_ELEVATION, MAX_ELEVATION)
	var set_angles: Vector2 = SkyRules.moon_angles(1.0, MIN_ELEVATION, MAX_ELEVATION)

	assert_float(rise.x).is_equal_approx(MIN_ELEVATION, TOLERANCE)
	assert_float(rise.y).is_equal_approx(PI / 2.0, TOLERANCE)
	assert_float(set_angles.x).is_equal_approx(MIN_ELEVATION, TOLERANCE)
	assert_float(set_angles.y).is_equal_approx(-PI / 2.0, TOLERANCE)


func test_moon_is_highest_at_midnight_half() -> void:
	var middle: Vector2 = SkyRules.moon_angles(0.5, MIN_ELEVATION, MAX_ELEVATION)

	assert_float(middle.x).is_equal_approx(MAX_ELEVATION, TOLERANCE)
	assert_float(middle.y).is_equal_approx(0.0, TOLERANCE)


func test_moon_progress_is_clamped() -> void:
	var before: Vector2 = SkyRules.moon_angles(-1.0, MIN_ELEVATION, MAX_ELEVATION)

	assert_vector(before).is_equal_approx(
		SkyRules.moon_angles(0.0, MIN_ELEVATION, MAX_ELEVATION), Vector2.ONE * TOLERANCE
	)
