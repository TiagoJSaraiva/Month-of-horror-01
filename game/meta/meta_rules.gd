class_name MetaRules
extends RefCounted
## Regras puras da meta-progressão: pontos ganhos numa run e custo dos upgrades.

const POINTS_PER_NIGHT := 10
const POINTS_PER_FISH := 1


## Pontos pagos no fim de uma run: por noite cumprida e por peixe entregue.
static func run_points(nights_completed: int, fish_delivered: int) -> int:
	return maxi(nights_completed, 0) * POINTS_PER_NIGHT + maxi(fish_delivered, 0) * POINTS_PER_FISH


## Custo do próximo nível: o custo base vezes o nível que será comprado (20, 40, 60...).
static func upgrade_cost(base_cost: int, current_level: int) -> int:
	return base_cost * (current_level + 1)


## Dá para comprar o próximo nível: o upgrade não está no máximo e os pontos cobrem o custo.
static func can_buy(points: int, current_level: int, max_level: int, cost: int) -> bool:
	return current_level < max_level and points >= cost
