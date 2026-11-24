class_name DroppedFish
extends Interactable
## Peixe largado no convés. Pode ser pego de novo com as mãos livres.

var fish: FishData
var amount: int = 1


func get_prompt(hands: Hands) -> String:
	if fish == null or not hands.state.can_take_item():
		return ""
	return "Pick up %s" % fish.display_name


func interact(hands: Hands) -> void:
	if hands.carry_fish(fish, amount):
		queue_free()
