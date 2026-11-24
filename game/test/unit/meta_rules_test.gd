extends GdUnitTestSuite
## Meta-progressão: pontos por noite cumprida e por peixe, custo crescente e compra só com pontos
## e abaixo do nível máximo.


func test_run_points_count_nights_and_fish() -> void:
	assert_int(MetaRules.run_points(2, 7)).is_equal(27)
	assert_int(MetaRules.run_points(0, 0)).is_equal(0)


func test_upgrade_cost_grows_with_the_level() -> void:
	assert_int(MetaRules.upgrade_cost(20, 0)).is_equal(20)
	assert_int(MetaRules.upgrade_cost(20, 1)).is_equal(40)
	assert_int(MetaRules.upgrade_cost(20, 4)).is_equal(100)


func test_mvp_upgrades_load_with_their_stats() -> void:
	var expected: Dictionary[String, StatModifier.Stat] = {
		"health": StatModifier.Stat.MAX_HEALTH,
		"damage": StatModifier.Stat.WEAPON_DAMAGE,
		"rod_power": StatModifier.Stat.FISHING_POWER,
	}
	for id: String in expected:
		var upgrade: UpgradeData = load("res://meta/upgrades/%s.tres" % id)
		assert_int(upgrade.stat).is_equal(expected[id])
		assert_int(upgrade.max_level).is_equal(5)
		assert_float(upgrade.percent_per_level).is_equal(10.0)


func test_buying_needs_points_and_a_free_level() -> void:
	assert_bool(MetaRules.can_buy(40, 1, 5, 40)).is_true()
	assert_bool(MetaRules.can_buy(39, 1, 5, 40)).is_false()
	assert_bool(MetaRules.can_buy(500, 5, 5, 120)).is_false()
