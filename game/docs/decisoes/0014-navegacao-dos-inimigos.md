# 0014 — Navegação dos inimigos por malha montada ao carregar

- **Data**: 2026-11
- **Status**: aceita

## Contexto
O peixe-homem (M5) persegue o jogador pelo barco todo, inclusive dentro da cabine, que só tem uma porta de 1 m. Andar em linha reta até o jogador o deixaria preso nas paredes. O barco ainda é greybox em CSG e vai virar asset no M9.

## Decisão
- Um `NavigationRegion3D` (`BoatNavigation`, filho do `Boat`) monta a malha de navegação ao carregar a noite, um frame depois do `_ready`, a partir dos corpos estáticos do grupo `boat_navigation` (o próprio `Boat` e os filhos).
- Os inimigos usam `NavigationAgent3D` sobre essa malha.
- O tamanho de célula da navegação fica em 0,1 m (`navigation/3d/default_cell_size` e `default_cell_height` no `project.godot`, iguais aos da malha), para a porta continuar passável depois de descontado o raio do agente (0,3 m).

## Alternativas descartadas
- **Perseguir em linha reta**: simples, mas não atravessa a porta da cabine.
- **Malha escrita à mão ou salva num `.tres` por um script**: rápida de carregar, mas precisaria ser refeita à mão a cada mudança no barco, e o M9 troca toda a geometria.

## Consequências
- Mudanças no barco entram na navegação sem passo extra: basta o corpo estático estar no `Boat`.
- Enquanto o barco for CSG, o Godot avisa no console, a cada noite, que leu as malhas renderizadas das formas CSG para montar a navegação. O aviso some quando o barco virar asset com formas de colisão (M9).
- A montagem acontece com a tela preta do início da noite, então um travamento curto não aparece.
- Toda navegação futura do projeto herda a célula de 0,1 m.
