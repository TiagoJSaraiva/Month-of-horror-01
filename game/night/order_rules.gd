class_name OrderRules
extends RefCounted
## Regras puras do pedido de peixes de cada noite.

## Valores provisórios: a curva de dificuldade (M7) deve assumir o crescimento por noite.
const BASE_FISH_COUNT: int = 3
const FISH_PER_NIGHT: int = 1


## Quantos peixes o pedido exige: 3 na primeira noite e mais 1 a cada noite seguinte.
static func fish_count(night_number: int) -> int:
	return BASE_FISH_COUNT + maxi(night_number - 1, 0) * FISH_PER_NIGHT


## Sorteia a espécie de cada peixe do pedido entre as espécies disponíveis.
## Devolve quantos peixes de cada espécie foram pedidos; espécies não sorteadas ficam de fora.
static func generate(
	night_number: int, species: Array[FishData], rng: RandomNumberGenerator
) -> Dictionary[FishData, int]:
	var order: Dictionary[FishData, int] = {}
	if species.is_empty():
		return order
	for _fish in fish_count(night_number):
		var picked: FishData = species[rng.randi_range(0, species.size() - 1)]
		var current: int = order.get(picked, 0)
		order[picked] = current + 1
	return order
