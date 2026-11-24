extends GdUnitTestSuite
## Bônus da run: o valor final soma os percentuais das cartas, tempos diminuem com percentuais
## negativos e a chance vem em fração.


func test_no_cards_keeps_the_base_value() -> void:
	var stats: PlayerStats = PlayerStats.from_cards([])

	assert_float(stats.apply(StatModifier.Stat.MAX_HEALTH, 100.0)).is_equal_approx(100.0, 0.001)
	assert_float(stats.chance(StatModifier.Stat.DOUBLE_FISH_CHANCE)).is_equal(0.0)


func test_cards_raise_the_value() -> void:
	var stats: PlayerStats = PlayerStats.from_cards(
		[_card(StatModifier.Stat.MAX_HEALTH, 20.0), _card(StatModifier.Stat.MAX_HEALTH, 10.0)]
	)

	assert_float(stats.apply(StatModifier.Stat.MAX_HEALTH, 100.0)).is_equal_approx(130.0, 0.001)


func test_negative_percent_shortens_a_time() -> void:
	var stats: PlayerStats = PlayerStats.from_cards(
		[_card(StatModifier.Stat.MAINTENANCE_TIME, -50.0)]
	)

	assert_float(stats.apply(StatModifier.Stat.MAINTENANCE_TIME, 4.0)).is_equal_approx(2.0, 0.001)


func test_value_never_goes_negative() -> void:
	var stats: PlayerStats = PlayerStats.from_cards(
		[_card(StatModifier.Stat.RELOAD_TIME, -80.0), _card(StatModifier.Stat.RELOAD_TIME, -80.0)]
	)

	assert_float(stats.apply(StatModifier.Stat.RELOAD_TIME, 2.0)).is_equal(0.0)


func test_chance_is_a_fraction() -> void:
	var stats: PlayerStats = PlayerStats.from_cards(
		[_card(StatModifier.Stat.DOUBLE_FISH_CHANCE, 50.0)]
	)

	assert_float(stats.chance(StatModifier.Stat.DOUBLE_FISH_CHANCE)).is_equal_approx(0.5, 0.001)


func test_cards_and_upgrades_add_up() -> void:
	var upgrades: Dictionary[StatModifier.Stat, float] = {StatModifier.Stat.MAX_HEALTH: 10.0}

	var stats: PlayerStats = PlayerStats.from_sources(
		[_card(StatModifier.Stat.MAX_HEALTH, 20.0)], upgrades
	)

	assert_float(stats.apply(StatModifier.Stat.MAX_HEALTH, 100.0)).is_equal_approx(130.0, 0.001)


func _card(stat: StatModifier.Stat, percent: float) -> CardData:
	var modifier := StatModifier.new()
	modifier.stat = stat
	modifier.percent = percent
	var card := CardData.new()
	card.modifiers = [modifier]
	return card
