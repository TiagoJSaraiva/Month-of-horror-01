# Fluxo: fim de sessão ou de tarefa

1. Confira o papel e o estado: `node scripts/inicio-sessao.mjs` e `git status -sb`.
   - **Dono na `main`**: siga todos os passos.
   - **Dono numa branch criada a pedido**: siga os passos 1 a 4 e não faça push (o passo 5 é só da `main`); diga no resumo em que branch ficaram os commits.
   - **Colaborador** (sempre na branch da missão): siga os passos com as diferenças marcadas "Colaborador".
   - Mudanças desta sessão ainda sem commit: faça o commit do módulo correspondente (modelo na seção **Git** de `AGENTS.md`).
   - Mudanças que não são suas: não inclua; cite no resumo.
2. Rode o check completo:
   `node scripts/check.mjs`
   Se falhar, corrija em um commit próprio ou reporte. **Com check falhando não há push.**
3. Atualize a memória em `docs/`:
   - `status.md`: onde paramos, próximo passo, bloqueios.
   - `arquitetura.md`, `sistemas/` e `decisoes/`: o que tiver ficado pendente (o normal é já terem ido no commit do módulo).
   Commit: `docs(status): <resumo da sessão>`.
   - **Colaborador**: não toque em `status.md` nem em `decisoes/`. Atualize `docs/branches/<branch>/missao.md` (Estado, Decisões propostas, Validar jogando); cada decisão proposta fica em `docs/branches/<branch>/decisoes/<titulo>.md`, sem número. Commit: `docs(colaboracao): atualiza o estado da missão`.
4. Revise os commits ainda não enviados:
   - Liste: `git log --oneline origin/main..HEAD` (sem remoto: os commits desta sessão). **Colaborador**: `git log --oneline upstream/main..HEAD`.
   - Em cada commit (`git show --stat <hash>`): mensagem no modelo, sem rodapé de coautoria, escopo coerente com o módulo, nenhum arquivo indevido (`.godot/`, relatórios, segredos, binários sem motivo).
   - Diff total (`git diff origin/main...HEAD`; colaborador: `git diff upstream/main...HEAD`) pelas categorias de `revisar.md`.
   - **Colaborador**: tudo cabe na missão? O que não couber sai desta branch (vai para outra) antes do push.
   - Bug real ou arquivo indevido: corrija em novo commit e volte ao passo 2.
   - Mensagem fora do modelo: corrija com `git commit --amend` se for o último commit e ainda não enviado; senão, cite no resumo.
   - As demais categorias não bloqueiam o push: relate no resumo.
5. Push: `git push origin main` (na primeira vez, `git push -u origin main`).
   - Sem remoto `origin`: não faça push; avise.
   - Rejeitado porque o remoto tem commits novos: `git pull --rebase=merges origin main` (preserva os merges do `/integrar`). Com conflito, `git rebase --abort` e reporte. Sem conflito, rode o check completo de novo e repita o push.
   - Nunca use `--force`.
   - **Colaborador**: `git push -u origin <branch>` (o seu fork). Nunca faça push da `main` nem para `upstream`. Antes, `git fetch upstream`: se a `main` original avançou e a branch não integra limpa com ela (`git merge-tree --write-tree upstream/main HEAD` falha), faça `git merge upstream/main -m "merge: atualiza a branch com a main original"` na branch, resolva (o que for da missão prevalece; dúvida, pergunte), rode o check e só então envie. Nunca rebase de commit já enviado.
6. Responda com:
   - Resumo das mudanças de código (arquivos e propósito).
   - Arquivos de `docs/` alterados.
   - Commits enviados (hash curto e título), ou o motivo de não ter enviado.
   - Pontos da revisão que não bloquearam o push.
   - O que o desenvolvedor deve validar jogando (game feel, visual).
   - **Colaborador**: o texto do pull request, pronto para colar: título `<tipo>(<escopo>): <resumo da missão>`; corpo com Objetivo, o que entrou, Estado, Decisões propostas e Validar jogando, tirados da missão. Diga onde abri-lo: no GitHub, a página do fork mostra "Compare & pull request" para a branch enviada; o destino é a `main` do repositório original.
