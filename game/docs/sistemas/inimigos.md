# Inimigos

## Propósito
Ameaçar o jogador quando o barco fica escuro. No MVP: o peixe-homem (M5) e o voador da tempestade (M6).

## Navegação (decisão 0014)
- `boat/boat_navigation.gd`: `BoatNavigation` (`NavigationRegion3D`), filho `Navigation` do `Boat`. Um frame depois do `_ready` monta a malha a partir dos corpos estáticos do grupo `boat_navigation` (o `Boat` e todos os filhos: casco, cabine, freezer, caixas e gerador) e emite `baked`.
- Malha: célula de 0,1 m, agente de 1,8 m de altura e 0,3 m de raio, degrau máximo de 0,3 m. O convés, o interior da cabine e a porta entre eles ficam ligados. Os topos das amuradas, o teto da cabine e o tampo da mesa viram ilhas soltas, sem caminho até elas.
- Enquanto o barco for CSG, o console mostra a cada noite um aviso de que a montagem leu as malhas renderizadas das formas CSG. É esperado (ver a decisão).

## Testes
- `test/scenes/boat_navigation_test.gd`: depois de montada a malha, há caminho do convés aberto até dentro da cabine, e ele passa pelo vão da porta.
