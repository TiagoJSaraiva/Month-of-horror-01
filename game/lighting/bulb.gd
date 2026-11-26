class_name Bulb
extends Interactable
## Lâmpada do barco. Acende quando está boa e recebe energia do gerador. Queima por sorteio
## (e, no M6, pelo ataque do voador) e é trocada segurando E com uma lâmpada de reposição.

signal changed

@export var spare_bulb: ItemData
@export var replace_seconds: float = 2.0
@export var light_range: float = 6.0
@export var light_energy: float = 1.2
@export var glow_color: Color = Color(1.0, 0.86, 0.62)
@export var glass_color: Color = Color(0.45, 0.45, 0.42)
@export var burnt_glass_color: Color = Color(0.06, 0.06, 0.06)

## Multiplica o tempo de troca (bônus da run: 0,5 é a metade).
var hold_multiplier: float = 1.0

var _broken: bool = false
var _powered: bool = false
# Material próprio de cada lâmpada; a emissão fica sempre ligada para trocar só a cor, sem
# recompilar o shader a cada mudança.
var _glass_material := StandardMaterial3D.new()

@onready var _light: OmniLight3D = $Light
@onready var _glass: MeshInstance3D = $Glass


## Aplica o alcance, a energia e a cor do inspetor na luz e prepara o material do vidro.
func _ready() -> void:
	if spare_bulb == null:
		push_warning("Bulb sem spare_bulb: a lâmpada não pode ser trocada.")
	_light.omni_range = light_range
	_light.light_energy = light_energy
	_light.light_color = glow_color
	_glass_material.emission_enabled = true
	_glass.material_override = _glass_material
	_refresh()


## A lâmpada está queimada.
func is_broken() -> bool:
	return _broken


## A lâmpada está acesa: tem energia e não está queimada.
func is_lit() -> bool:
	return _powered and not _broken


## Liga ou corta a energia que vem do gerador.
func set_powered(powered: bool) -> void:
	_powered = powered
	_refresh()


## Queima a lâmpada e avisa pelo sinal changed. Ignorado se já está queimada.
func burn_out() -> void:
	if _broken:
		return
	_broken = true
	_refresh()
	changed.emit()


## Dica de interação: trocar a lâmpada. Vazia se ela não está queimada ou as mãos não têm a
## reposição.
func get_prompt(hands: Hands) -> String:
	if not _can_replace(hands):
		return ""
	return "Replace bulb"


## Tempo, em segundos, que o jogador segura E para trocar a lâmpada.
func get_hold_seconds(_hands: Hands) -> float:
	return replace_seconds * hold_multiplier


## Gasta a lâmpada de reposição das mãos e conserta a lâmpada.
func interact(hands: Hands) -> void:
	if not _can_replace(hands):
		return
	hands.state.stop_carrying()
	_broken = false
	_refresh()
	changed.emit()


## A lâmpada está queimada e as mãos carregam a lâmpada de reposição.
func _can_replace(hands: Hands) -> bool:
	return _broken and hands.state.is_carrying_item(spare_bulb)


## Atualiza a luz e a cor do vidro conforme a lâmpada esteja queimada ou acesa.
func _refresh() -> void:
	_light.visible = is_lit()
	_glass_material.albedo_color = burnt_glass_color if _broken else glass_color
	_glass_material.emission = glow_color if is_lit() else Color.BLACK
