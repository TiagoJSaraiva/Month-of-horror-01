# 0010 — Renderer Forward+

- **Data**: 2026-11
- **Status**: aceita

## Contexto
O documento de game loop no Notion previa o renderer Compatibility, que faz sentido para web e hardware fraco. O jogo será lançado só para Windows.

## Decisão
Usar o renderer Forward+ (padrão do Godot), configurado no `project.godot`.

## Alternativas descartadas
- **Compatibility**: sem neblina volumétrica nem compute shaders (que vários oceanos prontos usam), e com limite de luzes por objeto. Não há exportação web que justifique essas perdas.

## Consequências
- Ficam disponíveis neblina volumétrica para o clima de terror e oceanos prontos baseados em compute shader (FFT).
- Sem limite prático de luzes por malha, o que importa para as lâmpadas do barco.
- Exige GPU com Vulkan ou Direct3D 12, aceitável para um jogo de PC.
