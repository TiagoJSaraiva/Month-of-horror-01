class_name Freezer
extends Interactable
## Freezer da cabine. Um peixe só conta para o pedido depois de guardado aqui.

signal fish_stored(fish: FishData, amount: int)


## Dica de interação: guardar o peixe carregado. Vazia se as mãos não carregam um peixe.
func get_prompt(hands: Hands) -> String:
	var fish: FishData = hands.state.carried_item as FishData
	if not hands.state.is_carrying() or fish == null:
		return ""
	return "Store %s" % fish.display_name


## Guarda o peixe carregado, com a quantidade, e emite fish_stored.
func interact(hands: Hands) -> void:
	var fish: FishData = hands.state.carried_item as FishData
	if not hands.state.is_carrying() or fish == null:
		return
	var amount: int = hands.state.carried_amount
	hands.state.stop_carrying()
	fish_stored.emit(fish, amount)
