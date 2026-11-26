extends Node
## Meta-progressão entre as runs (decisão 0015): pontos e níveis dos upgrades, salvos num
## arquivo do usuário a cada mudança. É o único autoload do projeto; o estado de uma run fica na
## Run (decisão 0013).

signal changed

const DEFAULT_SAVE_PATH := "user://meta_progress.cfg"
const UPGRADES: Array[UpgradeData] = [
	preload("res://meta/upgrades/health.tres"),
	preload("res://meta/upgrades/damage.tres"),
	preload("res://meta/upgrades/rod_power.tres"),
]

var state: MetaState

var _save_path: String = DEFAULT_SAVE_PATH


## Carrega o save padrão ao entrar na árvore.
func _ready() -> void:
	use_save_path(DEFAULT_SAVE_PATH)


## Troca o arquivo de save e carrega dele. Os testes usam um caminho próprio, para não mexer no
## save do jogador.
func use_save_path(path: String) -> void:
	if state != null and state.changed.is_connected(_on_state_changed):
		state.changed.disconnect(_on_state_changed)
	_save_path = path
	state = MetaState.load_from(path)
	state.changed.connect(_on_state_changed)
	changed.emit()


## Soma pontos ao saldo do jogador (valor zero ou negativo é ignorado) e salva.
func add_points(amount: int) -> void:
	state.add_points(amount)


## Compra o próximo nível do upgrade e salva. Devolve false se os pontos não cobrirem o custo ou se
## o upgrade já estiver no máximo.
func buy(upgrade: UpgradeData) -> bool:
	return state.buy(upgrade)


## Percentual dos upgrades comprados, por atributo.
func upgrade_percents() -> Dictionary[StatModifier.Stat, float]:
	return state.percents(UPGRADES)


## Salva a cada mudança do estado (se a gravação falhar, só avisa no console) e emite changed.
func _on_state_changed() -> void:
	var error: Error = state.save(_save_path)
	if error != OK:
		push_warning("MetaProgress não conseguiu salvar em %s (erro %d)." % [_save_path, error])
	changed.emit()
