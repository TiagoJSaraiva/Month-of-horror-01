class_name CardRules
extends RefCounted
## Regras puras das cartas: o sorteio da raridade, a montagem da seleção e a soma dos bônus.


## Raridade de uma carta da seleção, sorteada à parte das outras. [param roll] vai de 0 a 1;
## o que passa de comum e rara é lendária.
static func roll_rarity(roll: float, common_chance: float, rare_chance: float) -> CardData.Rarity:
	if roll < common_chance:
		return CardData.Rarity.COMMON
	if roll < common_chance + rare_chance:
		return CardData.Rarity.RARE
	return CardData.Rarity.LEGENDARY


## Raridades a tentar quando a sorteada não tem cartas: primeiro as de baixo, depois as de cima.
static func fallback_order(rarity: CardData.Rarity) -> Array[CardData.Rarity]:
	match rarity:
		CardData.Rarity.LEGENDARY:
			return [CardData.Rarity.LEGENDARY, CardData.Rarity.RARE, CardData.Rarity.COMMON]
		CardData.Rarity.RARE:
			return [CardData.Rarity.RARE, CardData.Rarity.COMMON, CardData.Rarity.LEGENDARY]
	return [CardData.Rarity.COMMON, CardData.Rarity.RARE, CardData.Rarity.LEGENDARY]


## Monta uma seleção de até [param size] cartas do pool, sem repetir carta. Com menos cartas no
## pool, a seleção fica menor; com o pool vazio, fica vazia.
static func draw_selection(
	pool: Array[CardData],
	size: int,
	common_chance: float,
	rare_chance: float,
	rng: RandomNumberGenerator
) -> Array[CardData]:
	var selection: Array[CardData] = []
	var available: Array[CardData] = pool.duplicate()
	for slot: int in size:
		if available.is_empty():
			break
		var rarity: CardData.Rarity = roll_rarity(rng.randf(), common_chance, rare_chance)
		for candidate_rarity: CardData.Rarity in fallback_order(rarity):
			var options: Array[CardData] = _of_rarity(available, candidate_rarity)
			if not options.is_empty():
				var card: CardData = options[rng.randi_range(0, options.size() - 1)]
				selection.append(card)
				available.erase(card)
				break
	return selection


## Soma dos percentuais das cartas para um atributo.
static func total_percent(cards: Array[CardData], stat: StatModifier.Stat) -> float:
	var total: float = 0.0
	for card: CardData in cards:
		for modifier: StatModifier in card.modifiers:
			if modifier.stat == stat:
				total += modifier.percent
	return total


static func _of_rarity(cards: Array[CardData], rarity: CardData.Rarity) -> Array[CardData]:
	var matching: Array[CardData] = []
	for card: CardData in cards:
		if card.rarity == rarity:
			matching.append(card)
	return matching
