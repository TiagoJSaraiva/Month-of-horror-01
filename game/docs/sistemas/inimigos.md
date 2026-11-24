# Inimigos

## Propósito
Ameaçar o jogador: o peixe-homem quando o barco fica escuro e o voador durante a tempestade.

## Peixe-homem
### Componentes
- `enemies/fishman/fishman_brain.gd`: `FishmanBrain` (`RefCounted`), a máquina de estados pura: `CLIMBING`, `CHASING`, `WINDING_UP`, `RECOVERING`, `STUNNED`, `FLEEING` e `DEAD`. Emite `state_changed(state)` e `attack_landed`.
- `enemies/fishman/fishman.tscn` / `fishman.gd`: `Fishman` (`CharacterBody3D`, camada `enemy`, colide com `world`, `player` e `enemy`). Corpo greybox escuro com olhos amarelo-esverdeados sem sombreamento, que aparecem no escuro. Filhos:
  - `Health` (75, sem regeneração);
  - `Hurtbox` (camada `hurtbox`), onde o revólver acerta;
  - `LightSensor` (`components/light_sensor.gd`, camada `light_sensor`), uma esfera de 0,3 m no rosto que a lanterna procura. O sinal `lit` chama `Fishman.stun()`;
  - `NavigationAgent3D` (raio 0,3 m), que segue a malha do barco.

  O nó move, vira para o alvo, aplica o dano do golpe e cuida do visual: inclina para trás na preparação, fecha os olhos atordoado, cai ao morrer.
- `enemies/spawn_rules.gd`: `SpawnRules`, regras puras da escuridão e do intervalo entre surgimentos.
- `enemies/fishman_spawner.gd`: `FishmanSpawner`, dentro de `Actors` na `Night` (congela no amanhecer). Os filhos `ClimbPoints/*` são 6 `Marker3D` no convés aberto, 3 por amurada, com o eixo +Z apontando para o mar. A `Night` chama `start(lighting, player, player.health)`.

### Regras
- Surgimento: com o nível de luz abaixo de 0,5 (`light_threshold`), um peixe-homem sobe a bordo a cada intervalo:
  - de 20 s logo abaixo do limiar até 6 s no escuro total, variando em linha reta com a escuridão `(limiar - luz) / limiar`;
  - o tempo zera sempre que a luz volta ao limiar;
  - no máximo 3 a bordo (`max_alive`). O ponto é sorteado entre os que ficam a 2 m ou mais do jogador.
- Subida: 1,5 s, saindo da água, passando por cima da amurada e pousando no ponto, sem colisão até pisar no convés.
- Perseguição: a 2,6 m/s pela malha de navegação, recalculando o caminho a cada 0,2 s. Persegue o jogador pelo barco todo, inclusive dentro da cabine.
- Golpe: a 1,4 m do jogador, prepara por 0,6 s (inclinado para trás). Só acerta, com 20 de dano direto no `Health` do jogador, se o jogador ainda estiver a 1,4 m. Depois espera 1 s e volta a perseguir.
- Atordoamento: a lanterna acesa com o rosto no facho (`LightStun`, até 8 m, sem parede no caminho; ver `docs/sistemas/iluminacao.md`) chama `stun()`. Fica 1 s parado e de olhos apagados, e a preparação do golpe é interrompida. Depois fica 2 s imune. Não vale subindo, fugindo, morto ou já atordoado.
- Fuga: quando a luz volta ao limiar, todos a bordo fogem a 3,5 m/s até o ponto de subida mais próximo e saltam para o mar. Quem estava subindo volta pela mesma amurada. A fuga não volta atrás.
- Morte: 75 de vida (3 tiros do revólver). Cai para trás em 0,6 s e some; o corpo caído não bloqueia tiros nem é achado pela lanterna.

## Voador (tempestade)
### Componentes
- `enemies/flyer/flyer_brain.gd`: `FlyerBrain` (`RefCounted`), a máquina de estados pura: `ARRIVING`, `CIRCLING`, `WARNING`, `DIVING`, `RETURNING`, `LEAVING` e `DEAD`, mais o alvo (`Target`: `NONE`, `PLAYER`, `BULB`) e `pick_target()`.
- `enemies/flyer/flyer.tscn` / `flyer.gd`: `Flyer` (`CharacterBody3D` em voo livre, camada `enemy`, colide só com `world`). Corpo greybox com asas batendo e olhos vermelhos sem sombreamento. Tem `Health` (50) e `Hurtbox`; não tem `LightSensor`, então a lanterna não o afeta.
- `enemies/flyer_spawner.gd`: `FlyerSpawner`, dentro de `Actors` (congela no amanhecer). A `Night` chama `start(storm, lighting, player, player.health)`, e ele ouve `Storm.started` e `Storm.ended`. As lâmpadas vêm de `BoatLighting.bulbs()`.

### Regras
- Surgimento: só durante a tempestade. O primeiro chega 4 s depois do início e os seguintes a cada 12 s, no máximo 2 ao mesmo tempo. Cada um chega de um ponto sorteado a 25 m do barco e 10 m de altura, sobre o mar.
- Voo: circula o barco num círculo de 7 m de raio a 6 m de altura, a 5 m/s, por 3 a 6 s (sorteado).
- Alvo, no fim do círculo: o jogador ou uma lâmpada boa, desde que um raio do voador até eles não bata numa parede (camada `world`).
  - Com os dois à vista, é meio a meio (`player_chance`); sem nenhum, continua circulando.
  - A cabine protege o jogador e a lâmpada do teto.
- Aviso: 0,6 s parado no ar, encarando o alvo, com os olhos dobrando de tamanho.
- Mergulho a 9 m/s até onde o alvo estava no fim do aviso, então quem se mexe escapa:
  - no jogador: 15 de dano se a cabeça dele ainda estiver a 1,2 m do ponto;
  - na lâmpada: ela queima (`Bulb.burn_out()`).

  Um mergulho que não chega em 3 s (bateu numa parede) termina mesmo assim. Depois ele sobe de volta ao círculo e repete.
- Fim da tempestade: todos vão embora, subindo e se afastando do barco, e somem a 40 m.
- Morte: 50 de vida (2 tiros do revólver). Cai sem colisão e some em 1,5 s.

## Navegação (decisão 0014)
- `boat/boat_navigation.gd`: `BoatNavigation` (`NavigationRegion3D`), filho `Navigation` do `Boat`. Um frame depois do `_ready` monta a malha a partir dos corpos estáticos do grupo `boat_navigation` (o `Boat` e todos os filhos: casco, cabine, freezer, caixas e gerador) e emite `baked`.
- Malha: célula de 0,1 m, agente de 1,8 m de altura e 0,3 m de raio, degrau máximo de 0,3 m. O convés, o interior da cabine e a porta entre eles ficam ligados. Os topos das amuradas, o teto da cabine e o tampo da mesa viram ilhas soltas, sem caminho até elas.
- Enquanto o barco for CSG, o console mostra a cada noite um aviso de que a montagem leu as malhas renderizadas das formas CSG. É esperado (ver a decisão).

## Sinais
- `BoatLighting.light_level_changed(level)` → `FishmanSpawner._on_lighting_light_level_changed`: no limiar ou acima, manda todos fugirem.
- `FishmanBrain.state_changed` → `Fishman._on_brain_state_changed`; `FishmanBrain.attack_landed` → `Fishman._on_brain_attack_landed`.
- `Health.died` (do peixe-homem) → `FishmanBrain.kill`.
- `LightSensor.lit` → `Fishman.stun` → `FishmanBrain.stun`.
- `Fishman.removed` → `FishmanSpawner._on_fishman_removed`: libera a vaga.
- `Storm.started` e `Storm.ended` → `FlyerSpawner`: liga os surgimentos e, no fim, manda os voadores embora.
- `FlyerBrain.state_changed` → `Flyer._on_brain_state_changed`; `Health.died` (do voador) → `FlyerBrain.kill`.
- `Flyer.removed` → `FlyerSpawner._on_flyer_removed`: libera a vaga.

## Testes
- `test/unit/spawn_rules_test.gd`: nada no limiar ou acima, mínimo no escuro total, quase o máximo logo abaixo do limiar, intervalo menor quanto mais escuro, escuridão de 0 a 1.
- `test/unit/fishman_brain_test.gd`: sobe e persegue, prepara perto, acerta se o alvo continua perto, erra se ele se afastou, recupera e volta, atordoamento interrompe a preparação e dura o tempo certo, imunidade, sem atordoar subindo ou fugindo, foge com a luz, morto ignora tudo.
- `test/unit/flyer_brain_test.gd`: chega e circula, circula antes de avisar, sem alvo à vista continua circulando, mergulha depois do aviso, volta e circula de novo, escolha do alvo à vista e no sorteio, vai embora de qualquer estado, morto ignora tudo.
- `test/scenes/flyer_test.gd`: um voador chega, circula, avisa e mergulha no jogador parado no convés aberto, tirando vida.
- `test/scenes/boat_navigation_test.gd`: depois de montada a malha, há caminho do convés aberto até dentro da cabine, e ele passa pelo vão da porta.
- `test/scenes/fishman_chase_test.gd`: um peixe-homem começa na água, do lado de fora do casco, sobe pela amurada, atravessa o convés e a porta e tira vida do jogador dentro da cabine.
- `test/scenes/flashlight_stun_test.gd`: com a lanterna acesa apontada para o rosto, o peixe-homem que vem pelo convés fica atordoado.
- Conferidos com captura de tela: peixe-homem subindo pela amurada, se aproximando no convés escuro com os olhos brilhando e atordoado de olhos apagados sob a lanterna; voador circulando sobre o barco na chuva e em aviso, de olhos grandes.
