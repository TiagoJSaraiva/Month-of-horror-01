class_name UpgradesScreen
extends CanvasLayer
## Tela de upgrades permanentes: uma linha por upgrade (nível, bônus atual e compra) e os pontos
## guardados. As compras vão para o MetaProgress. Feita com componentes nativos do Godot.

signal back_requested

@onready var _points: Label = %Points
@onready var _rows: VBoxContainer = %Rows
@onready var _back_button: Button = %BackButton


## Começa escondida e liga o botão de voltar ao sinal.
func _ready() -> void:
	hide()
	_back_button.pressed.connect(back_requested.emit)


## Atualiza as linhas, mostra a tela e dá o foco ao botão de voltar.
func open() -> void:
	_refresh()
	show()
	_back_button.grab_focus()


## Botões de compra, na ordem dos upgrades. Públicos para os testes.
func buy_buttons() -> Array[Button]:
	var buttons: Array[Button] = []
	for row: Node in _rows.get_children():
		buttons.append(row.get_child(1) as Button)
	return buttons


## Reconstrói os pontos e uma linha por upgrade, com nível, bônus e botão de compra.
func _refresh() -> void:
	var meta: MetaState = MetaProgress.state
	_points.text = "Points: %d" % meta.points
	for row: Node in _rows.get_children():
		_rows.remove_child(row)
		row.queue_free()
	for upgrade: UpgradeData in MetaProgress.UPGRADES:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 16)
		var label := Label.new()
		label.custom_minimum_size = Vector2(320, 0)
		label.add_theme_font_size_override("font_size", 20)
		var level: int = meta.level(upgrade)
		label.text = (
			"%s   Level %d/%d   (+%d%%)"
			% [
				upgrade.display_name,
				level,
				upgrade.max_level,
				roundi(level * upgrade.percent_per_level)
			]
		)
		var button := Button.new()
		button.custom_minimum_size = Vector2(160, 40)
		if level >= upgrade.max_level:
			button.text = "Max"
			button.disabled = true
		else:
			button.text = "Buy (%d)" % meta.cost(upgrade)
			button.disabled = not meta.can_buy(upgrade)
		button.pressed.connect(_on_buy_pressed.bind(upgrade))
		row.add_child(label)
		row.add_child(button)
		_rows.add_child(row)


## Compra o upgrade e atualiza a tela.
func _on_buy_pressed(upgrade: UpgradeData) -> void:
	MetaProgress.buy(upgrade)
	_refresh()
