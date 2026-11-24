extends GdUnitTestSuite
## Regras das mãos: uma coisa por vez entre ferramenta, diário e peixe carregado.

var _hands: HandsState
var _mackerel: FishData


func before_test() -> void:
	_hands = HandsState.new()
	_mackerel = FishData.new()
	_mackerel.id = &"mackerel"


func test_starts_with_tool_ready() -> void:
	assert_int(_hands.mode).is_equal(HandsState.Mode.TOOL)
	assert_bool(_hands.can_use_tool()).is_true()
	assert_bool(_hands.can_take_item()).is_true()


func test_journal_toggles_open_and_closed() -> void:
	assert_bool(_hands.toggle_journal()).is_true()
	assert_int(_hands.mode).is_equal(HandsState.Mode.JOURNAL)
	assert_bool(_hands.can_use_tool()).is_false()

	assert_bool(_hands.toggle_journal()).is_true()
	assert_int(_hands.mode).is_equal(HandsState.Mode.TOOL)


func test_journal_stays_closed_while_line_is_out() -> void:
	_hands.tool_busy = true

	assert_bool(_hands.toggle_journal()).is_false()
	assert_int(_hands.mode).is_equal(HandsState.Mode.TOOL)


func test_journal_stays_closed_while_carrying() -> void:
	_hands.start_carrying(_mackerel, 1)

	assert_bool(_hands.toggle_journal()).is_false()
	assert_int(_hands.mode).is_equal(HandsState.Mode.CARRYING)


func test_carrying_needs_free_hands() -> void:
	_hands.tool_busy = true
	assert_bool(_hands.start_carrying(_mackerel, 1)).is_false()

	_hands.tool_busy = false
	_hands.toggle_journal()
	assert_bool(_hands.start_carrying(_mackerel, 1)).is_false()


func test_carrying_blocks_the_tool() -> void:
	assert_bool(_hands.start_carrying(_mackerel, 2)).is_true()

	assert_bool(_hands.is_carrying()).is_true()
	assert_bool(_hands.can_use_tool()).is_false()
	assert_object(_hands.carried_fish).is_same(_mackerel)
	assert_int(_hands.carried_amount).is_equal(2)


func test_invalid_fish_or_amount_is_not_carried() -> void:
	assert_bool(_hands.start_carrying(null, 1)).is_false()
	assert_bool(_hands.start_carrying(_mackerel, 0)).is_false()
	assert_bool(_hands.is_carrying()).is_false()


func test_stop_carrying_frees_the_hands() -> void:
	_hands.start_carrying(_mackerel, 1)

	_hands.stop_carrying()

	assert_int(_hands.mode).is_equal(HandsState.Mode.TOOL)
	assert_object(_hands.carried_fish).is_null()
	assert_int(_hands.carried_amount).is_equal(0)


func test_changes_are_announced() -> void:
	# Array para a lambda alterar o contador por referência.
	var emissions: Array[int] = [0]
	_hands.changed.connect(func() -> void: emissions[0] += 1)

	_hands.toggle_journal()
	_hands.toggle_journal()
	_hands.start_carrying(_mackerel, 1)
	_hands.stop_carrying()

	assert_int(emissions[0]).is_equal(4)
