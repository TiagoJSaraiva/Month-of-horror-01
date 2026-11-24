extends GdUnitTestSuite
## Comportamento principal da dificuldade: uma noite avançada começa com a bateria menor e mais
## chance de tempestade que a primeira.

const NIGHT_SCENE := "res://night/night.tscn"
const LATE_NIGHT := 5
const BASE_BATTERY_SECONDS := 90.0


func test_late_night_is_harder_than_the_first() -> void:
	# Criada à mão para receber o número antes do _ready; auto_free a libera no fim do teste.
	var night := auto_free((load(NIGHT_SCENE) as PackedScene).instantiate()) as Night
	night.night_number = LATE_NIGHT
	var runner: GdUnitSceneRunner = scene_runner(night)
	var player := runner.find_child("Player") as Player
	var storm := runner.find_child("Storm") as Storm
	await await_millis(50)

	var battery: float = DifficultyRules.value(night.difficulty.flashlight_battery, LATE_NIGHT)
	assert_float(player.flashlight.battery_seconds).is_less(BASE_BATTERY_SECONDS)
	assert_float(player.flashlight.battery_seconds).is_equal_approx(
		BASE_BATTERY_SECONDS * battery, 0.01
	)
	assert_float(storm.settings.chance).is_greater(0.5)
	# O .tres compartilhado continua com a chance base.
	assert_float((load("res://night/storm_settings.tres") as StormSettings).chance).is_equal(0.5)
