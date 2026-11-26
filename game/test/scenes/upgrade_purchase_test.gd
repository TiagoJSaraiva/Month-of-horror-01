extends GdUnitTestSuite
## Comportamento principal da tela de upgrades: com pontos suficientes, comprar sobe o nível e
## desconta os pontos (num save de teste, sem mexer no progresso do jogador).

const SCREEN_SCENE: String = "res://ui/upgrades/upgrades_screen.tscn"
const TEST_SAVE_PATH: String = "user://test_upgrade_purchase_meta.cfg"


func before_test() -> void:
	MetaProgress.use_save_path(TEST_SAVE_PATH)


func after_test() -> void:
	MetaProgress.use_save_path(MetaProgress.DEFAULT_SAVE_PATH)
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(TEST_SAVE_PATH)


func test_buying_raises_the_level_and_spends_points() -> void:
	MetaProgress.add_points(50)
	var runner: GdUnitSceneRunner = scene_runner(SCREEN_SCENE)
	var screen: UpgradesScreen = runner.scene() as UpgradesScreen
	screen.open()
	var health: UpgradeData = MetaProgress.UPGRADES[0]

	screen.buy_buttons()[0].pressed.emit()

	assert_int(MetaProgress.state.level(health)).is_equal(1)
	assert_int(MetaProgress.state.points).is_equal(30)
	# 30 pontos não pagam o nível 2 (40): o botão fica desligado.
	assert_bool(screen.buy_buttons()[0].disabled).is_true()
	# A compra foi salva no arquivo de teste.
	assert_int(MetaState.load_from(TEST_SAVE_PATH).level(health)).is_equal(1)
