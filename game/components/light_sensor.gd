class_name LightSensor
extends Area3D
## Área que percebe o facho da lanterna, como o rosto do peixe-homem. Fica na camada
## light_sensor, onde a lanterna procura.

signal lit


## Chamado pela lanterna a cada frame de física em que o facho alcança o sensor.
func expose_to_light() -> void:
	lit.emit()
