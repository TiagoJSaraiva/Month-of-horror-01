class_name Interactable
extends Area3D
## Algo com que o jogador interage mirando e apertando E. Cada objeto estende esta classe e
## decide, a partir das mãos do jogador, se há ação disponível e o que ela faz.
## Fica na camada interactable, onde a mira de interação (Interactor) procura.


## Texto da ação disponível agora, ou vazio quando não há ação com estas mãos.
func get_prompt(_hands: Hands) -> String:
	return ""


## Executa a ação. O Interactor só chama quando [method get_prompt] não está vazio.
func interact(_hands: Hands) -> void:
	pass
