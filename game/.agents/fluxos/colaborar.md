# Fluxo: colaborar (nova contribuição)

Só no papel colaborador. Cada contribuição é uma branch com uma única missão, criada a partir da `main` do repositório original (`upstream/main`), sem depender de o fork estar atualizado.

1. Pré-condições: `node scripts/inicio-sessao.mjs` sem ERRO e mostrando "Modo colaborador" (senão, `/configurar`). Trabalho anterior sem commit: termine-o ou pergunte o que fazer.
2. Pergunte ao colaborador a missão da contribuição:
   - **objetivo**: o que muda para quem joga ou para o projeto;
   - **inclui** e **não inclui**: o limite do que a branch entrega;
   - **pastas** do projeto que ele espera alterar.
   Missão com mais de um propósito (ex.: corrigir o pulo e criar um menu): proponha dividir em branches e pare até ele escolher uma.
3. Proponha o nome da branch e confirme com ele: `<tipo>/<descricao-em-kebab-case>`, com o tipo que descreve a missão (`feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `assets`, `chore`), só letras minúsculas sem acento, números e hífen, até 50 caracteres. Ex.: `fix/corrige-pulo-duplo`, `feat/menu-de-pausa`.
4. Crie a branch: `node scripts/colaborar.mjs --branch <nome>`.
5. Preencha `docs/branches/<nome>/missao.md` com as respostas (Objetivo, Inclui, Não inclui, Pastas). Arquivo protegido (lista em `AGENTS.md`, seção **Colaboração**) só entra em "Arquivos protegidos autorizados" se a missão exigir; avise que quem integra vai revê-lo.
6. Commit: `docs(colaboracao): registra a missão da branch <nome>`.
7. Limpeza: liste as suas branches já integradas no original (`git branch --merged upstream/main`, fora a `main` e a atual) e ofereça apagá-las: `git branch -d <branch>` e, no fork, `git push origin --delete <branch>`. Pergunte antes.
8. Responda com a branch, a missão resumida e o próximo passo (`/planejar` a primeira tarefa).
