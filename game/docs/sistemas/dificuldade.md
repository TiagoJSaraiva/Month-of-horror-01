# Dificuldade

## Propósito
Fazer cada noite da run mais difícil que a anterior.

## Componentes
- `difficulty/scaling_value.gd`: `ScalingValue` (Resource), valor da noite 1 (`first_night_value`), mudança por noite (`per_night`) e limite (`limit`: máximo quando cresce, mínimo quando cai).
- `difficulty/difficulty_curve.gd` + `difficulty/difficulty_curve.tres`: `DifficultyCurve` (Resource), um `ScalingValue` por parâmetro. Exportada na `Night` (`difficulty`).
- `difficulty/difficulty_rules.gd`: `DifficultyRules.value(scaling, night)`, a regra pura.

## Regras
- Valor na noite N = `first_night_value + per_night × (N − 1)`, parado no limite.
- Valores do MVP (multiplicadores sobre os valores do inspetor, exceto a chance de tempestade):

| Parâmetro | Noite 1 | Por noite | Limite |
|---|---|---|---|
| Intervalo entre peixes-homens | 1× | −0,1 | 0,5× |
| Intervalo entre voadores | 1× | −0,08 | 0,6× |
| Vida dos inimigos | 1× | +0,12 | 2× |
| Dano dos inimigos | 1× | +0,12 | 2× |
| Frequência das falhas de manutenção | 1× | +0,15 | 2,5× |
| Bateria da lanterna | 1× | −0,08 | 0,5× |
| Chance de tempestade | 40% | +10 pontos | 90% |
| Duração da tempestade | 1× | +0,1 | 1,5× |

- A tempestade só existe a partir da noite 2, então a chance começa, na prática, em 50%.
- O tamanho do pedido cresce por conta própria (`OrderRules`, ver `docs/sistemas/pedido.md`).
- Aplicação, no `_ready` da `Night`, depois dos bônus das cartas e antes do sorteio da tempestade:
  - `FishmanSpawner.set_difficulty` e `FlyerSpawner.set_difficulty`: intervalos, e vida e dano de cada inimigo criado (`strengthen`);
  - `BoatLighting.set_failure_frequency`: as médias das falhas são divididas pelo multiplicador;
  - `Flashlight.set_battery_seconds`: a bateria, já com o bônus de carta, é multiplicada;
  - `Storm.settings`: uma cópia do `StormSettings` com a chance e a duração da noite. O `.tres` compartilhado não muda.

## Testes
- `test/unit/difficulty_rules_test.gd`: noite 1 usa o valor inicial, valor cresce, para no limite para cima e para baixo, e a curva do MVP não muda nada na noite 1 (com 50% de tempestade na noite 2).
- `test/scenes/night_difficulty_test.gd`: uma noite 5 começa com a bateria menor que 90 s, igual ao valor da curva, e com mais de 50% de chance de tempestade, sem mexer no `.tres` compartilhado.
