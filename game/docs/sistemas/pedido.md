# Pedido

## Propósito
Definir quais peixes o jogador precisa entregar em cada noite e acompanhar as entregas.

## Componentes
- `fish/fish_data.gd`: `FishData` (Resource), uma espécie de peixe com `id` e `display_name`.
- `fish/data/*.tres`: as espécies. No MVP são duas: `mackerel` (Mackerel) e `swordfish` (Swordfish), nomes provisórios.
- `night/order_rules.gd`: `OrderRules`, regras puras de tamanho e sorteio do pedido.
- `night/night_order.gd`: `NightOrder` (`RefCounted`), o pedido de uma noite e as entregas.
- `player/journal.gd`: `Journal`, filho do `Head` do jogador. Abre e fecha com uma animação curta quando o `Hands` manda (Tab; ver `docs/sistemas/maos.md`). `display(night_number, order)` é chamado pela `Night` no início da noite.
- `player/journal_text.gd`: `JournalText`, função pura que monta o texto do diário.

## Regras
- O pedido tem 3 peixes na noite 1 e mais 1 a cada noite seguinte (`OrderRules.BASE_FISH_COUNT` e `FISH_PER_NIGHT`). Noite menor que 1 conta como noite 1.
- A espécie de cada peixe é sorteada entre as espécies disponíveis, então o pedido pode sair todo de uma espécie só.
- Uma entrega é um peixe guardado no freezer (M2). Peixes a mais, ou de espécie fora do pedido, ficam registrados, mas não reduzem o que falta.
- `missing_total()` soma o que falta de cada espécie. O M3 usa esse valor para decidir a vida perdida e o passe livre ("falta exatamente 1").
- Quantidade zero ou negativa é ignorada.
- Diário:
  - mostra "NIGHT n", "ORDER" e uma linha `Nome entregues/pedidos` por espécie, em ordem alfabética. Não mostra a hora;
  - fica preso ao giro horizontal do `Head`, e não à inclinação da câmera. Aberto, fica a cerca de 53° abaixo do olhar e a 25 cm do olho, dentro da cápsula, então não atravessa paredes. Olhando para a frente, só o topo dele aparece; para ler, o jogador olha para baixo;
  - página e texto não recebem sombreamento, para serem legíveis no escuro;
  - o `Label3D` ignora linhas em branco, por isso o texto não tem espaçamento entre blocos;
  - o jogador pode andar com o diário aberto, mas não pescar nem carregar nada.

## Sinais
- `NightOrder.changed` → `Journal._refresh`: o diário reescreve o texto a cada entrega.

## Testes
- `test/unit/order_rules_test.gd`: tamanho por noite, total sorteado, espécies usadas, seed fixa e lista vazia.
- `test/unit/night_order_test.gd`: faltantes, entregas a mais, espécie fora do pedido, pedido completo, quantidade inválida, `changed` e `species()`.
- `test/unit/journal_text_test.gd`: número da noite, ordem alfabética e peixes entregues.
- A legibilidade do diário em 576×324 foi conferida com captura de tela.
