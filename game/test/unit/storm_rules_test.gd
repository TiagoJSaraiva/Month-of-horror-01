extends GdUnitTestSuite
## Tempestade: só a partir da noite permitida, na janela de início, com a duração no
## intervalo, sempre antes do amanhecer, e intensidade com rampa de subida e descida.

const NIGHT_SECONDS: float = 420.0
const ROLLS: int = 30

var _settings: StormSettings
var _rng: RandomNumberGenerator


func before_test() -> void:
	_settings = StormSettings.new()
	_settings.chance = 1.0
	_rng = RandomNumberGenerator.new()
	_rng.seed = 7


func test_no_storm_before_the_first_allowed_night() -> void:
	var storm: StormPlan = StormRules.plan(
		_settings.first_night - 1, NIGHT_SECONDS, _settings, _rng
	)

	assert_bool(storm.has_storm).is_false()


func test_chance_decides_the_storm() -> void:
	_settings.chance = 0.0
	assert_bool(StormRules.plan(2, NIGHT_SECONDS, _settings, _rng).has_storm).is_false()

	_settings.chance = 1.0
	assert_bool(StormRules.plan(2, NIGHT_SECONDS, _settings, _rng).has_storm).is_true()


func test_start_and_duration_stay_in_their_ranges() -> void:
	for roll: int in ROLLS:
		var storm: StormPlan = StormRules.plan(2, NIGHT_SECONDS, _settings, _rng)
		assert_float(storm.start_seconds).is_between(
			_settings.start_window_min * NIGHT_SECONDS, _settings.start_window_max * NIGHT_SECONDS
		)
		assert_float(storm.duration_seconds).is_between(
			_settings.min_duration_seconds, _settings.max_duration_seconds
		)
		assert_float(storm.end_seconds()).is_less_equal(
			_settings.latest_end_fraction * NIGHT_SECONDS
		)


func test_short_night_shrinks_the_storm_to_fit() -> void:
	var short_night: float = 40.0

	var storm: StormPlan = StormRules.plan(2, short_night, _settings, _rng)

	assert_float(storm.start_seconds).is_greater_equal(0.0)
	assert_float(storm.end_seconds()).is_less_equal(
		_settings.latest_end_fraction * short_night + 0.001
	)


func test_strength_is_zero_outside_the_storm() -> void:
	var storm: StormPlan = _storm(100.0, 60.0)

	assert_float(StormRules.strength(50.0, storm, 8.0)).is_equal(0.0)
	assert_float(StormRules.strength(170.0, storm, 8.0)).is_equal(0.0)
	assert_float(StormRules.strength(130.0, StormPlan.new(), 8.0)).is_equal(0.0)


func test_strength_ramps_up_holds_and_ramps_down() -> void:
	var storm: StormPlan = _storm(100.0, 60.0)

	var rising: float = StormRules.strength(104.0, storm, 8.0)
	var peak: float = StormRules.strength(130.0, storm, 8.0)
	var falling: float = StormRules.strength(156.0, storm, 8.0)

	assert_float(rising).is_between(0.1, 0.9)
	assert_float(peak).is_equal_approx(1.0, 0.001)
	assert_float(falling).is_between(0.1, 0.9)


func test_strength_never_exceeds_one() -> void:
	var storm: StormPlan = _storm(0.0, 10.0)

	for step: int in 100:
		assert_float(StormRules.strength(step * 0.1, storm, 8.0)).is_between(0.0, 1.0)


func _storm(start: float, duration: float) -> StormPlan:
	var storm: StormPlan = StormPlan.new()
	storm.has_storm = true
	storm.start_seconds = start
	storm.duration_seconds = duration
	return storm
