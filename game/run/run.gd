class_name Run
extends Node
## Uma run: oferece cartas antes da primeira noite e entre as noites, cria cada noite, avalia o
## pedido no amanhecer e encerra a run na terceira falha ou com a morte do jogador. As regras
## ficam em RunState, RunRules e CardRules (decisão 0013).

signal run_over
signal new_run_requested
signal main_menu_requested
## O jogador saiu pelo menu de pausa: os pontos já foram pagos e a Main volta ao menu.
signal quit_to_menu_requested
## Um menu (seleção de cartas ou pausa) abriu ou fechou: a Main solta ou recaptura o mouse.
signal menu_opened
signal menu_closed

const DEAL_BROKEN_TITLE: String = "THE DEAL IS OFF"
const DEATH_TITLE: String = "YOU DIED"

@export var night_scene: PackedScene
@export var note_lines: NoteLines
@export var card_pool: CardPool
## Tempo parado na tela do amanhecer antes de seguir, em segundos.
@export var dawn_hold_seconds: float = 3.0

var state: RunState = RunState.new()

var _night: Night
var _selection: Array[CardData] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
## Os pontos da run são pagos uma vez só, no fim (acordo quebrado, morte ou saída).
var _points_paid: bool = false

@onready var _hud: Hud = $Hud
@onready var _night_viewport: SubViewport = $LowResView/SubViewport
@onready var _transition: TransitionOverlay = $TransitionOverlay
@onready var _card_screen: CardSelectionScreen = $CardSelectionScreen
@onready var _pause_menu: PauseMenu = $PauseMenu
@onready var _run_over_screen: RunOverScreen = $RunOverScreen


## Sorteia a semente, monta o pool de cartas, liga os sinais das telas e abre a primeira seleção de
## cartas.
func _ready() -> void:
	_rng.randomize()
	state.start_card_pool(card_pool.cards)
	_run_over_screen.new_run_requested.connect(new_run_requested.emit)
	_run_over_screen.main_menu_requested.connect(main_menu_requested.emit)
	_card_screen.card_chosen.connect(_on_card_screen_card_chosen)
	_card_screen.card_replaced.connect(_on_card_screen_card_replaced)
	_card_screen.refused.connect(_close_cards)
	_card_screen.reroll_requested.connect(_on_card_screen_reroll_requested)
	_pause_menu.toggle_requested.connect(_on_pause_menu_toggle_requested)
	_pause_menu.resume_requested.connect(_resume)
	_pause_menu.quit_requested.connect(_on_pause_menu_quit_requested)
	_hud.hide()
	_offer_cards()


## Noite em andamento, ou null entre as noites.
func current_night() -> Night:
	return _night


## A pausa só abre com uma noite em andamento: na seleção de cartas, no amanhecer e no fim de run,
## pausar prenderia as transições que a Run aguarda.
func can_pause() -> bool:
	return _night != null and not _night.is_ended() and not _card_screen.visible


## Pausa o jogo e abre o menu de pausa.
func _pause() -> void:
	get_tree().paused = true
	_pause_menu.open()
	menu_opened.emit()


## Retoma o jogo e fecha o menu de pausa.
func _resume() -> void:
	get_tree().paused = false
	_pause_menu.close()
	menu_closed.emit()


## Esc: retoma se está pausado; senão pausa, se a pausa é permitida agora.
func _on_pause_menu_toggle_requested() -> void:
	if get_tree().paused:
		_resume()
	elif can_pause():
		_pause()


## Sair conta como derrota: os peixes já entregues valem, e os pontos são pagos.
func _on_pause_menu_quit_requested() -> void:
	get_tree().paused = false
	_pause_menu.close()
	state.add_delivered_fish(_night.order.delivered_total())
	_pay_points()
	quit_to_menu_requested.emit()


## Mostra a seleção de cartas; com o pool vazio, pula direto para a noite.
func _offer_cards() -> void:
	_selection = CardRules.draw_selection(
		state.card_pool,
		card_pool.selection_size,
		card_pool.common_chance,
		card_pool.rare_chance,
		_rng
	)
	if _selection.is_empty():
		_start_night()
		return
	_card_screen.show_selection(_selection, state.equipped, state.rerolls_left, state.slots_full())
	menu_opened.emit()


## Fecha a seleção de cartas e começa a noite.
func _close_cards() -> void:
	_card_screen.close()
	menu_closed.emit()
	_start_night()


## Cria a noite com o bilhete, os bônus e o número da noite, a coloca na árvore e mostra a transição
## de entrada.
func _start_night() -> void:
	var kind: RunRules.NoteKind = RunRules.note_kind(state.last_outcome, state.failures)
	_night = night_scene.instantiate() as Night
	_night.night_number = state.night_number
	_night.table_note_text = note_lines.text_for(kind)
	_night.table_note_pin = RunRules.pin_for(kind)
	_night.player_stats = state.player_stats(MetaProgress.upgrade_percents())
	_night.night_finished.connect(_on_night_night_finished)
	_night.player_died.connect(_on_night_player_died)
	_night_viewport.add_child(_night)
	_hud.reset()
	_transition.reveal("NIGHT %d" % state.night_number)


## Equipa a carta escolhida e começa a noite.
func _on_card_screen_card_chosen(card: CardData) -> void:
	state.choose(card)
	_close_cards()


## Troca a carta equipada pela escolhida e começa a noite.
func _on_card_screen_card_replaced(old_card: CardData, new_card: CardData) -> void:
	state.replace(old_card, new_card)
	_close_cards()


## Gasta um reroll, se houver, e sorteia uma seleção nova.
func _on_card_screen_reroll_requested() -> void:
	if not state.use_reroll():
		return
	_card_screen.close()
	_offer_cards()


## No amanhecer, registra os peixes entregues e avalia o pedido: encerra a run na terceira falha;
## senão, cobre a tela e oferece as cartas da próxima noite.
func _on_night_night_finished(order: NightOrder) -> void:
	_hud.hide()
	await _transition.play_dawn()
	await get_tree().create_timer(dawn_hold_seconds).timeout
	state.add_delivered_fish(order.delivered_total())
	state.finish_night(order.missing_total())
	if state.is_over():
		_show_run_over(DEAL_BROKEN_TITLE, note_lines.run_over)
		return
	await _transition.cover()
	# A noite antiga sai no fim do frame; a seleção e a próxima noite entram sob a tela preta.
	_night.queue_free()
	_night = null
	_offer_cards()


## Com a morte do jogador, registra os peixes entregues, encerra a run e mostra a tela de fim.
func _on_night_player_died() -> void:
	_hud.hide()
	state.add_delivered_fish(_night.order.delivered_total())
	state.die()
	await _transition.cover()
	_show_run_over(DEATH_TITLE, note_lines.death)


## Mostra a tela de fim de run com as noites vividas e os pontos pagos, e avisa pelo sinal run_over.
func _show_run_over(title: String, message: String) -> void:
	var nights: int = RunRules.nights_survived(state.night_number, state.died)
	_run_over_screen.show_summary(title, message, nights, _pay_points())
	run_over.emit()


## Paga os pontos da run no MetaProgress, uma vez só. Devolve quanto foi pago.
func _pay_points() -> int:
	if _points_paid:
		return 0
	_points_paid = true
	var points: int = state.points()
	MetaProgress.add_points(points)
	return points
