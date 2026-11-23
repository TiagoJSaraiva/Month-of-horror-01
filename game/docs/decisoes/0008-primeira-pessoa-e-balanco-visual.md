# 0008 — Primeira pessoa e balanço visual do barco

- **Data**: 2026-11
- **Status**: aceita (aberta a revisão depois de jogar)

## Contexto
O jogo é em primeira pessoa (concept 1 em `notes/`). O barco precisa balançar com as ondas, mas o jogador anda sobre ele, e inimigos sobem a bordo e voam ao redor. No Godot, um `CharacterBody3D` sobre uma plataforma que gira treme e escorrega, e o problema se repete em cada inimigo.

## Decisão
- Câmera em primeira pessoa.
- O barco fica parado na física. Jogador, inimigos e objetos do barco vivem nesse referencial estático.
- O balanço é visual: o "mundo de fora" (mar, lua, luz da lua) gira com o inverso do balanço, e o céu acompanha por `Environment.sky_rotation`. Para quem está a bordo, o horizonte inclina e a água sobe e desce no casco, como num barco de verdade.
- O balanço atrapalha a visão, mas não empurra o jogador. A intensidade é ajustável (a tempestade aumenta).

## Alternativas descartadas
- **Barco físico se movendo de verdade**: tremor e escorregão do personagem e dos inimigos, colisões instáveis.
- **Inclinar só a câmera**: o barco inclinaria junto com o horizonte na tela, o que não parece balanço de barco visto de dentro.

## Consequências
Tudo que está fora do barco (mar, lua, objetos distantes) precisa ficar dentro do nó que recebe o balanço. Se o balanço tiver de afetar a jogabilidade (escorregar, desequilibrar), isso entra como força aplicada ao jogador, sem mudar o referencial.
