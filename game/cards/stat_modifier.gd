class_name StatModifier
extends Resource
## Um bônus percentual sobre um atributo do jogador ou do barco. Bônus do mesmo atributo
## somam: +20% e +10% dão +30%. Tempos usam percentuais negativos (-50% é a metade do tempo).

enum Stat {
	MAX_HEALTH,
	FISHING_POWER,
	WEAPON_DAMAGE,
	BATTERY_CAPACITY,
	AMMO_CAPACITY,
	MOVE_SPEED,
	DOUBLE_FISH_CHANCE,
	MAINTENANCE_TIME,
	RELOAD_TIME,
	FIRE_RATE,
}

@export var stat: Stat = Stat.MAX_HEALTH
@export var percent: float = 0.0
