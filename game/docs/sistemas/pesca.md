# Pesca

## Propósito
Lançar a linha, esperar a mordida, fisgar e vencer o minijogo para pegar o peixe que a isca atrai.

## Componentes
- `fish/fish_data.gd` (grupo "Fishing"): `bite_delay_min/max` (segundos até a mordida), `swim_speed` (trilhos por segundo no minijogo) e `direction_changes_per_second`.
- `fish/bait_data.gd` + `fish/data/{worm,squid}.tres`: `BaitData`, isca que atrai uma espécie. Worm atrai Mackerel e Squid atrai Swordfish.
- `fishing/fishing_attempt.gd`: `FishingAttempt` (`RefCounted`), uma tentativa do lançamento ao fim.
- `fishing/fishing_minigame.gd`: `FishingMinigame` (`RefCounted`), regras puras do minijogo.

## Regras
- Tentativa:
  - `WAITING`: o peixe morde depois de um tempo sorteado no intervalo da espécie (Mackerel 2–5 s, Swordfish 4–8 s).
  - `BITING`: o jogador tem 1,2 s (`HOOK_WINDOW_SECONDS`) para fisgar. Se perder, o peixe escapa.
  - Clicar antes da mordida só recolhe a linha (`CANCELLED`).
  - `REELING`: roda o minijogo. Desistir agora faz o peixe escapar.
  - Fins possíveis: `CAUGHT`, `ESCAPED` e `CANCELLED`.
- Minijogo (posições de 0 = fundo a 1 = topo do trilho):
  - a barra ocupa 25% do trilho. Segurando o botão, ela acelera para cima a 3 trilhos/s²; solto, cai a 2,5 trilhos/s² e para nas pontas;
  - o peixe anda até um destino a `swim_speed` e sorteia um destino novo em média `direction_changes_per_second` vezes por segundo (Mackerel 0,35 e 0,8; Swordfish 0,7 e 1,6);
  - a captura começa em 0,3. Com o peixe dentro da barra, enche 0,3/s × poder de pesca; fora, esvazia 0,2/s. Em 1 o peixe é pescado; em 0, escapa;
  - o poder de pesca (1 por padrão) é o valor que as cartas e os upgrades vão aumentar.

## Sinais
- `FishingAttempt.state_changed(state)`: emitido a cada mudança de estado.

## Testes
- `test/unit/fishing_minigame_test.gd`: peixe dentro da barra é pescado em cerca de 2,3 s; peixe fora escapa em cerca de 1,5 s; poder 2 pesca mais rápido; a barra sobe segurando, fica no trilho e cai ao soltar; nada muda depois do fim.
- `test/unit/fishing_attempt_test.gd`: mordida no tempo da espécie e dentro do intervalo, fisgar abre o minijogo, perder a janela faz escapar, clicar cedo recolhe, desistir puxando faz escapar, vencer o minijogo pesca e cada mudança é anunciada.
