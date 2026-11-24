class_name DifficultyCurve
extends Resource
## Como a noite fica mais difícil ao longo da run. Quase tudo é multiplicador sobre os valores
## do inspetor (1 = sem mudança); a chance de tempestade é o valor direto, de 0 a 1.
## O tamanho do pedido cresce por conta própria (OrderRules).

## Multiplica os intervalos entre surgimentos de peixes-homens (menor = mais frequente).
@export var fishman_spawn_interval: ScalingValue
## Multiplica o intervalo entre voadores na tempestade.
@export var flyer_spawn_interval: ScalingValue
## Multiplica a vida dos inimigos.
@export var enemy_health: ScalingValue
## Multiplica o dano dos inimigos.
@export var enemy_damage: ScalingValue
## Multiplica a frequência das falhas do gerador e das lâmpadas.
@export var maintenance_failures: ScalingValue
## Multiplica a duração da bateria da lanterna.
@export var flashlight_battery: ScalingValue
## Chance de tempestade numa noite permitida, de 0 a 1.
@export var storm_chance: ScalingValue
## Multiplica a duração da tempestade.
@export var storm_duration: ScalingValue
