# Pesca

## Propósito
Lançar a linha, esperar a mordida, fisgar e vencer o minijogo para pegar o peixe que a isca atrai.

## Componentes
- `fish/fish_data.gd` (grupo "Fishing"): `bite_delay_min/max` (segundos até a mordida), `swim_speed` (trilhos por segundo no minijogo) e `direction_changes_per_second`.
- `fish/bait_data.gd` + `fish/data/{worm,squid}.tres`: `BaitData`, isca que atrai uma espécie. Worm atrai Mackerel e Squid atrai Swordfish.
- `fishing/fishing_attempt.gd`: `FishingAttempt` (`RefCounted`), uma tentativa do lançamento ao fim.
- `fishing/fishing_minigame.gd`: `FishingMinigame` (`RefCounted`), regras puras do minijogo.
- `fishing/fishing_rod.gd`: `FishingRod`, filho da `Camera3D` do jogador, ligado a `Hands` e `HudEvents` por `@export`.
  - Trata botão esquerdo (lançar, fisgar, puxar segurando), botão direito (recolher ou desistir) e Q (trocar isca, só com a linha fora d'água).
  - Conduz a `FishingAttempt` e mostra `Model` (vara greybox) só com a vara pronta na mão (`is_tool_ready(ROD)`).
  - `Aim` é um RayCast de 15 m nas camadas `world` e `water`.
- `fishing/bobber.tscn` / `bobber.gd`: `Bobber`, boia vermelha sem sombreamento, filha da vara com `top_level`. A cada frame de física procura a água por raio e acompanha a altura dela, que muda com o balanço. Na mordida afunda 12 cm.
- `night/water_surface.gd`: `WaterSurface` (`StaticBody3D`, camada `water`, sem máscara), caixa de 2000×0,2×2000 m com o topo em y = 0, dentro do `OutsideWorld`.
- `ui/hud/fishing_minigame_view.gd`: `FishingMinigameView`, `Control` do `Hud` que desenha o trilho, a barra, o peixe e a captura lendo o modelo.

## Regras
- Lançar exige a vara pronta na mão (ver `docs/sistemas/maos.md`) e a mira na água: o primeiro objeto atingido pelo `Aim` precisa ser a `WaterSurface`. Mirar o barco mostra "Aim at the water to cast.". Dá para lançar de qualquer ponto, desde que a mira passe por cima da amurada.
- Com a linha na água, `tool_busy` fica ligado: não dá para abrir o diário nem pegar coisas.
- Sacar o revólver (tecla 2) com a linha na água cancela a tentativa: antes da fisgada recolhe a linha, durante o minijogo o peixe escapa.
- A isca escolhida define a espécie que morde. As iscas ficam em `baits` (`@export` na vara), e a atual aparece no HUD.
- Pescado, o peixe vai para as mãos (modo `CARRYING`) depois de a vara liberar `tool_busy`.
- Mensagens no HUD: "Waiting for a bite...", "Something's biting! Click to hook it.", "Hold the mouse button to reel.", "You caught a X!" e "It got away...". As de resultado somem em 2,5 s.
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
- `FishingAttempt.state_changed(state)` → `FishingRod._on_attempt_state_changed`: boia, mensagens, minijogo e peixe para as mãos.
- `Hands.changed` → `FishingRod._on_hands_changed`: mostra ou esconde a vara e cancela a tentativa quando a vara sai da mão.
- Pelo canal `HudEvents`: `bait_changed`, `hint_requested`, `minigame_started(minigame)` e `minigame_finished`.

## Testes
- `test/unit/fishing_minigame_test.gd`: peixe dentro da barra é pescado em cerca de 2,3 s; peixe fora escapa em cerca de 1,5 s; poder 2 pesca mais rápido; a barra sobe segurando, fica no trilho e cai ao soltar; nada muda depois do fim.
- `test/unit/fishing_attempt_test.gd`: mordida no tempo da espécie e dentro do intervalo, fisgar abre o minijogo, perder a janela faz escapar, clicar cedo recolhe, desistir puxando faz escapar, vencer o minijogo pesca e cada mudança é anunciada.
- A boia na água, o desenho do minijogo e o peixe nas mãos depois da captura foram conferidos com capturas de tela (lançamento e vitória forçados pelo script de captura).
