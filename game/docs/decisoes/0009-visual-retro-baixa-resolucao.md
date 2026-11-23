# 0009 — Visual retrô em baixa resolução (provisório)

- **Data**: 2026-11
- **Status**: aceita, provisória

## Contexto
O concept 1 tem cara de jogo de PS1: "realista antigo", com referências em Resident Evil 1 e Metal Gear Solid. O estilo pode mudar no futuro para algo mais moderno e realista, ou para algo mais cartunesco. Os assets virão de fontes CC0 diferentes e precisam parecer do mesmo jogo.

## Decisão
- O mundo 3D é renderizado num `SubViewport` em resolução reduzida (`stretch_shrink` do `SubViewportContainer`) e ampliado sem filtro (`texture_filter` nearest).
- A interface (HUD, menus, cartas) fica fora do `SubViewport`, em resolução nativa, para o texto continuar legível.
- Para desfazer o efeito, basta pôr `stretch_shrink` em 1. Efeitos mais pesados de PS1 (vértices tremendo, textura afim, paleta reduzida) ficam de fora até o estilo se firmar.

## Alternativas descartadas
- **Stretch mode `viewport` no projeto inteiro**: pixelaria também a interface e o texto das cartas.
- **Shader PS1 completo desde já**: mais trabalho e mais difícil de desfazer se o estilo mudar.

## Consequências
O movimento do mouse dentro do `SubViewport` chega escalado: a câmera usa `InputEventMouseMotion.screen_relative`, que não depende da escala. O áudio 3D exige `audio_listener_enable_3d` no `SubViewport`. Mudar de estilo depois afeta os assets e o pós-processamento, não a lógica do jogo.
