# Balanço do barco

## Propósito
Dar a sensação de estar num barco balançando sem mover o barco na física (decisão 0008).

## Componentes
- `night/boat_sway.gd`: `BoatSway`, script do nó `OutsideWorld` da cena da noite. Gira o próprio nó (mar, lua e o que mais estiver fora do barco) com o inverso do balanço e aplica a mesma rotação a `Environment.sky_rotation`.
- `night/sway_rules.gd`: `SwayRules.angles()`, regra pura que devolve os ângulos de arfagem (x) e rolagem (z) para um instante.

## Regras
- Arfagem de 1,5° com período de 9 s e rolagem de 3° com período de 7 s (`@export` no `BoatSway`). Os períodos diferentes evitam um movimento mecânico.
- `intensity` multiplica as duas amplitudes: 1 é o balanço normal, e a tempestade (M6) vai aumentá-lo.
- O balanço é só visual: não empurra o jogador nem os objetos do barco.
- Tudo o que está fora do barco precisa ser filho de `OutsideWorld`, senão não balança junto com o mar.

## Sinais
Nenhum.

## Testes
- `test/unit/sway_rules_test.gd`: ângulos dentro da amplitude, intensidade zero deixa tudo parado, cada eixo se repete após o seu período e período não positivo deixa o eixo parado.
- O alinhamento entre o céu e o mar foi conferido visualmente com balanço exagerado (6×), porque não dá para cobrir com teste unitário.
