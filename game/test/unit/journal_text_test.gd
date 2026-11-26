extends GdUnitTestSuite
## Texto do diário: noite atual e andamento do pedido.

var _mackerel: FishData
var _swordfish: FishData
var _order: NightOrder


func before_test() -> void:
	_mackerel = _fish(&"mackerel", "Mackerel")
	_swordfish = _fish(&"swordfish", "Swordfish")
	# Swordfish primeiro, para confirmar que o texto ordena por nome.
	var required: Dictionary[FishData, int] = {_swordfish: 1, _mackerel: 2}
	_order = NightOrder.new(required)


func test_shows_night_number() -> void:
	var text: String = JournalText.compose(3, _order)

	assert_str(text).starts_with("NIGHT 3")


func test_lists_each_species_in_alphabetical_order() -> void:
	var lines: PackedStringArray = JournalText.compose(1, _order).split("\n")

	assert_str(lines[2]).is_equal("Mackerel 0/2")
	assert_str(lines[3]).is_equal("Swordfish 0/1")


func test_shows_delivered_fish() -> void:
	_order.deliver(_mackerel)

	var text: String = JournalText.compose(1, _order)

	assert_str(text).contains("Mackerel 1/2")


func _fish(id: StringName, display_name: String) -> FishData:
	var fish: FishData = FishData.new()
	fish.id = id
	fish.display_name = display_name
	return fish
