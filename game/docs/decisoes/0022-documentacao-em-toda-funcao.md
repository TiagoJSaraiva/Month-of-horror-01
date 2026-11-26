# 0022 — `##` em toda função do jogo

- **Data**: 2026-11
- **Status**: aceita (substitui a regra de `docs/convencoes-gdscript.md` que pedia `##` só em classes e métodos públicos)

## Contexto
O desenvolvedor lê e revisa todo o código. Até aqui o `##` aparecia só em classes e em parte dos métodos públicos: 292 das 420 funções do jogo não tinham documentação, e um `#` solto acima de algumas delas não aparece na ajuda do editor. Quem revisa precisava ler o corpo para saber o contrato.

Um `##` só ajuda se acompanha a função: quando o corpo muda e o texto fica como estava, a documentação passa a mentir. O `godot-template` (decisão 0011 de lá) resolveu os dois problemas com uma etapa do check, e este projeto traz as mesmas ferramentas (`scripts/lib/docs.mjs`, `scripts/check-doc-review.mjs`).

## Decisão
- **Toda função do jogo tem `##` na linha logo acima**, pública ou privada, virtual ou handler de sinal. Ficam de fora `test/` (os testes já se descrevem pelo nome `test_<comportamento>`), `addons/` e `.godot/`.
- O `##` é uma linha com o contrato: o que a função faz ou garante, no presente, sem repetir o nome. Regra não óbvia, efeito colateral ou valor devolvido em casos de borda entram em mais linhas. O `#` continua para o **porquê** (regra de design, contorno de bug, valor não óbvio) e fica dentro do corpo.
- **Função alterada tem o `##` revisado.** O check compara com o `HEAD`: se a assinatura ou o corpo mudou e o `##` não, ele reprova e lista a função. Quem alterou atualiza o texto ou, se ele continua correto, confirma com `node scripts/check-doc-review.mjs --reviewed "arquivo::funcao"`. A confirmação vale para aquele corpo (hash em `.doc-review`, ignorado pelo git); mexer de novo na função a invalida.
- A etapa fica ligada por `documentacaoDasFuncoes` em `scripts/check.config.json`, depois de a migração das funções existentes ter sido concluída, sistema por sistema.

## Alternativas descartadas
- **`##` só em métodos públicos** (a regra antiga): os handlers e as funções privadas concentram a lógica de cena, e é onde a revisão mais precisa do contrato.
- **Gerar o texto por script a partir do nome da função**: produz "Atualiza a vida", que repete o código e passa no check sem ajudar quem lê.

## Consequências
Função nova ou alterada custa uma linha a mais, e o check reprova a esquecida. A revisão do `##` das funções alteradas pode pedir `--reviewed` em mudanças pequenas; é de propósito. O texto das 292 funções migradas foi escrito lendo o corpo de cada uma e deve ser corrigido como qualquer código, no diff, quando estiver impreciso. Arquivos `.gd` novos precisam nascer com o `##`.
