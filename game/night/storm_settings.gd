class_name StormSettings
extends Resource
## Ajustes do sorteio e do ritmo da tempestade. A dificuldade por noite (M7) vai trocar estes
## valores.

## Primeira noite da run em que pode haver tempestade.
@export var first_night: int = 2
## Chance de 0 a 1 de haver tempestade numa noite permitida.
@export var chance: float = 0.5
## Janela, em frações da noite, em que a tempestade pode começar.
@export var start_window_min: float = 0.15
@export var start_window_max: float = 0.7
@export var min_duration_seconds: float = 60.0
@export var max_duration_seconds: float = 90.0
## Tempo para a tempestade crescer até o pico e para sumir no fim.
@export var ramp_seconds: float = 8.0
## Fração da noite até a qual a tempestade precisa ter acabado.
@export var latest_end_fraction: float = 0.95
