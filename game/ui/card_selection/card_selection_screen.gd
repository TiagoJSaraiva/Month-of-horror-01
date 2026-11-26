class_name CardSelectionScreen
extends CanvasLayer
## Tela de seleção de cartas: as cartas sorteadas, as equipadas, o reroll e, com os slots
## cheios, a troca por uma equipada ou a recusa. Só mostra e avisa por sinais; as regras ficam
## no RunState. Feita com componentes nativos do Godot: função antes de design.

signal card_chosen(card: CardData)
signal card_replaced(old_card: CardData, new_card: CardData)
signal refused
signal reroll_requested

const RARITY_NAMES: Dictionary[CardData.Rarity, String] = {
	CardData.Rarity.COMMON: "Common",
	CardData.Rarity.RARE: "Rare",
	CardData.Rarity.LEGENDARY: "Legendary",
}
const CHOOSE_TITLE := "Choose a card"
const FULL_TITLE := "Your slots are full: swap a card or refuse"
const REPLACE_TITLE := "Replace which card with %s?"
const CARD_BUTTON_SIZE := Vector2(260, 170)

var _slots_full: bool = false
var _equipped: Array[CardData] = []

@onready var _title: Label = %Title
@onready var _cards: HBoxContainer = %Cards
@onready var _equipped_label: Label = %Equipped
@onready var _replace_row: HBoxContainer = %ReplaceRow
@onready var _reroll_button: Button = %RerollButton
@onready var _refuse_button: Button = %RefuseButton


## Começa escondida e liga os botões de reroll e de recusa aos sinais.
func _ready() -> void:
	hide()
	_reroll_button.pressed.connect(reroll_requested.emit)
	_refuse_button.pressed.connect(refused.emit)


## Mostra as cartas sorteadas, as equipadas e os rerolls restantes. Com os slots cheios, o título
## pede trocar ou recusar.
func show_selection(
	selection: Array[CardData], equipped: Array[CardData], rerolls_left: int, slots_full: bool
) -> void:
	_slots_full = slots_full
	_equipped = equipped
	_title.text = FULL_TITLE if slots_full else CHOOSE_TITLE
	_clear(_cards)
	for card: CardData in selection:
		var button := Button.new()
		button.custom_minimum_size = CARD_BUTTON_SIZE
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.text = (
			"%s\n(%s)\n\n%s" % [card.display_name, RARITY_NAMES[card.rarity], card.description]
		)
		button.pressed.connect(_on_card_pressed.bind(card))
		_cards.add_child(button)
	_equipped_label.text = "Equipped: %s" % _names(equipped) if not equipped.is_empty() else ""
	_replace_row.hide()
	_reroll_button.text = "Reroll (%d)" % rerolls_left
	_reroll_button.disabled = rerolls_left <= 0
	_refuse_button.visible = slots_full
	show()
	if _cards.get_child_count() > 0:
		(_cards.get_child(0) as Button).grab_focus()


## Esconde a tela, inclusive a linha de troca.
func close() -> void:
	_replace_row.hide()
	hide()


## Botões das cartas da seleção atual, na ordem. Públicos para os testes.
func card_buttons() -> Array[Button]:
	var buttons: Array[Button] = []
	for child: Node in _cards.get_children():
		buttons.append(child as Button)
	return buttons


## Com slot livre, escolhe a carta. Com os slots cheios, mostra as equipadas para o jogador escolher
## qual trocar.
func _on_card_pressed(card: CardData) -> void:
	if not _slots_full:
		card_chosen.emit(card)
		return
	# Com os slots cheios, a carta escolhida precisa de um slot para ocupar.
	_title.text = REPLACE_TITLE % card.display_name
	_clear(_replace_row)
	for old_card: CardData in _equipped:
		var slot_button := Button.new()
		slot_button.text = old_card.display_name
		slot_button.pressed.connect(card_replaced.emit.bind(old_card, card))
		_replace_row.add_child(slot_button)
	_replace_row.show()


## Devolve os nomes das cartas, separados por vírgula.
func _names(cards: Array[CardData]) -> String:
	var names: PackedStringArray = []
	for card: CardData in cards:
		names.append(card.display_name)
	return ", ".join(names)


## Remove e libera todos os filhos do contêiner.
func _clear(container: Node) -> void:
	for child: Node in container.get_children():
		container.remove_child(child)
		child.queue_free()
