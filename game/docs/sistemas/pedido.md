# Pedido

## Propósito
Definir quais peixes o jogador precisa entregar em cada noite e acompanhar as entregas.

## Componentes
- `fish/fish_data.gd`: `FishData` (Resource), uma espécie de peixe com `id` e `display_name`.
- `fish/data/*.tres`: as espécies. No MVP são duas: `mackerel` (Mackerel) e `swordfish` (Swordfish), nomes provisórios.
- `night/order_rules.gd`: `OrderRules`, regras puras de tamanho e sorteio do pedido.
- `night/night_order.gd`: `NightOrder` (`RefCounted`), o pedido de uma noite e as entregas.

## Regras
- O pedido tem 3 peixes na noite 1 e mais 1 a cada noite seguinte (`OrderRules.BASE_FISH_COUNT` e `FISH_PER_NIGHT`). Noite menor que 1 conta como noite 1.
- A espécie de cada peixe é sorteada entre as espécies disponíveis, então o pedido pode sair todo de uma espécie só.
- Uma entrega é um peixe guardado no freezer (M2). Peixes a mais, ou de espécie fora do pedido, ficam registrados, mas não reduzem o que falta.
- `missing_total()` soma o que falta de cada espécie. O M3 usa esse valor para decidir a vida perdida e o passe livre ("falta exatamente 1").
- Quantidade zero ou negativa é ignorada.

## Sinais
- `NightOrder.changed`: emitido a cada entrega.

## Testes
- `test/unit/order_rules_test.gd`: tamanho por noite, total sorteado, espécies usadas, seed fixa e lista vazia.
- `test/unit/night_order_test.gd`: faltantes, entregas a mais, espécie fora do pedido, pedido completo, quantidade inválida, `changed` e `species()`.
