class_name PlayerStats
extends RefCounted
## Bônus da run sobre os atributos do jogador e do barco, somados por atributo: as cartas
## equipadas e os upgrades permanentes.

var _percents: Dictionary[StatModifier.Stat, float] = {}


## Cria um PlayerStats só com os bônus das cartas, sem upgrades permanentes.
static func from_cards(cards: Array[CardData]) -> PlayerStats:
	return from_sources(cards, {})


## Soma as cartas e os upgrades permanentes por atributo: +20% de carta e +10% de upgrade dão
## +30%.
static func from_sources(
	cards: Array[CardData], upgrade_percents: Dictionary[StatModifier.Stat, float]
) -> PlayerStats:
	var stats := PlayerStats.new()
	for stat: StatModifier.Stat in StatModifier.Stat.values():
		stats._percents[stat] = (
			CardRules.total_percent(cards, stat) + upgrade_percents.get(stat, 0.0)
		)
	return stats


## Bônus total do atributo, em percentual; zero se o atributo não tem bônus.
func percent(stat: StatModifier.Stat) -> float:
	return _percents.get(stat, 0.0)


## Valor base com o bônus: +20% sobre 100 dá 120, -50% sobre 4 s dá 2 s. Nunca fica negativo.
func apply(stat: StatModifier.Stat, base: float) -> float:
	return maxf(base * (1.0 + percent(stat) / 100.0), 0.0)


## Bônus lido como chance de 0 a 1 (50% dá 0,5).
func chance(stat: StatModifier.Stat) -> float:
	return clampf(percent(stat) / 100.0, 0.0, 1.0)
