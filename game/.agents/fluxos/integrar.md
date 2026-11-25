# Fluxo: integrar uma contribuição

Só no papel dono, na `main`. Integra um pull request (ou uma branch) revisando código, missão e documentação. Não use o botão de merge do GitHub: o merge feito aqui reconcilia a memória do projeto, e o GitHub marca o pull request como integrado quando o push chega.

Argumento: número do pull request (`/integrar 42`) ou `<remoto-ou-url> <branch>`.

1. Pré-condições: papel dono (`node scripts/inicio-sessao.mjs`); na `main` com `git status` limpo; `git fetch origin` e `git merge --ff-only origin/main`.
2. Busque a branch **sem trocar para ela** (o código dela ainda não foi revisto):
   - pull request: `git fetch origin pull/<N>/head:pr/<N>`;
   - remoto ou URL: `git fetch <remoto-ou-url> <branch>:pr/<branch-com-barras-trocadas-por-hífen>`.
3. Analise sem executar nada da branch: `node scripts/integrar.mjs --analisar pr/<...>` (o script é o da sua `main`, não o da branch). Leia também o diff inteiro (`git diff main...pr/<...>`) e revise pelas categorias de `revisar.md`, mais:
   - **missão**: cada commit e cada arquivo cabem nela? Algo de outro propósito é motivo para pedir que vá para outra branch;
   - **infraestrutura, scripts `@tool` e APIs sensíveis** (a análise lista cada uma): o que muda e por quê. Qualquer coisa que execute comandos, acesse a rede ou mexa em arquivos fora do projeto sem justificativa na missão é bloqueio;
   - **memória compartilhada** (`docs/status.md`, decisões numeradas): o colaborador não deveria alterar; o conteúdo vai para a reconciliação do passo 6 ou volta para ele;
   - **decisões propostas** (`docs/branches/<branch>/decisoes/`): contradizem `AGENTS.md`, as convenções ou uma decisão aceita?
4. **Pare** e apresente o relatório: resumo, problemas por gravidade, infraestrutura alterada e a sua recomendação (integrar, pedir mudanças ou recusar). Nada da branch roda antes da aprovação do desenvolvedor. Pedido de mudanças ou recusa: redija o comentário para o pull request, apague `pr/<...>` e encerre.
5. Aprovado: `git merge --no-ff --no-commit pr/<...>`.
   - Conflito: resolva preservando a intenção dos dois lados; se envolver decisão de design, `git merge --abort` e pergunte.
   - Rode o check completo (`node scripts/check.mjs`) sobre o resultado. Falha causada pela branch: `git merge --abort` e devolva ao colaborador. Ajuste pequeno de integração (ex.: a mesma ação de input dos dois lados) pode ser feito aqui, com aprovação.
   - Commit: `merge(<escopo>): integra <branch> (#<N>)`, com o objetivo da missão no corpo.
6. Reconcilie a documentação num commit próprio, `docs(<escopo>): incorpora a documentação de <branch>`:
   - cada decisão em `docs/branches/<branch>/decisoes/` vira `docs/decisoes/NNNN-<titulo>.md`, com o próximo número livre e status "aceita"; atualize as referências a ela; se substituir outra, marque a antiga;
   - `docs/status.md`: incorpore o Estado e o Validar jogando da missão (o que entrou, o que validar, pendências);
   - `docs/arquitetura.md` e `docs/sistemas/`: confira que refletem o código integrado;
   - apague `docs/branches/<branch>/` com `git rm -r` e remova as pastas vazias que sobrarem no disco (a missão fica no histórico do git).
7. Rode o check completo de novo e faça `git push origin main`. O pull request passa a constar como integrado no GitHub.
8. Limpeza: `git branch -D pr/<...>`.
9. Responda com: o que entrou, as decisões numeradas, o que validar jogando e o pull request integrado.
