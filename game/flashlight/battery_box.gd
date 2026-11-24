class_name BatteryBox
extends Interactable
## Caixa de pilhas na mesa da cabine, com estoque infinito. Segurando E com as mãos livres,
## o jogador troca as pilhas da lanterna e a bateria volta cheia. É a única forma de recarregar.

@export var swap_seconds: float = 1.0


func get_prompt(hands: Hands) -> String:
	if not _can_swap(hands):
		return ""
	return "Replace batteries"


func get_hold_seconds(_hands: Hands) -> float:
	return swap_seconds


func interact(hands: Hands) -> void:
	if _can_swap(hands):
		hands.flashlight.recharge()


func _can_swap(hands: Hands) -> bool:
	return (
		hands.flashlight != null
		and not hands.flashlight.battery.is_full()
		and hands.state.can_take_item()
	)
