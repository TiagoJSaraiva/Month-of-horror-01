extends GdUnitTestSuite
## Regras de tamanho e sorteio do pedido da noite.

var _mackerel: FishData
var _swordfish: FishData


func before_test() -> void:
	_mackerel = _fish(&"mackerel", "Mackerel")
	_swordfish = _fish(&"swordfish", "Swordfish")


func test_fish_count_grows_one_per_night() -> void:
	assert_int(OrderRules.fish_count(1)).is_equal(3)
	assert_int(OrderRules.fish_count(2)).is_equal(4)
	assert_int(OrderRules.fish_count(5)).is_equal(7)


func test_fish_count_never_below_first_night() -> void:
	assert_int(OrderRules.fish_count(0)).is_equal(3)


func test_generated_order_has_the_night_fish_count() -> void:
	var order: Dictionary[FishData, int] = OrderRules.generate(4, _species(), _rng(7))

	var total := 0
	for fish: FishData in order:
		total += order[fish]
	assert_int(total).is_equal(OrderRules.fish_count(4))


func test_generated_order_only_uses_given_species() -> void:
	var order: Dictionary[FishData, int] = OrderRules.generate(10, _species(), _rng(3))

	for fish: FishData in order:
		assert_bool(fish == _mackerel or fish == _swordfish).is_true()


func test_same_seed_gives_same_order() -> void:
	var first: Dictionary[FishData, int] = OrderRules.generate(6, _species(), _rng(42))
	var second: Dictionary[FishData, int] = OrderRules.generate(6, _species(), _rng(42))

	assert_dict(first).is_equal(second)


func test_empty_species_gives_empty_order() -> void:
	var no_species: Array[FishData] = []

	var order: Dictionary[FishData, int] = OrderRules.generate(1, no_species, _rng(1))

	assert_dict(order).is_empty()


func _species() -> Array[FishData]:
	return [_mackerel, _swordfish]


func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _fish(id: StringName, display_name: String) -> FishData:
	var fish := FishData.new()
	fish.id = id
	fish.display_name = display_name
	return fish
