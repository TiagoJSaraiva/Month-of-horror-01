extends GdUnitTestSuite
## Pedido da noite: entregas, faltantes e aviso de mudança.

var _mackerel: FishData
var _swordfish: FishData
var _order: NightOrder


func before_test() -> void:
	_mackerel = _fish(&"mackerel", "Mackerel")
	_swordfish = _fish(&"swordfish", "Swordfish")
	var required: Dictionary[FishData, int] = {_mackerel: 2, _swordfish: 1}
	_order = NightOrder.new(required)


func test_new_order_misses_every_fish() -> void:
	assert_int(_order.missing_total()).is_equal(3)
	assert_bool(_order.is_complete()).is_false()
	assert_int(_order.delivered_count(_mackerel)).is_equal(0)


func test_delivering_reduces_missing() -> void:
	_order.deliver(_mackerel)

	assert_int(_order.delivered_count(_mackerel)).is_equal(1)
	assert_int(_order.missing_total()).is_equal(2)


func test_extra_deliveries_do_not_go_below_zero() -> void:
	_order.deliver(_swordfish, 3)

	assert_int(_order.delivered_count(_swordfish)).is_equal(3)
	assert_int(_order.missing_total()).is_equal(2)


func test_fish_outside_order_does_not_reduce_missing() -> void:
	var cod: FishData = _fish(&"cod", "Cod")

	_order.deliver(cod)

	assert_int(_order.delivered_count(cod)).is_equal(1)
	assert_int(_order.missing_total()).is_equal(3)


func test_is_complete_when_every_fish_is_delivered() -> void:
	_order.deliver(_mackerel, 2)
	_order.deliver(_swordfish)

	assert_bool(_order.is_complete()).is_true()


func test_non_positive_amount_is_ignored() -> void:
	_order.deliver(_mackerel, 0)
	_order.deliver(_mackerel, -2)

	assert_int(_order.delivered_count(_mackerel)).is_equal(0)


func test_deliver_emits_changed() -> void:
	# Array para a lambda alterar o contador por referência.
	var emissions: Array[int] = [0]
	_order.changed.connect(func() -> void: emissions[0] += 1)

	_order.deliver(_mackerel)

	assert_int(emissions[0]).is_equal(1)


func test_species_lists_the_ordered_fish() -> void:
	assert_array(_order.species()).contains_exactly_in_any_order([_mackerel, _swordfish])


func _fish(id: StringName, display_name: String) -> FishData:
	var fish := FishData.new()
	fish.id = id
	fish.display_name = display_name
	return fish
