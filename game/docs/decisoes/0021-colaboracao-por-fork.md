# 0021 — Colaboração por fork e pull request

- **Data**: 2026-11
- **Status**: aceita (amplia 0019)

## Contexto
O projeto passa a aceitar colaboradores, com agentes de IA dos dois lados. As regras de Git (0019) pressupõem uma pessoa: trabalho direto na `main`, push pelo agente no `fim`, uma única memória em `docs/status.md` e decisões numeradas em sequência. Com várias pessoas, os agentes disputariam a `main`, as memórias se sobrescreveriam, duas branches criariam a mesma "decisão 0015", e branches misturariam propósitos (uma correção de movimento trazendo um menu novo). Além disso, integrar um pull request executa código de terceiros na máquina do dono: o check roda scripts do jogo, e um hook ou script alterado roda no próximo comando.

## Decisão
- **Papéis por máquina, fora do repositório**: `git config projeto.papel` (dono | colaborador), definido no `/configurar`. As regras dos dois papéis ficam fixas no `AGENTS.md`; nada versionado muda conforme quem trabalha. O hook de início mostra papel, branch e missão ao agente.
- **Colaborador**: fork como `origin`, original como `upstream`. Nunca altera nem envia a `main`. Cada contribuição é uma branch criada pelo `/colaborar` a partir de `upstream/main`, com nome `<tipo>/<descrição-em-kebab-case>` (tipos dos commits, ASCII minúsculo, até 50 caracteres) e uma missão em `docs/branches/<branch>/missao.md`. Push só da própria branch para o fork; pull request para a `main` original.
- **Uma branch, um propósito**, verificado pelo check em modo colaborador: reprova branch na `main`, nome fora do padrão, missão ausente, arquivo protegido alterado sem autorização na missão e commit de tipo que a branch não aceita (ex.: `feat` numa `fix/`); avisa sobre arquivo fora das pastas declaradas. O agente compara cada pedido com a missão antes de agir.
- **Memória sem conflito**: o colaborador não edita `docs/status.md` nem `docs/decisoes/`. O estado da branch fica na missão, e as decisões propostas em `docs/branches/<branch>/decisoes/`, sem número. `arquitetura.md` e `sistemas/` acompanham o código, como sempre.
- **Integração pelo `/integrar`, não pelo botão do GitHub**: o dono busca a branch (`pull/<N>/head`) sem fazer checkout, analisa com o `scripts/integrar.mjs` da própria `main` (que lista infraestrutura, scripts `@tool` e memória alterada, com diff), revisa e só executa o código da branch depois de aprovar. Depois: merge `--no-ff` com check, um commit que numera as decisões propostas, incorpora o estado ao `status.md` e apaga a pasta da branch, e push. O GitHub marca o pull request como integrado quando os commits chegam à `main`.
- **CI no GitHub Actions** (`.github/workflows/check.yml`): o check completo roda em Linux a cada pull request, com as regras de colaborador, e a cada push na `main`. O pull request é validado numa máquina do GitHub antes de rodar na do dono. O check aceita `PROJETO_PAPEL`, `PROJETO_BRANCH` e `PROJETO_BASE` no ambiente, porque no CI não há `git config` local e o HEAD do pull request fica solto. Sem tela, os testes rodam numa tela virtual (Xvfb): com `--headless`, o Godot não entrega eventos de input e os testes de cena com interação falhariam.
- **Texto com LF em todas as máquinas** (`.gitattributes` com `eol=lf`): o Godot grava os arquivos que gera sempre com LF; com cópias de trabalho em CRLF, um clone novo ficava com dezenas de `.import` "alterados" depois do primeiro import, o que travava o `/colaborar` e o `/integrar`, que exigem a árvore limpa.

## Alternativas descartadas
- **Merge pelo botão do GitHub**: o código entraria na `main` sem reconciliar a memória (estado e numeração das decisões), e o agente do dono não revisaria a missão.
- **Modo colaborador escrito na documentação versionada**: a mudança iria na branch, no pull request e na `main` do dono.
- **Colaboradores em branches do próprio repositório original**: exige dar permissão de escrita a cada colaborador; o fork isola o que ainda não foi revisto.
- **Missão só como instrução ao agente**: a experiência com o `##` no the-beacon e no godot-template mostrou que regra só escrita não é seguida; a parte verificável vai para o check.

## Consequências
Contribuições chegam com propósito declarado e documentação sem conflito, e o dono revisa antes de executar qualquer código de terceiros. Em troca, colaborar exige fork, `/configurar` uma vez e `/colaborar` a cada contribuição, e o dono integra pelo agente. Uma mudança de infraestrutura vinda de colaborador precisa ser autorizada na missão e revista no `/integrar`.
