extends GdUnitTestSuite
## Tentativa de pesca: espera, mordida, fisgada, puxada e fim.

const STEP := 1.0 / 60.0
const BITE_DELAY := 1.0

var _fish: FishData
var _attempt: FishingAttempt


func before_test() -> void:
	# Mordida em tempo fixo e peixe parado no minijogo, para tempos previsíveis.
	_fish = FishData.new()
	_fish.bite_delay_min = BITE_DELAY
	_fish.bite_delay_max = BITE_DELAY
	_fish.swim_speed = 0.0
	_fish.direction_changes_per_second = 0.0
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	_attempt = FishingAttempt.new(_fish, 1.0, rng)


func test_bite_happens_after_the_species_delay() -> void:
	_run(BITE_DELAY - 0.1)
	assert_int(_attempt.state).is_equal(FishingAttempt.State.WAITING)

	_run(0.2)
	assert_int(_attempt.state).is_equal(FishingAttempt.State.BITING)


func test_bite_delay_stays_inside_the_species_range() -> void:
	_fish.bite_delay_min = 2.0
	_fish.bite_delay_max = 5.0
	for seed_value in 20:
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_value
		var attempt := FishingAttempt.new(_fish, 1.0, rng)
		var waited := 0.0
		while attempt.state == FishingAttempt.State.WAITING and waited < 10.0:
			attempt.update(STEP, false)
			waited += STEP
		assert_float(waited).is_between(2.0 - STEP, 5.0 + STEP)


func test_hooking_during_the_bite_starts_the_minigame() -> void:
	_run(BITE_DELAY + 0.1)

	_attempt.hook()

	assert_int(_attempt.state).is_equal(FishingAttempt.State.REELING)
	assert_object(_attempt.minigame).is_not_null()


func test_missing_the_hook_window_lets_the_fish_escape() -> void:
	_run(BITE_DELAY + 0.1)

	_run(FishingAttempt.HOOK_WINDOW_SECONDS + 0.1)

	assert_int(_attempt.state).is_equal(FishingAttempt.State.ESCAPED)


func test_hooking_too_early_just_reels_in() -> void:
	_attempt.hook()

	assert_int(_attempt.state).is_equal(FishingAttempt.State.CANCELLED)
	assert_bool(_attempt.is_finished()).is_true()


func test_cancelling_while_reeling_lets_the_fish_escape() -> void:
	_run(BITE_DELAY + 0.1)
	_attempt.hook()

	_attempt.cancel()

	assert_int(_attempt.state).is_equal(FishingAttempt.State.ESCAPED)


func test_winning_the_minigame_catches_the_fish() -> void:
	_run(BITE_DELAY + 0.1)
	_attempt.hook()
	_attempt.minigame.fish_position = 0.1

	_run(3.0)

	assert_int(_attempt.state).is_equal(FishingAttempt.State.CAUGHT)


func test_each_state_change_is_announced() -> void:
	var states: Array[FishingAttempt.State] = []
	_attempt.state_changed.connect(func(state: FishingAttempt.State) -> void: states.append(state))

	_run(BITE_DELAY + 0.1)
	_attempt.hook()
	_attempt.cancel()

	assert_array(states).is_equal(
		[FishingAttempt.State.BITING, FishingAttempt.State.REELING, FishingAttempt.State.ESCAPED]
	)


func _run(seconds: float) -> void:
	for _step in roundi(seconds / STEP):
		_attempt.update(STEP, false)
