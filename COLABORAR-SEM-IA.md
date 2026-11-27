# Colaborar sem agente de IA

Guia para quem contribui com este projeto **sem Claude, Codex ou outro agente**. O fluxo é o mesmo dos agentes (fork, uma branch por contribuição, pull request); a diferença é que você roda os scripts direto no terminal.

Resumo: **uma vez por máquina** você configura; **a cada contribuição** roda dois comandos, um no começo e um no fim:

```sh
node scripts/colaborar.mjs        # começa: pergunta a missão e cria a branch
# ... trabalha no Godot e faz commits ...
node scripts/fim-colaborador.mjs  # termina: check, missão, envio e texto do pull request
```

Todos os comandos deste guia rodam **dentro da pasta `game/`** do projeto (no VS Code: *Terminal > New Terminal*, e `cd game`).

## 1. Uma vez por máquina

### Programas

| Programa | Para quê | Como conferir |
|---|---|---|
| Godot **4.7.x** (Steam ou site oficial; no Linux, o executável do site, não o Flatpak) | o jogo | abrir o Godot e ver a versão |
| Node.js 18+ | os scripts do projeto | `node --version` |
| Python 3 | formatador e lint do GDScript | `python --version` |
| Git | versionamento | `git --version` |
| Conta no GitHub | fork e pull request | — |
| VS Code + extensão godot-tools (opcional) | editar GDScript e resolver conflitos | — |

No Windows: `winget install OpenJS.NodeJS.LTS`, `winget install Python.Python.3.12`, `winget install Git.Git`.

### Fork e clone

1. No GitHub, abra o repositório original e clique em **Fork**. Isso cria uma cópia na sua conta.
2. Clone **o seu fork** (não o original): `git clone <url-do-seu-fork>`.
3. Entre na pasta `game/` do clone.

### Configurar

```sh
node scripts/configurar.mjs                              # diagnóstico: mostra o que falta
node scripts/configurar.mjs --papel colaborador
node scripts/configurar.mjs --upstream <url-do-repositorio-original>
node scripts/configurar.mjs --godot "<caminho-do-executavel-do-godot>"
pip install -r requirements.txt                          # formatador e lint (gdtoolkit)
git fetch upstream
```

- O caminho do Godot é o do **arquivo** executável, não da pasta. O diagnóstico sugere os que encontrar.
- Se o diagnóstico disser que falta a identidade do git: `git config --global user.name "Seu Nome"` e `git config --global user.email "seu@email"`.
- Repita `node scripts/configurar.mjs` até aparecer **"Máquina pronta"**. Depois rode o check completo uma vez: `node scripts/check.mjs` (a primeira vez demora: o Godot importa o projeto).

## 2. Começar uma contribuição

```sh
node scripts/colaborar.mjs
```

O script pergunta, nesta ordem:

1. **Tipo** da mudança: `feat` (algo novo), `fix` (correção), `refactor`, `perf`, `test`, `docs`, `assets` (arte, som, fontes), `chore`.
2. **Descrição curta**, que vira o nome da branch (ex.: `fix/corrige-pulo-duplo`). Pode aceitar a sugestão com Enter ou digitar outro nome.
3. **Objetivo**: o que muda para quem joga ou para o projeto.
4. **O que entra** e **o que fica de fora**: um item por linha, linha vazia termina.
5. **Pastas** que você espera alterar (ex.: `player/`, `test/unit/`).

Ele cria a branch a partir da `main` do original (não precisa atualizar o fork antes), grava a missão em `docs/branches/<branch>/missao.md` e faz o commit dela.

**Uma branch, um propósito.** Corrigir o pulo e criar um menu são duas contribuições: duas branches, dois pull requests. O check reprova commit de tipo que não cabe na branch (ex.: `feat` numa branch `fix/`).

## 3. Trabalhar

### Regras de código (o check cobra)

Detalhes em `docs/convencoes-gdscript.md`. O essencial:

- **Tipo escrito em tudo**: `var speed: float = 200.0`, `func jump() -> void:`, `for enemy: Enemy in enemies:`. Nunca `:=`.
- **Sintaxe do Godot 4**: `@export`, `@onready`, `await`, `signal.connect(callable)`.
- **`##` acima de toda função** (fora de `test/` e `addons/`), dizendo o que ela faz ou devolve.
- Mudou uma função e o `##` dela continua certo? Confirme: `node scripts/check-doc-review.mjs --reviewed "player/player.gd::jump"`. O check avisa quando isso é preciso e mostra o comando.
- Mecânica nova vem com teste em `test/unit/` (gdUnit4). Arquivos `<alvo>_test.gd`, funções `test_<comportamento>`.
- Nomes de arquivos, nós e variáveis em inglês; comentários em português.

### Arquivos que você não altera

`docs/status.md`, `docs/decisoes/`, `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.agents/`, `.claude/`, `.gemini/`, `.mcp.json`, `scripts/`, `addons/`, `requirements.txt`, `.gitignore`, `.editorconfig` e tudo fora de `game/` (menos `notes/`). São a memória e as ferramentas do projeto; o check reprova se mudarem. Se a sua missão realmente precisar de um deles, liste-o em "Arquivos protegidos autorizados" na `missao.md` e explique no pull request.

`docs/arquitetura.md` e `docs/sistemas/` você atualiza, sim, junto com o código que os mudou.

### Commits

Faça um commit a cada parte pronta e funcionando (um componente com seus testes, uma correção), não um único commit no fim.

```sh
node scripts/check.mjs --fix --fast    # formata e roda o check rápido; precisa passar
git status                             # confira o que mudou
git add player/player.gd player/player.gd.uid test/unit/player_test.gd
git commit -m "fix(player): corrige pulo duplo ao sair da plataforma"
```

- Mensagem: `<tipo>(<escopo>): <resumo>`, em português, verbo no presente, minúsculo, sem ponto final. Ex.: `feat(hud): adiciona barra de stamina`, `test(player): cobre pulo no limite da plataforma`.
- Tipos que cada branch aceita: `feat/` → feat, test, docs, assets; `fix/` → fix, test, docs; `refactor/` e `perf/` → o próprio tipo, test, docs; `test/` → test, docs; `docs/` → docs; `assets/` → assets, docs; `chore/` → chore, docs.
- Script novo: o `.uid` que o Godot (ou o check) gera para ele vai **no mesmo commit**.
- Pelo VS Code também funciona (aba *Source Control*): marque os arquivos, escreva a mensagem no mesmo formato e faça o commit.

## 4. Terminar

```sh
node scripts/fim-colaborador.mjs
```

O script:

1. Para se houver mudança sem commit (faça o commit e rode de novo).
2. Busca a `main` original. Se ela mudou de um jeito que conflita com a sua branch, ele traz as mudanças para a branch; havendo conflito, explica como resolver.
3. Roda o **check completo**. Falhou: corrija, faça o commit e rode de novo.
4. Pergunta o **estado** (o que ficou feito e o que falta), o que o dono deve **testar jogando** e se houve alguma **decisão de projeto** a registrar. Grava tudo na missão e faz o commit.
5. Pede confirmação e **envia a branch para o seu fork**.
6. Mostra o **título e a descrição do pull request** e o link para abri-lo.

Pode rodar quantas vezes precisar: o que já foi feito é mantido (Enter mantém o que estava registrado).

## 5. Pull request

1. Abra o link que o script mostrou (ou, na página do seu fork, **Compare & pull request**). O destino é a `main` do repositório **original**.
2. Cole o título e a descrição e crie o pull request.
3. O GitHub roda o check (CI) com as mesmas regras. Se falhar, a página do PR mostra o motivo.
4. O dono revisa. Pediu mudanças? Continue **na mesma branch**, faça os commits e rode `node scripts/fim-colaborador.mjs` de novo: o pull request se atualiza sozinho.
5. Integrado: comece a próxima contribuição com `node scripts/colaborar.mjs`. Ele lista as branches antigas que já podem ser apagadas.

## Problemas comuns

| Mensagem | O que fazer |
|---|---|
| `não está no papel colaborador` | `node scripts/configurar.mjs --papel colaborador` |
| `falta o remoto upstream` | `node scripts/configurar.mjs --upstream <url-do-original>` |
| `há mudanças sem commit` | faça o commit (seção 3) ou descarte com `git restore <arquivo>` |
| `GODOT_PATH não definido` | `node scripts/configurar.mjs --godot "<caminho>"` |
| `gdformat não encontrado` | `pip install -r requirements.txt` e reabra o terminal |
| check acusa formatação | `node scripts/check.mjs --fix --fast` e faça o commit do resultado |
| check acusa função sem `##` ou com `##` não revisado | escreva ou atualize o `##`, ou confirme com o comando que o check mostra |
| check acusa tipo de commit que a branch não aceita | o commit é de outro propósito: ele deveria estar em outra branch. Peça ajuda ao dono antes de mexer em commits já feitos |
| conflito no fim | siga as instruções que o script mostra; para desistir: `git merge --abort` |
| `ERROR: Remote Debugger ... port` nos testes | ruído conhecido, não é falha |

Nunca use `git push --force` nem altere commits já enviados. Na dúvida, pare e pergunte ao dono.

## Para quem usa agente

Os mesmos passos existem como comandos: `/configurar`, `/colaborar`, `/fim` (e `/planejar`, `/revisar`). Este guia e os comandos podem ser misturados: uma branch criada à mão pode ser terminada pelo agente, e vice-versa.
