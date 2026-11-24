class_name JournalText
extends RefCounted
## Monta o texto do diário: a noite atual e o andamento do pedido. Não mostra a hora,
## que fica só no relógio da cabine.


## Uma linha por espécie, em ordem alfabética, no formato "Nome entregues/pedidos".
static func compose(night_number: int, order: NightOrder) -> String:
	var lines: PackedStringArray = ["NIGHT %d" % night_number, "ORDER"]
	var species: Array[FishData] = order.species()
	species.sort_custom(_by_display_name)
	for fish: FishData in species:
		lines.append(
			(
				"%s %d/%d"
				% [fish.display_name, order.delivered_count(fish), order.required_count(fish)]
			)
		)
	return "\n".join(lines)


static func _by_display_name(first: FishData, second: FishData) -> bool:
	return first.display_name < second.display_name
