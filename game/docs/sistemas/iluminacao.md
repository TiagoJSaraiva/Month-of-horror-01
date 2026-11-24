# Iluminação

## Propósito
Dar ao barco um nível de luz que depende de manutenção: o gerador gasta combustível e quebra, e as lâmpadas queimam. O nível de luz é o que os inimigos do escuro (M5) vão consultar.

## Componentes
- `lighting/boat_lighting.tscn` / `boat_lighting.gd`: `BoatLighting`, instanciado no `Boat` como `Lighting`. Filhos:
  - `Generator`, na popa;
  - `Bulbs`, com as 6 lâmpadas: teto da cabine, acima da porta da cabine e 4 nos postes das amuradas (meio do convés e popa);
  - `EmergencyLights`, duas `OmniLight3D` vermelhas e fracas (cabine e convés);
  - `MaintenanceFailures`.

  Liga a energia das lâmpadas ao gerador, mostra a emergência quando ele para e calcula `light_level`, avisando com `light_level_changed(level)`.
- `lighting/generator.tscn` / `generator.gd`: `Generator` (`Interactable`, com um `StaticBody3D` que bloqueia o jogador). Guarda um `GeneratorState` em `state` e gasta combustível no `_process`.
  - Na face voltada para a cabine ficam a luz de status (verde funcionando, vermelha quebrado, apagada sem combustível) e o medidor de combustível (barra amarela).
- `lighting/bulb.tscn` / `bulb.gd`: `Bulb` (`Interactable`). Acende quando está boa e recebe energia (`set_powered`); `burn_out()` a queima (pelo sorteio de falhas ou pelo mergulho de um voador). O vidro brilha acesa, fica cinza sem energia e preto queimada. Alcance e energia da luz ficam em `@export`.
- `lighting/maintenance_failures.gd`: `MaintenanceFailures`, o sorteio de quebra do gerador e de queima das lâmpadas. Recebe o gerador e as lâmpadas do `BoatLighting` por `watch()`.
- `lighting/lighting_rules.gd`: `LightingRules`, regras puras do nível de luz e da chance de falha.
- `lighting/generator_state.gd`: `GeneratorState` (`RefCounted`), combustível e quebra do gerador. Avisa com `running_changed(running)` quando passa a funcionar ou para.
- Suprimentos na cabine, dos dois lados da porta: `FuelCans` e `SpareBulbs`, instâncias de `SupplyCrate` (ver `docs/sistemas/maos.md`) com `items/data/fuel_can.tres` e `items/data/spare_bulb.tres`. O estoque é infinito.

## Regras
- Nível de luz = lâmpadas boas ÷ total, com o gerador funcionando. Sem o gerador, o nível é 0 e só a luz de emergência fica acesa; ela não conta para o nível.
- O gerador funciona com combustível e sem quebra. Só gasta combustível funcionando; quebrado ou vazio, para.
- O tanque cheio dura `fuel_capacity_seconds` (150 s) de funcionamento. Cada noite começa com o tanque cheio, o gerador inteiro e as lâmpadas boas.
- Manutenção, sempre segurando E (`get_hold_seconds`):
  - reabastecer: com o galão nas mãos e o tanque não cheio, 3 s. Enche o tanque, e o galão some das mãos;
  - consertar: gerador quebrado e mãos livres (vara parada), 4 s. Sem combustível, o gerador continua parado;
  - trocar lâmpada: lâmpada queimada e lâmpada de reposição nas mãos, 2 s.
- Falhas por sorteio, só com o gerador funcionando:
  - o gerador quebra em média a cada `generator_mean_seconds` (240 s);
  - cada lâmpada acesa queima em média a cada `bulb_mean_seconds` (720 s). Com 6 acesas, uma queima a cada ~2 min.
- A chance num passo de tempo é `1 - e^(-delta / média)`, para o sorteio não depender da taxa de quadros. Média zero ou negativa desliga a falha. Na tempestade, as médias são divididas por até `storm_failure_multiplier` (3) conforme a intensidade (`LightingRules.storm_mean`); a curva de dificuldade multiplica a frequência a cada noite (`BoatLighting.set_failure_frequency`; ver `docs/sistemas/dificuldade.md`).
- No amanhecer, a `Night` desliga o processamento da `Lighting`: o combustível para de gastar e as falhas param.

## Lanterna
- `flashlight/flashlight.tscn` / `flashlight.gd`: `Flashlight`, filha da `Camera3D` do jogador, à esquerda. Tem um `Model` e um `Beam` (`SpotLight3D` de 16 m e 22°, com sombra).
- `flashlight/light_stun.gd`: `LightStun` (`ShapeCast3D`), filho da `Flashlight`. A lanterna o liga e desliga junto com o facho. Ligado, lança uma esfera de 0,35 m até `stun_range` (8 m) na camada `light_sensor` e avisa cada `LightSensor` alcançado (`expose_to_light()`), se um raio até ele não bater numa parede (camada `world`).
- `flashlight/flashlight_battery.gd`: `FlashlightBattery` (`RefCounted`), carga em segundos de luz.
- `flashlight/battery_box.tscn` / `battery_box.gd`: `BatteryBox` (`Interactable`), caixa de pilhas na mesa da cabine, com estoque infinito.
- Regras:
  - F (`toggle_flashlight`) liga e desliga, com as mãos em qualquer modo;
  - a bateria cheia dá `battery_seconds` (90 s) de luz e só gasta acesa. Cada noite começa com ela cheia;
  - quando a carga acaba, a lanterna apaga e aparece "The flashlight died."; tentar ligar sem carga mostra "The batteries are dead.";
  - recarga só na caixa de pilhas: segurando E por 1 s, com as mãos livres e a bateria não cheia, a bateria volta cheia. Não há recarga gradual nem pilhas guardadas;
  - a lanterna não conta para o nível de luz do barco. Acesa, atordoa o peixe-homem com o rosto no facho (ver `docs/sistemas/inimigos.md`). A bateria fica menor a cada noite pela curva de dificuldade (ver `docs/sistemas/dificuldade.md`).
- A `BatteryBox` chega à lanterna por `Hands.flashlight` (`@export`), porque a interação recebe as mãos do jogador.
- O HUD mostra a carga na barra `Battery` (canal `battery_changed`), avisada só quando o percentual inteiro muda.

## Sinais
- `GeneratorState.running_changed` → `Generator` → `Generator.running_changed` → `BoatLighting`: energia das lâmpadas, emergência e nível de luz.
- `Bulb.changed` (queimou ou foi trocada) → `BoatLighting._refresh_light_level`.
- `BoatLighting.light_level_changed(level)` → `FishmanSpawner`: os peixes-homens sobem abaixo do limiar e fogem quando a luz volta (ver `docs/sistemas/inimigos.md`).

## Testes
- `test/unit/lighting_rules_test.gd`: nível cheio, parcial, sem energia e sem lâmpadas; chance de falha nula sem tempo ou sem média, crescente com o tempo, 1 - 1/e num intervalo médio e igual em passos divididos; média sem tempestade igual, dividida no pico e falha desligada continua desligada.
- `test/unit/generator_state_test.gd`: começa cheio, gasta funcionando, vazio para e avisa uma vez, reabastecer religa, quebrado não gasta, conserto religa, conserto sem combustível continua parado e capacidade zero nunca funciona.
- `test/unit/flashlight_battery_test.gd`: começa cheia, gasta, acaba uma vez só sem ficar negativa, pilhas novas enchem e capacidade zero fica sempre vazia.
- `test/scenes/lighting_maintenance_test.gd`: com o gerador vazio, o nível é 0 e a emergência acende. Segurando E no gerador com o galão nas mãos, o nível volta a 1, a emergência apaga e as mãos ficam livres.
- Conferidos com captura de tela: cabine com as caixas, convés aceso, convés só com a emergência, lâmpadas queimadas, gerador quebrado, galão nas mãos diante do gerador vazio, lanterna acesa no escuro com a barra da bateria e a caixa de pilhas.
