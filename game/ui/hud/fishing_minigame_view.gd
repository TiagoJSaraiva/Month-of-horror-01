class_name FishingMinigameView
extends Control
## Desenha o minijogo de pesca: trilho com a barra e o peixe e, ao lado, a captura.
## Só lê o modelo; as regras ficam em FishingMinigame.

const TRACK_COLOR := Color(0.08, 0.12, 0.16, 0.85)
const BAR_COLOR := Color(0.3, 0.85, 0.4, 0.7)
const FISH_COLOR := Color(0.95, 0.75, 0.2, 1.0)
const PROGRESS_BACK_COLOR := Color(0.12, 0.12, 0.12, 0.85)
const PROGRESS_COLOR := Color(0.95, 0.85, 0.3, 1.0)
## Medidas em pixels.
const FISH_HEIGHT := 14.0
const PROGRESS_WIDTH := 12.0
const GAP := 8.0

var _minigame: FishingMinigame


func _process(_delta: float) -> void:
	if _minigame != null:
		queue_redraw()


func show_minigame(minigame: FishingMinigame) -> void:
	_minigame = minigame
	show()


func hide_minigame() -> void:
	_minigame = null
	hide()


func _draw() -> void:
	if _minigame == null:
		return
	var track_width: float = size.x - PROGRESS_WIDTH - GAP
	draw_rect(Rect2(0.0, 0.0, track_width, size.y), TRACK_COLOR)
	# Posições do modelo crescem para cima; na tela, y cresce para baixo.
	var bar_height: float = FishingMinigame.BAR_SIZE * size.y
	var bar_top: float = (1.0 - _minigame.bar_position) * size.y - bar_height
	draw_rect(Rect2(0.0, bar_top, track_width, bar_height), BAR_COLOR)
	var fish_center: float = (1.0 - _minigame.fish_position) * size.y
	draw_rect(
		Rect2(track_width * 0.2, fish_center - FISH_HEIGHT / 2.0, track_width * 0.6, FISH_HEIGHT),
		FISH_COLOR
	)
	var progress_left: float = track_width + GAP
	draw_rect(Rect2(progress_left, 0.0, PROGRESS_WIDTH, size.y), PROGRESS_BACK_COLOR)
	var filled: float = _minigame.progress * size.y
	draw_rect(Rect2(progress_left, size.y - filled, PROGRESS_WIDTH, filled), PROGRESS_COLOR)
