extends GdUnitTestSuite
## Comportamento principal da tempestade: no pico, o balanço fica mais forte, o céu vai para a
## paleta da tempestade e a lua some; no fim, tudo volta ao normal.

const NIGHT_SCENE := "res://night/night.tscn"
const STORM_SECONDS := 1.0
const RAMP_SECONDS := 0.2


func test_storm_peaks_and_then_everything_calms_down() -> void:
	var runner: GdUnitSceneRunner = scene_runner(NIGHT_SCENE)
	var storm := runner.find_child("Storm") as Storm
	var sway := runner.find_child("OutsideWorld") as BoatSway
	var sky := runner.find_child("WorldEnvironment") as SkyCycle
	var moon := runner.find_child("Moon") as MoonArc
	storm.settings = _immediate_storm()
	storm.roll(1, RandomNumberGenerator.new())

	await await_millis(int(STORM_SECONDS * 500.0))

	assert_bool(storm.is_active()).is_true()
	assert_float(sway.effective_intensity()).is_greater(sway.intensity)
	assert_float(sky.storm_weight).is_greater(0.9)
	assert_float(moon.cloud_cover).is_greater(0.9)

	await await_millis(int(STORM_SECONDS * 1000.0))

	assert_bool(storm.is_active()).is_false()
	assert_float(sway.effective_intensity()).is_equal_approx(sway.intensity, 0.001)
	assert_float(sky.storm_weight).is_equal(0.0)
	assert_float(moon.cloud_cover).is_equal(0.0)


# Tempestade certa, começando já e durando STORM_SECONDS, com rampas curtas.
func _immediate_storm() -> StormSettings:
	var settings := StormSettings.new()
	settings.first_night = 1
	settings.chance = 1.0
	settings.start_window_min = 0.0
	settings.start_window_max = 0.0
	settings.min_duration_seconds = STORM_SECONDS
	settings.max_duration_seconds = STORM_SECONDS
	settings.ramp_seconds = RAMP_SECONDS
	return settings
