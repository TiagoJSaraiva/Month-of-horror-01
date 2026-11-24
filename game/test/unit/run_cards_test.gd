extends GdUnitTestSuite
## Cartas da run: escolher ocupa slot e tira do pool, substituir não devolve a antiga, recusar
## só com os slots cheios e mantém a carta no pool, 3 rerolls por run.

var _state: RunState
var _cards: Array[CardData] = []


func before_test() -> void:
	_cards = []
	for i: int in 5:
		_cards.append(CardData.new())
	_state = RunState.new()
	_state.start_card_pool(_cards)


func test_choosing_equips_and_removes_from_the_pool() -> void:
	assert_bool(_state.choose(_cards[0])).is_true()

	assert_array(_state.equipped).contains_exactly([_cards[0]])
	assert_bool(_state.card_pool.has(_cards[0])).is_false()
	assert_int(_state.card_pool.size()).is_equal(4)


func test_slots_are_limited_to_three() -> void:
	_fill_slots()

	assert_bool(_state.slots_full()).is_true()
	assert_bool(_state.choose(_cards[3])).is_false()
	assert_int(_state.equipped.size()).is_equal(RunState.CARD_SLOTS)


func test_refuse_needs_full_slots() -> void:
	assert_bool(_state.can_refuse()).is_false()

	_fill_slots()

	assert_bool(_state.can_refuse()).is_true()
	assert_bool(_state.card_pool.has(_cards[3])).is_true()


func test_replaced_card_does_not_return_to_the_pool() -> void:
	_fill_slots()

	assert_bool(_state.replace(_cards[1], _cards[3])).is_true()

	assert_array(_state.equipped).contains_exactly([_cards[0], _cards[3], _cards[2]])
	assert_bool(_state.card_pool.has(_cards[1])).is_false()
	assert_bool(_state.card_pool.has(_cards[3])).is_false()


func test_replace_needs_an_equipped_card_and_a_pool_card() -> void:
	_fill_slots()

	assert_bool(_state.replace(_cards[4], _cards[3])).is_false()
	assert_bool(_state.replace(_cards[0], _cards[1])).is_false()


func test_three_rerolls_per_run() -> void:
	for i: int in RunState.REROLLS_PER_RUN:
		assert_bool(_state.use_reroll()).is_true()

	assert_bool(_state.use_reroll()).is_false()
	assert_int(_state.rerolls_left).is_equal(0)


func test_pool_is_a_copy() -> void:
	_state.choose(_cards[0])

	assert_int(_cards.size()).is_equal(5)


func _fill_slots() -> void:
	for i: int in RunState.CARD_SLOTS:
		_state.choose(_cards[i])
