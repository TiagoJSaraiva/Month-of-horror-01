# 0011 — Assets CC0, greybox e registro do que é gerado por IA

- **Data**: 2026-11
- **Status**: aceita

## Contexto
A jam proíbe assets gerados por IA. O MVP tem prazo curto e precisa de modelos, rigs, animações, texturas e sons. Alguns itens específicos (um barco de pesca com cabine, por exemplo) dificilmente existem em CC0.

## Decisão
- As mecânicas são feitas com primitivas e CSG (greybox) até o marco de assets (M9), para nenhuma mecânica esperar por arte.
- Os assets vêm primeiro de bibliotecas CC0. O que não for encontrado é gerado por um agente de IA (Blender ou ferramenta parecida), gastando o mínimo de tokens.
- Todo asset de terceiros ou gerado por IA, assim como todo addon do Godot, é registrado em `docs/assets.md` com arquivo, fonte, licença e se foi gerado por IA.
- Antes de enviar o jogo para a jam, todo item marcado como gerado por IA precisa ser substituído.

## Alternativas descartadas
- **Buscar assets definitivos antes das mecânicas**: trava o MVP esperando arte que pode mudar com o estilo (decisão 0009).
- **Registrar só o que é gerado por IA**: licenças CC-BY e de addons também exigem crédito, então o registro único serve para as duas coisas.

## Consequências
O jogo fica feio até o M9, de propósito. O registro precisa ser atualizado no mesmo commit em que o asset entra no projeto.
