// Cria a branch de uma contribuição a partir da main do repositório original (fluxo colaborar).
// Uso:
//   node scripts/colaborar.mjs                    interativo, sem agente de IA: pergunta a missão,
//                                                 cria a branch, preenche a missão e faz o commit dela
//   node scripts/colaborar.mjs --branch <tipo>/<descricao>
//                                                 só cria a branch e o esqueleto da missão, que o
//                                                 agente preenche com o colaborador
// A branch sai de upstream/main, sem depender de o fork estar atualizado.
import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { projectRoot as root, run } from "./lib/common.mjs";
import { ALLOWED_COMMITS, branchDir, branchNameError, currentRole, git } from "./lib/collab.mjs";
import { ask, askList, askRequired, choose, closeInput, confirm, slug } from "./lib/perguntar.mjs";

function fail(message) {
    console.log(`ERRO: ${message}`);
    closeInput();
    process.exit(1);
}

/** Itens de lista markdown, ou o texto de exemplo quando a lista está vazia. */
const bullets = (items, empty) => (items.length > 0 ? items.map((item) => `- ${item}`).join("\n") : `- ${empty}`);

/** Conteúdo de missao.md; sem respostas, sai o esqueleto com as instruções entre parênteses. */
function missionText(branch, answers = {}) {
    const { goal, includes = [], excludes = [], folders = [] } = answers;
    return `# Missão da branch ${branch}

Uma branch, um propósito: o que não couber nesta missão vai para outra branch.

## Objetivo
${goal ?? "(uma ou duas frases: o que muda para quem joga ou para o projeto)"}

## Inclui
${bullets(includes, "(o que esta branch entrega)")}

## Não inclui
${bullets(excludes, "(o que fica de fora, mesmo que pareça relacionado)")}

## Pastas
${bullets(folders.map((folder) => `\`${folder}\``), "(pastas do projeto que a branch deve alterar, ex.: player/, test/unit/)")}

## Arquivos protegidos autorizados
- (nenhum)

## Estado
(atualizado no fim: o que está feito e o que falta)

## Decisões propostas
- (nenhuma; cada uma em decisoes/<titulo>.md nesta pasta, sem número)

## Validar jogando
- (atualizado no fim)
`;
}

/** Confere o que precisa valer antes de criar qualquer branch. */
function checkPreconditions() {
    if (currentRole(root) !== "colaborador") {
        fail("esta máquina não está no papel colaborador (rode /configurar ou: node scripts/configurar.mjs --papel colaborador). O dono cria branch só quando quer testar algo à parte, pela regra de Git do AGENTS.md.");
    }
    if (!git(["remote"], root).split(/\s+/).includes("upstream")) {
        fail("falta o remoto upstream (o repositório original). Rode: node scripts/configurar.mjs --upstream <url-do-repositorio-original>");
    }
    // Compara conteúdo (git diff), não o git status: arquivos que o Godot regrava com outro final
    // de linha aparecem no status sem nenhuma mudança real.
    if (run("git", ["diff", "--quiet", "HEAD"], { cwd: root }).status !== 0) {
        fail("há mudanças sem commit. Termine ou guarde o trabalho atual antes de começar outra contribuição.");
    }
}

/** Cria a branch a partir de upstream/main e escreve a missão (se ainda não existir). */
function createBranch(branch, mission) {
    if (git(["rev-parse", "--verify", "--quiet", `refs/heads/${branch}`], root) !== "") {
        fail(`a branch ${branch} já existe nesta máquina. Para continuar nela: git switch ${branch}`);
    }
    const fetched = run("git", ["fetch", "upstream"], { cwd: root });
    if (fetched.status !== 0) {
        fail(`não consegui buscar o repositório original (git fetch upstream):\n${fetched.output.trim()}`);
    }
    const switched = run("git", ["switch", "--no-track", "-c", branch, "upstream/main"], { cwd: root });
    if (switched.status !== 0) {
        fail(`não consegui criar a branch:\n${switched.output.trim()}`);
    }
    const dir = join(root, branchDir(branch));
    mkdirSync(dir, { recursive: true });
    const missionFile = join(dir, "missao.md");
    if (!existsSync(missionFile)) {
        writeFileSync(missionFile, mission, "utf8");
    }
    console.log(`OK: branch ${branch} criada a partir de upstream/main (${git(["rev-parse", "--short", "upstream/main"], root)})`);
    return missionFile;
}

const TYPES = [
    { value: "feat", label: "feat     mecânica, cena ou conteúdo novo" },
    { value: "fix", label: "fix      correção de bug" },
    { value: "refactor", label: "refactor reorganiza o código sem mudar o comportamento" },
    { value: "perf", label: "perf     desempenho" },
    { value: "test", label: "test     só testes" },
    { value: "docs", label: "docs     só documentação" },
    { value: "assets", label: "assets   arte, som, fontes" },
    { value: "chore", label: "chore    configuração do projeto" },
];

/** Modo sem agente: pergunta tudo no terminal e deixa a branch pronta, com a missão no commit. */
async function interactive() {
    checkPreconditions();
    console.log("Nova contribuição. Uma branch tem um único propósito: se forem duas coisas, faça duas branches.\n");
    const type = await choose("Que tipo de mudança é?", TYPES);
    let branch = "";
    for (;;) {
        const description = await askRequired("Descreva a mudança em poucas palavras (ex.: corrige pulo duplo)");
        branch = await ask("Nome da branch", `${type}/${slug(description)}`.slice(0, 50).replace(/-+$/, ""));
        const error = branchNameError(branch);
        if (error === "") {
            break;
        }
        console.log(`  Nome inválido: ${error}`);
    }
    const goal = await askRequired("\nObjetivo: o que muda para quem joga ou para o projeto (uma ou duas frases)");
    const includes = await askList("\nO que esta branch entrega");
    const excludes = await askList("\nO que fica de fora, mesmo que pareça relacionado");
    const folders = await askList("\nPastas do projeto que você espera alterar (ex.: player/, test/unit/)");

    console.log(`\nBranch: ${branch} (commits aceitos: ${ALLOWED_COMMITS[type].join(", ")})`);
    console.log(`Objetivo: ${goal}`);
    if (!(await confirm("Criar a branch?"))) {
        fail("cancelado; nada foi criado.");
    }
    const missionFile = createBranch(branch, missionText(branch, { goal, includes, excludes, folders }));
    run("git", ["add", missionFile], { cwd: root });
    const committed = run("git", ["commit", "-m", `docs(colaboracao): registra a missão da branch ${branch}`], { cwd: root });
    if (committed.status !== 0) {
        fail(`a branch foi criada, mas o commit da missão falhou:\n${committed.output.trim()}\nConfira a identidade do git (node scripts/configurar.mjs) e faça o commit de ${branchDir(branch)}/missao.md.`);
    }
    console.log(`OK: missão registrada em ${branchDir(branch)}/missao.md`);

    // Branches antigas já integradas no original: só sugere, nunca apaga sozinho.
    const merged = git(["branch", "--merged", "upstream/main", "--format=%(refname:short)"], root)
        .split(/\r?\n/)
        .filter((name) => name !== "" && name !== "main" && name !== branch);
    if (merged.length > 0) {
        console.log("\nBranches suas já integradas no projeto original (pode apagar):");
        merged.forEach((name) => console.log(`  git branch -d ${name}   e   git push origin --delete ${name}`));
    }
    console.log("\nPronto. Trabalhe no Godot, faça commits pelo caminho e, ao terminar, rode: node scripts/fim-colaborador.mjs");
    closeInput();
}

const args = process.argv.slice(2);
if (args.length === 0) {
    await interactive();
} else {
    const branchIndex = args.indexOf("--branch");
    const branch = branchIndex >= 0 ? (args[branchIndex + 1] ?? "") : "";
    if (branch === "") {
        fail("informe a branch: node scripts/colaborar.mjs --branch <tipo>/<descricao> (ou rode sem argumentos para o modo guiado)");
    }
    const nameError = branchNameError(branch);
    if (nameError) {
        fail(`nome '${branch}' inválido: ${nameError}`);
    }
    checkPreconditions();
    createBranch(branch, missionText(branch));
    console.log(`OK: missão em ${branchDir(branch)}/missao.md — preencha antes do primeiro commit`);
    closeInput();
}
