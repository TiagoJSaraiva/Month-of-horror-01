extends GdUnitTestSuite
## Regras da run: resultado da noite, bilhete e alfinete.


func test_nothing_missing_completes_the_night() -> void:
	assert_int(RunRules.evaluate_night(0, true)).is_equal(RunRules.Outcome.COMPLETED)
	assert_int(RunRules.evaluate_night(0, false)).is_equal(RunRules.Outcome.COMPLETED)


func test_one_missing_uses_the_free_pass_when_available() -> void:
	assert_int(RunRules.evaluate_night(1, true)).is_equal(RunRules.Outcome.FREE_PASS)


func test_one_missing_without_free_pass_fails() -> void:
	assert_int(RunRules.evaluate_night(1, false)).is_equal(RunRules.Outcome.FAILED)


func test_two_missing_fails_even_with_free_pass() -> void:
	assert_int(RunRules.evaluate_night(2, true)).is_equal(RunRules.Outcome.FAILED)


func test_first_night_gets_the_intro_note() -> void:
	var kind: RunRules.NoteKind = RunRules.note_kind(RunRules.Outcome.NONE, 0)

	assert_int(kind).is_equal(RunRules.NoteKind.INTRO)
	assert_int(RunRules.pin_for(kind)).is_equal(RunRules.Pin.BLUE)


func test_completed_and_free_pass_nights_get_blue_notes() -> void:
	var completed: RunRules.NoteKind = RunRules.note_kind(RunRules.Outcome.COMPLETED, 1)
	var free_pass: RunRules.NoteKind = RunRules.note_kind(RunRules.Outcome.FREE_PASS, 0)

	assert_int(completed).is_equal(RunRules.NoteKind.COMPLETED)
	assert_int(free_pass).is_equal(RunRules.NoteKind.FREE_PASS)
	assert_int(RunRules.pin_for(completed)).is_equal(RunRules.Pin.BLUE)
	assert_int(RunRules.pin_for(free_pass)).is_equal(RunRules.Pin.BLUE)


func test_first_failure_gets_a_yellow_warning() -> void:
	var kind: RunRules.NoteKind = RunRules.note_kind(RunRules.Outcome.FAILED, 1)

	assert_int(kind).is_equal(RunRules.NoteKind.FIRST_WARNING)
	assert_int(RunRules.pin_for(kind)).is_equal(RunRules.Pin.YELLOW)


func test_second_failure_gets_a_red_warning() -> void:
	var kind: RunRules.NoteKind = RunRules.note_kind(RunRules.Outcome.FAILED, 2)

	assert_int(kind).is_equal(RunRules.NoteKind.LAST_WARNING)
	assert_int(RunRules.pin_for(kind)).is_equal(RunRules.Pin.RED)


func test_note_lines_pick_the_text_for_each_kind() -> void:
	var lines: NoteLines = NoteLines.new()
	lines.intro = "intro"
	lines.last_warning = "last"

	assert_str(lines.text_for(RunRules.NoteKind.INTRO)).is_equal("intro")
	assert_str(lines.text_for(RunRules.NoteKind.LAST_WARNING)).is_equal("last")


func test_broken_deal_counts_the_last_night_as_survived() -> void:
	assert_int(RunRules.nights_survived(3, false)).is_equal(3)


func test_death_does_not_count_the_night_it_happened() -> void:
	assert_int(RunRules.nights_survived(3, true)).is_equal(2)
	assert_int(RunRules.nights_survived(1, true)).is_equal(0)
