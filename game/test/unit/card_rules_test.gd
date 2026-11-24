extends GdUnitTestSuite
## Cartas: raridade pelas chances, seleção sem repetir, raridade sem cartas cai para a próxima,
## pool pequeno ou vazio e soma dos bônus.

const COMMON_CHANCE := 0.6
const RARE_CHANCE := 0.3

var _rng: RandomNumberGenerator


func before_test() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.seed = 11


func test_rarity_follows_the_chances() -> void:
	assert_int(_rarity(0.0)).is_equal(CardData.Rarity.COMMON)
	assert_int(_rarity(0.59)).is_equal(CardData.Rarity.COMMON)
	assert_int(_rarity(0.6)).is_equal(CardData.Rarity.RARE)
	assert_int(_rarity(0.89)).is_equal(CardData.Rarity.RARE)
	assert_int(_rarity(0.9)).is_equal(CardData.Rarity.LEGENDARY)


func test_selection_has_three_different_cards() -> void:
	var pool: Array[CardData] = _pool(3, 3, 3)

	for roll: int in 20:
		var selection: Array[CardData] = _draw(pool, 3)
		assert_int(selection.size()).is_equal(3)
		assert_bool(selection[0] != selection[1] and selection[1] != selection[2]).is_true()
		assert_bool(selection[0] != selection[2]).is_true()


func test_missing_rarity_falls_back_to_the_next_available() -> void:
	var only_legendary: Array[CardData] = _pool(0, 0, 2)

	var selection: Array[CardData] = _draw(only_legendary, 2)

	assert_int(selection.size()).is_equal(2)
	for card: CardData in selection:
		assert_int(card.rarity).is_equal(CardData.Rarity.LEGENDARY)


func test_fallback_tries_lower_rarities_first() -> void:
	assert_array(CardRules.fallback_order(CardData.Rarity.LEGENDARY)).is_equal(
		[CardData.Rarity.LEGENDARY, CardData.Rarity.RARE, CardData.Rarity.COMMON]
	)
	assert_array(CardRules.fallback_order(CardData.Rarity.COMMON)).is_equal(
		[CardData.Rarity.COMMON, CardData.Rarity.RARE, CardData.Rarity.LEGENDARY]
	)


func test_small_pool_gives_a_smaller_selection() -> void:
	assert_int(_draw(_pool(1, 1, 0), 3).size()).is_equal(2)
	assert_int(_draw(_pool(0, 0, 0), 3).size()).is_equal(0)


func test_percents_of_the_same_stat_add_up() -> void:
	var cards: Array[CardData] = [
		_card(CardData.Rarity.COMMON, StatModifier.Stat.MAX_HEALTH, 20.0),
		_card(CardData.Rarity.COMMON, StatModifier.Stat.MAX_HEALTH, 10.0),
		_card(CardData.Rarity.RARE, StatModifier.Stat.MOVE_SPEED, 20.0),
	]

	assert_float(CardRules.total_percent(cards, StatModifier.Stat.MAX_HEALTH)).is_equal(30.0)
	assert_float(CardRules.total_percent(cards, StatModifier.Stat.FIRE_RATE)).is_equal(0.0)


func test_mvp_pool_has_three_cards_of_each_rarity() -> void:
	var pool: CardPool = load("res://cards/card_pool.tres")

	assert_int(pool.cards.size()).is_equal(9)
	for rarity: CardData.Rarity in CardData.Rarity.values():
		assert_int(CardRules._of_rarity(pool.cards, rarity).size()).is_equal(3)
	for card: CardData in pool.cards:
		assert_bool(card.modifiers.is_empty()).is_false()


func _rarity(roll: float) -> CardData.Rarity:
	return CardRules.roll_rarity(roll, COMMON_CHANCE, RARE_CHANCE)


func _draw(pool: Array[CardData], size: int) -> Array[CardData]:
	return CardRules.draw_selection(pool, size, COMMON_CHANCE, RARE_CHANCE, _rng)


func _pool(commons: int, rares: int, legendaries: int) -> Array[CardData]:
	var pool: Array[CardData] = []
	for i: int in commons:
		pool.append(_card(CardData.Rarity.COMMON, StatModifier.Stat.MAX_HEALTH, 10.0))
	for i: int in rares:
		pool.append(_card(CardData.Rarity.RARE, StatModifier.Stat.MAX_HEALTH, 10.0))
	for i: int in legendaries:
		pool.append(_card(CardData.Rarity.LEGENDARY, StatModifier.Stat.MAX_HEALTH, 10.0))
	return pool


func _card(rarity: CardData.Rarity, stat: StatModifier.Stat, percent: float) -> CardData:
	var modifier := StatModifier.new()
	modifier.stat = stat
	modifier.percent = percent
	var card := CardData.new()
	card.rarity = rarity
	card.modifiers = [modifier]
	return card
