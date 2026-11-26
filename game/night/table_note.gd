class_name TableNote
extends Interactable
## Bilhete dos clientes na mesa da cabine. O alfinete colorido mostra de longe como foi a
## noite anterior; o texto é lido no HUD, apertando E.

const PIN_COLORS: Dictionary[RunRules.Pin, Color] = {
	RunRules.Pin.BLUE: Color(0.2, 0.45, 1.0),
	RunRules.Pin.YELLOW: Color(1.0, 0.8, 0.1),
	RunRules.Pin.RED: Color(1.0, 0.15, 0.1),
}
const PIN_MARKS: Dictionary[RunRules.Pin, String] = {
	RunRules.Pin.BLUE: "",
	RunRules.Pin.YELLOW: "!",
	RunRules.Pin.RED: "!!",
}

@export var hud_events: HudEvents

var _text: String = ""
var _reading: bool = false

@onready var _pin: MeshInstance3D = $Pin
@onready var _mark: Label3D = $Mark


## Avisa se falta HudEvents e começa sem bilhete na mesa.
func _ready() -> void:
	if hud_events == null:
		push_warning("TableNote sem HudEvents: o bilhete não pode ser lido.")
	visible = false


## Põe o bilhete na mesa. Texto vazio deixa a mesa sem bilhete.
func show_note(text: String, pin: RunRules.Pin) -> void:
	_text = text
	visible = not text.is_empty()
	# Sem sombreamento, para o alfinete chamar atenção mesmo com pouca luz.
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = PIN_COLORS[pin]
	_pin.material_override = material
	_mark.text = PIN_MARKS[pin]
	_mark.modulate = PIN_COLORS[pin]


## Devolve a dica de interação (ler ou largar o bilhete); vazia se não há bilhete ou HudEvents.
func get_prompt(_hands: Hands) -> String:
	if _text.is_empty() or hud_events == null:
		return ""
	return "Put down note" if _reading else "Read note"


## Abre a leitura do bilhete no HUD ou, se já está aberta, a fecha.
func interact(_hands: Hands) -> void:
	if _reading:
		_close()
	else:
		_reading = true
		hud_events.note_opened.emit(_text)


## Fecha a leitura quando a mira sai do bilhete.
func focus_exited() -> void:
	if _reading:
		_close()


## Fecha a leitura do bilhete no HUD.
func _close() -> void:
	_reading = false
	hud_events.note_closed.emit()
