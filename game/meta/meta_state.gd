class_name MetaState
extends RefCounted
## O que sobrevive entre as runs: pontos e níveis dos upgrades. Salva e carrega um ConfigFile;
## arquivo ausente, de outra versão ou inválido começa do zero, sem travar o jogo.

signal changed

const SAVE_VERSION := 1
const META_SECTION := "meta"
const LEVELS_SECTION := "levels"

var points: int = 0

var _levels: Dictionary[StringName, int] = {}


## Lê o save no caminho dado. Arquivo ausente, de outra versão ou inválido devolve um estado zerado.
static func load_from(path: String) -> MetaState:
	var meta := MetaState.new()
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return meta
	if int(config.get_value(META_SECTION, "version", 0)) != SAVE_VERSION:
		return meta
	meta.points = maxi(int(config.get_value(META_SECTION, "points", 0)), 0)
	if config.has_section(LEVELS_SECTION):
		for key: String in config.get_section_keys(LEVELS_SECTION):
			meta._levels[StringName(key)] = maxi(int(config.get_value(LEVELS_SECTION, key, 0)), 0)
	return meta


## Grava pontos e níveis no caminho e devolve o código de erro do ConfigFile.
func save(path: String) -> Error:
	var config := ConfigFile.new()
	config.set_value(META_SECTION, "version", SAVE_VERSION)
	config.set_value(META_SECTION, "points", points)
	for id: StringName in _levels:
		config.set_value(LEVELS_SECTION, String(id), _levels[id])
	return config.save(path)


## Soma pontos ao saldo. Valor zero ou negativo é ignorado.
func add_points(amount: int) -> void:
	if amount <= 0:
		return
	points += amount
	changed.emit()


## Nível atual do upgrade, limitado ao máximo dele.
func level(upgrade: UpgradeData) -> int:
	return mini(_levels.get(upgrade.id, 0), upgrade.max_level)


## Custo do próximo nível do upgrade.
func cost(upgrade: UpgradeData) -> int:
	return MetaRules.upgrade_cost(upgrade.base_cost, level(upgrade))


## Dá para comprar o próximo nível do upgrade com os pontos atuais.
func can_buy(upgrade: UpgradeData) -> bool:
	return MetaRules.can_buy(points, level(upgrade), upgrade.max_level, cost(upgrade))


## Compra o próximo nível. Devolve false sem pontos suficientes ou no nível máximo.
func buy(upgrade: UpgradeData) -> bool:
	if not can_buy(upgrade):
		return false
	points -= cost(upgrade)
	_levels[upgrade.id] = level(upgrade) + 1
	changed.emit()
	return true


## Percentual somado por atributo, a partir dos níveis destes upgrades.
func percents(upgrades: Array[UpgradeData]) -> Dictionary[StatModifier.Stat, float]:
	var totals: Dictionary[StatModifier.Stat, float] = {}
	for upgrade: UpgradeData in upgrades:
		totals[upgrade.stat] = (
			totals.get(upgrade.stat, 0.0) + level(upgrade) * upgrade.percent_per_level
		)
	return totals
