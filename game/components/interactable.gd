class_name Interactable
extends Area3D
## Algo com que o jogador interage mirando e apertando E. Cada objeto estende esta classe e
## decide, a partir das mãos do jogador, se há ação disponível e o que ela faz.
## Fica na camada interactable, onde a mira de interação (Interactor) procura.


## Texto da ação disponível agora, ou vazio quando não há ação com estas mãos.
func get_prompt(_hands: Hands) -> String:
	return ""


## Segundos segurando a tecla até a ação acontecer. 0 é instantânea.
func get_hold_seconds(_hands: Hands) -> float:
	return 0.0


## Executa a ação. O Interactor só chama quando [method get_prompt] não está vazio.
func interact(_hands: Hands) -> void:
	pass


## Chamado quando a mira de interação deixa de apontar para este objeto.
func focus_exited() -> void:
	pass
