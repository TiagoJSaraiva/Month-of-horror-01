# Iluminação

## Propósito
Dar ao barco um nível de luz que depende de manutenção: o gerador gasta combustível e quebra, e as lâmpadas queimam. O nível de luz é o que os inimigos do escuro (M5) vão consultar.

## Componentes
- `lighting/lighting_rules.gd`: `LightingRules`, regras puras do nível de luz e da chance de falha.
- `lighting/generator_state.gd`: `GeneratorState` (`RefCounted`), combustível e quebra do gerador. Avisa com `running_changed(running)` quando passa a funcionar ou para.

## Regras
- Nível de luz = lâmpadas boas ÷ total, com o gerador funcionando. Sem o gerador, o nível é 0: a luz de emergência não conta.
- O gerador funciona com combustível e sem quebra. Só gasta combustível funcionando; quebrado ou vazio, para.
- Reabastecer enche o tanque e pode ser feito a qualquer momento em que ele não esteja cheio. Consertar tira a quebra, mas sem combustível o gerador continua parado.
- Falhas por sorteio: cada falha tem um intervalo médio em segundos, e a chance num passo de tempo é `1 - e^(-delta / média)`. Assim o sorteio não depende da taxa de quadros. Média zero ou negativa desliga a falha.

## Testes
- `test/unit/lighting_rules_test.gd`: nível cheio, parcial, sem energia e sem lâmpadas; chance de falha nula sem tempo ou sem média, crescente com o tempo, 1 - 1/e num intervalo médio e igual em passos divididos.
- `test/unit/generator_state_test.gd`: começa cheio, gasta funcionando, vazio para e avisa uma vez, reabastecer religa, quebrado não gasta, conserto religa, conserto sem combustível continua parado e capacidade zero nunca funciona.
