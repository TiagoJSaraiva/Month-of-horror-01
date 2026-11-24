class_name PlayerStats
extends RefCounted
## Bônus da run sobre os atributos do jogador e do barco, somados por atributo. Hoje vêm das
## cartas equipadas; os upgrades permanentes (M8) vão somar aqui também.

var _percents: Dictionary[StatModifier.Stat, float] = {}


static func from_cards(cards: Array[CardData]) -> PlayerStats:
	var stats := PlayerStats.new()
	for stat: StatModifier.Stat in StatModifier.Stat.values():
		stats._percents[stat] = CardRules.total_percent(cards, stat)
	return stats


func percent(stat: StatModifier.Stat) -> float:
	return _percents.get(stat, 0.0)


## Valor base com o bônus: +20% sobre 100 dá 120, -50% sobre 4 s dá 2 s. Nunca fica negativo.
func apply(stat: StatModifier.Stat, base: float) -> float:
	return maxf(base * (1.0 + percent(stat) / 100.0), 0.0)


## Bônus lido como chance de 0 a 1 (50% dá 0,5).
func chance(stat: StatModifier.Stat) -> float:
	return clampf(percent(stat) / 100.0, 0.0, 1.0)
