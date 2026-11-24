extends GdUnitTestSuite
## Minijogo de pesca: barra, peixe e captura.

const STEP := 1.0 / 60.0

var _still_fish: FishData


func before_test() -> void:
	# Peixe parado, para os tempos de captura serem previsíveis.
	_still_fish = FishData.new()
	_still_fish.swim_speed = 0.0
	_still_fish.direction_changes_per_second = 0.0


func test_fish_inside_resting_bar_is_caught_in_about_two_seconds() -> void:
	var minigame: FishingMinigame = _minigame_with_fish_at(0.1, 1.0)

	_run(minigame, 2.0, false)
	assert_int(minigame.state).is_equal(FishingMinigame.State.RUNNING)

	_run(minigame, 0.5, false)
	assert_int(minigame.state).is_equal(FishingMinigame.State.CAUGHT)


func test_fish_outside_bar_escapes_in_about_one_and_a_half_seconds() -> void:
	var minigame: FishingMinigame = _minigame_with_fish_at(0.9, 1.0)

	_run(minigame, 1.4, false)
	assert_int(minigame.state).is_equal(FishingMinigame.State.RUNNING)

	_run(minigame, 0.2, false)
	assert_int(minigame.state).is_equal(FishingMinigame.State.ESCAPED)


func test_more_fishing_power_catches_faster() -> void:
	var weak: FishingMinigame = _minigame_with_fish_at(0.1, 1.0)
	var strong: FishingMinigame = _minigame_with_fish_at(0.1, 2.0)

	_run(weak, 1.3, false)
	_run(strong, 1.3, false)

	assert_int(weak.state).is_equal(FishingMinigame.State.RUNNING)
	assert_int(strong.state).is_equal(FishingMinigame.State.CAUGHT)


func test_reeling_raises_the_bar_but_keeps_it_on_the_track() -> void:
	var minigame: FishingMinigame = _minigame_with_fish_at(0.9, 1.0)

	_run(minigame, 0.3, true)
	assert_float(minigame.bar_position).is_greater(0.05)

	_run(minigame, 0.6, true)
	assert_float(minigame.bar_position).is_less_equal(1.0 - FishingMinigame.BAR_SIZE)


func test_released_bar_falls_back_to_the_bottom() -> void:
	var minigame: FishingMinigame = _minigame_with_fish_at(0.9, 1.0)
	_run(minigame, 0.3, true)

	_run(minigame, 1.0, false)

	assert_float(minigame.bar_position).is_equal_approx(0.0, 0.001)


func test_nothing_changes_after_the_end() -> void:
	var minigame: FishingMinigame = _minigame_with_fish_at(0.9, 1.0)
	_run(minigame, 2.0, false)
	var final_progress: float = minigame.progress

	_run(minigame, 1.0, true)

	assert_int(minigame.state).is_equal(FishingMinigame.State.ESCAPED)
	assert_float(minigame.progress).is_equal(final_progress)
	assert_float(minigame.bar_position).is_equal_approx(0.0, 0.001)


func _minigame_with_fish_at(position: float, fishing_power: float) -> FishingMinigame:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var minigame := FishingMinigame.new(_still_fish, fishing_power, rng)
	minigame.fish_position = position
	return minigame


func _run(minigame: FishingMinigame, seconds: float, reeling: bool) -> void:
	for _step in roundi(seconds / STEP):
		minigame.update(STEP, reeling)
