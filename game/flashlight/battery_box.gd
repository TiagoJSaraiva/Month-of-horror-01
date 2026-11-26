class_name BatteryBox
extends Interactable
## Caixa de pilhas na mesa da cabine, com estoque infinito. Segurando E com as mãos livres,
## o jogador troca as pilhas da lanterna e a bateria volta cheia. É a única forma de recarregar.

@export var swap_seconds: float = 1.0


## Dica de interação: trocar as pilhas. Vazia se não há lanterna, se ela já está cheia ou se as mãos
## não podem pegar um item.
func get_prompt(hands: Hands) -> String:
	if not _can_swap(hands):
		return ""
	return "Replace batteries"


## Tempo, em segundos, que o jogador segura E para trocar as pilhas.
func get_hold_seconds(_hands: Hands) -> float:
	return swap_seconds


## Recarrega por completo a bateria da lanterna, se houver lanterna com carga faltando e as mãos
## puderem pegar um item. Senão, não faz nada.
func interact(hands: Hands) -> void:
	if _can_swap(hands):
		hands.flashlight.recharge()


## Há lanterna com a bateria não cheia e as mãos podem pegar um item (modo ferramenta, sem a vara
## com linha na água).
func _can_swap(hands: Hands) -> bool:
	return (
		hands.flashlight != null
		and not hands.flashlight.battery.is_full()
		and hands.state.can_take_item()
	)
