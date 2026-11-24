class_name Freezer
extends Interactable
## Freezer da cabine. Um peixe só conta para o pedido depois de guardado aqui.

signal fish_stored(fish: FishData, amount: int)


func get_prompt(hands: Hands) -> String:
	if not hands.state.is_carrying():
		return ""
	return "Store %s" % hands.state.carried_fish.display_name


func interact(hands: Hands) -> void:
	if not hands.state.is_carrying():
		return
	var fish: FishData = hands.state.carried_fish
	var amount: int = hands.state.carried_amount
	hands.state.stop_carrying()
	fish_stored.emit(fish, amount)
