extends GdUnitTestSuite
## Estado da run: noites, falhas e passe livre.

var _state: RunState


func before_test() -> void:
	_state = RunState.new()


func test_starts_on_night_one_with_all_lives() -> void:
	assert_int(_state.night_number).is_equal(1)
	assert_int(_state.lives_left()).is_equal(3)
	assert_bool(_state.is_over()).is_false()


func test_completed_night_moves_to_the_next_one() -> void:
	var outcome: RunRules.Outcome = _state.finish_night(0)

	assert_int(outcome).is_equal(RunRules.Outcome.COMPLETED)
	assert_int(_state.night_number).is_equal(2)
	assert_int(_state.failures).is_equal(0)


func test_free_pass_works_only_once_and_costs_no_life() -> void:
	var first: RunRules.Outcome = _state.finish_night(1)
	var second: RunRules.Outcome = _state.finish_night(1)

	assert_int(first).is_equal(RunRules.Outcome.FREE_PASS)
	assert_int(second).is_equal(RunRules.Outcome.FAILED)
	assert_int(_state.failures).is_equal(1)


func test_three_failures_apart_end_the_run() -> void:
	_state.finish_night(3)
	_state.finish_night(0)
	_state.finish_night(2)
	assert_bool(_state.is_over()).is_false()

	_state.finish_night(4)

	assert_bool(_state.is_over()).is_true()
	assert_int(_state.lives_left()).is_equal(0)


func test_night_does_not_advance_when_the_run_ends() -> void:
	_state.finish_night(5)
	_state.finish_night(5)

	_state.finish_night(5)

	assert_int(_state.night_number).is_equal(3)


func test_last_outcome_is_remembered() -> void:
	_state.finish_night(2)

	assert_int(_state.last_outcome).is_equal(RunRules.Outcome.FAILED)


func test_death_ends_the_run_on_the_current_night() -> void:
	_state.finish_night(0)

	_state.die()

	assert_bool(_state.is_over()).is_true()
	assert_int(_state.night_number).is_equal(2)
	assert_int(_state.failures).is_equal(0)
