# Escopo do MVP

Fonte: página "Game Loop (English)" do Notion e respostas do desenvolvedor em 2026-11-23.
As regras ficam aqui até o sistema existir. Ao implementar um sistema, as regras dele migram para `docs/sistemas/<sistema>.md` e saem desta nota.

## Prazo e plataforma
- Windows apenas, teclado e mouse. Textos do jogo em inglês.
- MVP: meta de cerca de 1 semana a partir de 2026-11-23. Jogo completo: 25 dias (jam). Depois do MVP, o jogo amadurece com o resto do escopo do Notion e novas decisões.
- A jam proíbe assets gerados por IA (decisão 0011).

## Conceito
Roguelite noturno em primeira pessoa (decisão 0008). Um pescador num barco ancorado precisa cumprir pedidos de peixe para clientes misteriosos entre 23:00 e 06:00 (7 min reais), mantendo a iluminação do barco e sobrevivendo a ameaças. A lore fica implícita.

## Loop da run
Implementado em `docs/sistemas/run.md`: noite com bilhete na mesa, amanhecer, avaliação do pedido, vidas, próxima noite e fim de run na terceira falha ou na morte do jogador. Falta encaixar:
- pontos de run para upgrades permanentes no fim (M8);
- gaivotas no amanhecer (M9).

A run é infinita e a dificuldade sobe a cada noite (M7).

## Regras por sistema

### Noite e pedido
- Tempo da noite, amanhecer e relógio de parede: implementados; regras em `docs/sistemas/noite.md`.
- Pedido e diário: implementados; regras em `docs/sistemas/pedido.md`.
- Entrega no freezer: implementada; regras em `docs/sistemas/maos.md`.

### Mãos
- Diário, itens carregados (peixe, galão, lâmpada), interação de segurar e vara: implementados; regras em `docs/sistemas/maos.md`. Lanterna na mão esquerda: `docs/sistemas/iluminacao.md`.
- A mão direita alterna entre vara e revólver: implementado; ver `docs/sistemas/maos.md`.

### Pesca
- Implementada; regras em `docs/sistemas/pesca.md`.

### Iluminação
- Gerador, lâmpadas, luz de emergência, suprimentos, reparos, sorteio de falhas, lanterna e caixa de pilhas: implementados; regras em `docs/sistemas/iluminacao.md`.
- Falta: falhas mais frequentes a cada noite e bateria que dura menos (M7) e falhas mais frequentes na tempestade (M6).

### Inimigos
- **Peixe-homem** (escuridão): implementado, com o atordoamento pela lanterna; regras em `docs/sistemas/inimigos.md`. Falta a força crescente por noite (M7).
- **Voador** (tempestade): implementado; regras em `docs/sistemas/inimigos.md`. Falta a força crescente por noite (M7).
- No MVP, nenhum inimigo rouba peixe.

### Tempestade
- Sorteio, intensidade, balanço forte, céu, lua, chuva com vento, relâmpagos e falhas mais frequentes: implementados; regras em `docs/sistemas/tempestade.md`.
- Falta: chance e duração crescendo a cada noite (M7).

### Combate e vida
- Revólver, vida com regeneração e morte encerrando a run: implementados; regras em `docs/sistemas/combate.md`.

### Vidas e mensagens
- Regras de vidas, passe livre e bilhete: implementadas em `docs/sistemas/run.md`.

### Cartas
- Seleção, raridades, rerolls, slots e os efeitos das 9 cartas: implementados; regras em `docs/sistemas/cartas.md`.

### Dificuldade
- Sobe a cada noite: tamanho do pedido, frequência e força dos inimigos, falhas de manutenção, duração da bateria (cai), chance e duração da tempestade. A curva fica em Resource.

### Meta-progressão
- Pontos = 10 × noites cumpridas + 1 por peixe entregue, pagos no fim da run.
- Upgrades permanentes: vida, dano e poder da vara. Cada um dá +10% por nível, até 5 níveis, com custo crescente.
- Só a meta-progressão é salva. Sair no meio da run conta como derrota, e os pontos são pagos normalmente.

### Mundo e visual
- Barco ancorado, sem navegação. Ambientes: barco e mar.
- Estilo retrô "realista antigo", referências Resident Evil 1 e Metal Gear Solid (decisão 0009, provisória).
- Mar animado e barco balançando (balanço visual, decisão 0008).
- Céu com lua e estrelas que se movem ao longo da noite. Ele muda durante a tempestade e clareia aos poucos com a aproximação do amanhecer. Preferir addons e assets prontos.
- Menus com os componentes nativos do Godot: função antes de design.
- Assets CC0 primeiro. O que for gerado por IA fica registrado para substituição (decisão 0011).

## Fora do MVP
- Save por run, como em outros roguelikes. No MVP só a meta-progressão é salva.
- Pool de falas variadas por situação.
- Níveis e upgrades de cartas.
- Upgrades permanentes de slots, cartas por seleção e rerolls.
- Limite de 10 noites, com lore, recompensa e New Game Plus ou modo infinito.
- Novas ameaças (redemoinho, lua de sangue) e inimigos que roubam peixe do freezer.
- Áreas de pesca e espécies por área.
- Recarga gradual da lanterna.

## Arquitetura prevista
- Árvore: `Main` contém os menus e a `Run`. A `Run` é dona de um `RunState` (`RefCounted`) e troca as cenas de `Night`.
- Único autoload previsto: `MetaProgress`, que salva pontos e upgrades. Ganha nota de decisão quando for criado.
- Conteúdo em Resources: peixes, cartas, modificadores de stat, inimigos, upgrades e curva de dificuldade.
- Regras em classes puras testadas em `test/unit/`: sorteio de cartas, geração e avaliação do pedido, cálculo de stats, minijogo, nível de luz e pontos.

## Roteiro
Cada marco tem o seu próprio `/planejar`. Até o M9 tudo usa primitivas (greybox), para nenhuma mecânica esperar por asset.

| # | Marco | Resultado jogável |
|---|---|---|
| M0 | Fundação (feito) | Andar em primeira pessoa num barco greybox, render em baixa resolução, balanço visual |
| M1 | Noite e pedido (feito) | Relógio de 23h a 6h, céu provisório, diário, amanhecer congelando tudo |
| M2 | Pesca (feito) | Isca, lançamento, minijogo, peixe levado ao freezer |
| M3 | Loop da run (feito) | Vidas, passe livre, mensagens na mesa, próxima noite, fim de run |
| M4 | Iluminação (feito) | Gerador, lâmpadas, luz de emergência, lanterna e pilhas, reparos |
| M5 | Combate (feito) | Arma, vida e regeneração, morte, peixe-homem |
| M6 | Tempestade (feito) | Evento, balanço forte, chuva, céu, voador |
| M7 | Cartas e dificuldade | Seleção de cartas, raridades, rerolls, slots, escala por noite |
| M8 | Meta e menus | Pontos, upgrades, save, menus |
| M9 | Mar, céu e assets | Oceano e céu definitivos, assets CC0, áudio |

Se o prazo apertar, a tempestade (M6) é a primeira candidata a corte ou simplificação.
