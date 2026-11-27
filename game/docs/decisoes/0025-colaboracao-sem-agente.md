# 0025 — Colaboração sem agente de IA

- **Data**: 2026-11
- **Status**: aceita (amplia 0021)

## Contexto
A colaboração por fork (0021) pressupõe um agente de IA dos dois lados: o `/colaborar` pergunta a missão e cria a branch, e o `/fim` atualiza a missão, confere a main original, envia a branch e redige o pull request. Um colaborador sem acesso a agente ficaria sem esses passos. As regras que protegem o projeto (check, CI no pull request e `/integrar`) já são mecânicas e não dependem do agente de quem contribui.

## Decisão
- O colaborador pode trabalhar sem agente, seguindo o guia do seu sistema, na raiz do repositório: `COLABORAR-SEM-IA-WINDOWS.md` ou `COLABORAR-SEM-IA-LINUX.md`. Os dois têm o mesmo fluxo; só a instalação dos programas muda.
- `node scripts/colaborar.mjs` sem argumentos é o modo guiado: pergunta tipo, nome, objetivo, o que entra, o que fica de fora e pastas; cria a branch a partir de `upstream/main`, preenche a missão e faz o commit dela. Com `--branch`, continua como antes (o agente preenche a missão).
- `node scripts/fim-colaborador.mjs` faz o `/fim` do colaborador: para com mudança sem commit ou merge em andamento; faz o merge da main original só quando ela conflita com a branch; roda o check completo e para se ele gerar arquivos (como `.uid`); pergunta estado, validar jogando e decisões propostas e faz o commit; envia a branch para o fork (nunca `--force`) e mostra o texto e o link do pull request.
- As regras continuam as de 0021. Os dois caminhos se misturam: uma branch começada à mão pode ser terminada pelo agente, e vice-versa.

## Alternativas descartadas
- **Agente gratuito só no início e no fim da sessão** (Codex, Gemini CLI): o `/fim` é o passo que mais consome cota, a revisão sem o contexto da sessão vale pouco, e o fluxo dependeria de uma cota que pode mudar.
- **Só um guia com comandos git**: deixaria à mão a parte mais propensa a erro (missão, merge com a main original, texto do pull request).

## Consequências
- Mudança numa regra de colaboração precisa manter coerentes o `AGENTS.md`, os fluxos, os dois guias e os dois scripts.
- A revisão do que o colaborador fez continua no CI e no `/integrar`, como antes.
