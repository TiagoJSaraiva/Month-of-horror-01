// Fim de uma contribuição para quem trabalha sem agente de IA (equivale ao /fim do colaborador).
// Uso (a partir da raiz do projeto): node scripts/fim-colaborador.mjs
//
// Passos: confere papel, branch e trabalho sem commit; atualiza a branch com a main original se
// ela não integrar limpa; roda o check completo; pergunta o estado da missão, o que validar
// jogando e as decisões propostas e faz o commit; envia a branch para o fork (nunca --force) e
// mostra o texto e o link do pull request. Pode ser rodado de novo quantas vezes precisar.
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { paint, projectRoot as root, run } from "./lib/common.mjs";
import { branchDir, branchNameError, currentBranch, currentRole, git } from "./lib/collab.mjs";
import { ask, askList, closeInput, confirm, slug } from "./lib/perguntar.mjs";

function fail(message) {
    console.log(paint("red", `\nPAROU: ${message}`));
    closeInput();
    process.exit(1);
}

function title(text) {
    console.log(paint("cyan", `\n== ${text} ==`));
}

/** Texto de uma seção "## Título" da missão (sem o título). */
function sectionBody(text, name) {
    const match = text.match(new RegExp(`(^|\\n)## ${name}\\r?\\n([\\s\\S]*?)(?=\\r?\\n## |$)`));
    return match ? match[2].trim() : "";
}

/** Troca o corpo de uma seção da missão, mantendo as outras. */
function replaceSection(text, name, body) {
    const pattern = new RegExp(`((?:^|\\n)## ${name}\\r?\\n)[\\s\\S]*?(?=\\r?\\n## |$)`);
    return pattern.test(text) ? text.replace(pattern, (_, head) => `${head}${body}\n`) : `${text.trimEnd()}\n\n## ${name}\n${body}\n`;
}

const isPlaceholder = (body) => body === "" || /^-?\s*\(/.test(body);
const bullets = (items) => items.map((item) => `- ${item}`).join("\n");

/** Dono e nome do repositório de uma URL do GitHub (https ou ssh), ou null. */
function githubRepo(url) {
    const match = url.match(/github\.com[:/]([^/]+)\/([^/]+?)(?:\.git)?\/?$/);
    return match ? { owner: match[1], repo: match[2] } : null;
}

// 1. Papel, branch e remotos
title("Branch e missão");
if (currentRole(root) !== "colaborador") {
    fail("esta máquina não está no papel colaborador. Rode: node scripts/configurar.mjs --papel colaborador");
}
const branch = currentBranch(root);
if (branch === "" || branch === "main") {
    fail("você está na main. Cada contribuição fica numa branch: rode node scripts/colaborar.mjs");
}
const nameError = branchNameError(branch);
if (nameError) {
    fail(`a branch '${branch}' está fora do padrão: ${nameError}`);
}
const remotes = git(["remote"], root).split(/\s+/);
if (!remotes.includes("upstream")) {
    fail("falta o remoto upstream. Rode: node scripts/configurar.mjs --upstream <url-do-repositorio-original>");
}
if (!remotes.includes("origin")) {
    fail("falta o remoto origin (o seu fork). Clone o seu fork ou rode: git remote add origin <url-do-seu-fork>");
}
const missionFile = join(root, branchDir(branch), "missao.md");
if (!existsSync(missionFile)) {
    fail(`missão ausente: ${branchDir(branch)}/missao.md. Toda branch nasce pelo node scripts/colaborar.mjs.`);
}
console.log(`Branch: ${branch}`);

// 2. Trabalho sem commit: o script não escolhe por você o que entra e com que mensagem.
const top = git(["rev-parse", "--show-toplevel"], root);
if (run("git", ["rev-parse", "--verify", "--quiet", "MERGE_HEAD"], { cwd: top }).status === 0) {
    console.log(git(["-c", "core.quotepath=off", "status", "--short"], top));
    fail("há um merge com a main original em andamento. Resolva os conflitos (arquivos marcados UU ou AA acima), rode git add <arquivos> e git commit --no-edit, e então rode este script de novo. Para desistir: git merge --abort");
}
const pending = git(["-c", "core.quotepath=off", "status", "--short"], top);
const hasDiff = run("git", ["diff", "--quiet", "HEAD"], { cwd: top }).status !== 0;
const untracked = git(["ls-files", "--others", "--exclude-standard"], top) !== "";
if (hasDiff || untracked) {
    console.log(pending);
    fail("há mudanças sem commit (lista acima). Faça o commit delas (veja 'Commits' no guia COLABORAR-SEM-IA-WINDOWS.md ou COLABORAR-SEM-IA-LINUX.md) ou descarte-as, e rode este script de novo.");
}
console.log("Sem mudanças pendentes.");

// 3. Main original: se ela avançou e não integra limpa com a branch, o merge é feito aqui.
title("Atualização com a main original");
const fetched = run("git", ["fetch", "upstream"], { cwd: root });
if (fetched.status !== 0) {
    fail(`não consegui buscar o repositório original (git fetch upstream):\n${fetched.output.trim()}`);
}
// merge-tree --write-tree simula o merge sem tocar nos arquivos: 0 = integra limpo, 1 = conflito.
// Outro código = git anterior à 2.38 (ex.: Ubuntu 22.04), sem essa opção: faz o merge direto.
const simulated = run("git", ["merge-tree", "--write-tree", "upstream/main", "HEAD"], { cwd: root }).status;
if (run("git", ["merge-base", "--is-ancestor", "upstream/main", "HEAD"], { cwd: root }).status === 0) {
    console.log("A branch já contém a main original.");
} else if (simulated === 0) {
    console.log("A main original avançou, mas integra sem conflito com a branch: nada a fazer.");
} else {
    console.log(simulated === 1
        ? "A main original avançou e conflita com a branch. Trazendo as mudanças dela para cá..."
        : "A main original avançou (este git é anterior à 2.38 e não simula o merge). Trazendo as mudanças dela para cá...");
    const merged = run("git", ["merge", "upstream/main", "-m", "merge: atualiza a branch com a main original"], { cwd: root });
    if (merged.status !== 0) {
        console.log(merged.output.trim());
        fail([
            "o merge parou em conflito. Para resolver:",
            "  1. abra os arquivos marcados como conflito (no VS Code: aba Source Control, 'Merge Changes');",
            "  2. em cada trecho, fique com o que a sua missão precisa sem desfazer o que veio da main;",
            "  3. git add <arquivos>  e depois  git commit --no-edit",
            "  4. rode este script de novo.",
            "Para desistir e voltar como estava: git merge --abort",
        ].join("\n"));
    }
    console.log("Merge feito sem conflito.");
}

// 4. Check completo
title("Check completo");
const check = run(process.execPath, ["scripts/check.mjs"], { cwd: root, inherit: true });
if (check.status !== 0) {
    fail("o check falhou (motivo acima). Corrija, faça o commit da correção e rode este script de novo. Sem check passando não há envio.");
}
// O import do check gera os .uid de scripts novos: se apareceu algum, ele precisa ir no commit.
if (run("git", ["diff", "--quiet", "HEAD"], { cwd: top }).status !== 0 || git(["ls-files", "--others", "--exclude-standard"], top) !== "") {
    console.log(git(["-c", "core.quotepath=off", "status", "--short"], top));
    fail(`o check gerou ou alterou arquivos (lista acima; normalmente .uid de scripts novos). Faça o commit deles com o tipo da sua branch (ex.: git add . e git commit -m \"${branch.split("/")[0]}: adiciona os uid dos scripts novos\") e rode este script de novo.`);
}

// 5. Missão: estado, validar jogando e decisões propostas
title("Missão");
let mission = readFileSync(missionFile, "utf8");
const currentState = sectionBody(mission, "Estado");
const currentPlaytest = sectionBody(mission, "Validar jogando");
if (!isPlaceholder(currentState)) {
    console.log(`Estado registrado:\n${currentState}\n`);
}
let state = await askList("Estado: o que ficou feito e o que ainda falta" + (isPlaceholder(currentState) ? "" : " (vazio mantém o registrado)"));
while (state.length === 0 && isPlaceholder(currentState)) {
    console.log("  (descreva o estado em pelo menos um item: é o que o dono lê primeiro)");
    state = await askList("Estado");
}
if (state.length > 0) {
    mission = replaceSection(mission, "Estado", bullets(state));
}
if (!isPlaceholder(currentPlaytest)) {
    console.log(`\nValidar jogando, registrado:\n${currentPlaytest}`);
}
const playtest = await askList("\nO que o dono deve testar jogando (sensação, visual, um passo a passo)" + (isPlaceholder(currentPlaytest) ? "" : " (vazio mantém)"));
if (playtest.length > 0) {
    mission = replaceSection(mission, "Validar jogando", bullets(playtest));
}

console.log("\nDecisões propostas: escolhas de projeto que o dono deveria registrar (ex.: 'inimigos usam máquina de estados'). Nenhuma? Só Enter.");
const decisions = [];
const decisionDir = join(root, branchDir(branch), "decisoes");
for (;;) {
    const name = await ask("Título da decisão (vazio termina)");
    if (name === "") {
        break;
    }
    const context = await ask("  Contexto: que problema levou a ela");
    const choice = await ask("  Escolha: o que foi decidido");
    const alternatives = await ask("  Alternativas descartadas (opcional)");
    mkdirSync(decisionDir, { recursive: true });
    const file = `${slug(name)}.md`;
    writeFileSync(join(decisionDir, file), `# ${name}

- **Status**: proposta pela branch \`${branch}\` (o número é dado na integração)

## Contexto
${context || "(não informado)"}

## Decisão
${choice || "(não informada)"}

## Alternativas descartadas
${alternatives || "(nenhuma registrada)"}
`, "utf8");
    decisions.push(`\`decisoes/${file}\`: ${name}`);
}
if (decisions.length > 0) {
    const registered = sectionBody(mission, "Decisões propostas");
    const kept = isPlaceholder(registered) ? "" : `${registered}\n`;
    mission = replaceSection(mission, "Decisões propostas", `${kept}${bullets(decisions)}`);
}

writeFileSync(missionFile, mission, "utf8");
run("git", ["add", branchDir(branch)], { cwd: root });
if (run("git", ["diff", "--cached", "--quiet"], { cwd: root }).status !== 0) {
    const committed = run("git", ["commit", "-m", "docs(colaboracao): atualiza o estado da missão"], { cwd: root });
    if (committed.status !== 0) {
        fail(`não consegui fazer o commit da missão:\n${committed.output.trim()}`);
    }
    console.log("OK: missão atualizada (commit docs(colaboracao): atualiza o estado da missão)");
} else {
    console.log("Missão sem mudanças.");
}

// 6. O que vai ser enviado
title("Commits da branch");
const commits = git(["log", "--oneline", "--no-decorate", "upstream/main..HEAD"], root);
console.log(commits || "(nenhum)");
const coauthored = git(["log", "--format=%h", "--grep=Co-Authored-By", "-i", "upstream/main..HEAD"], root);
if (coauthored !== "") {
    console.log(paint("yellow", `AVISO: commit com rodapé Co-Authored-By (${coauthored.split(/\s+/).join(", ")}); o projeto não usa esse rodapé.`));
}

// 7. Envio para o fork
title("Envio para o seu fork");
if (!(await confirm(`Enviar a branch ${branch} para o seu fork (origin)?`))) {
    fail("envio cancelado. Os commits continuam só nesta máquina; rode o script de novo quando quiser enviar.");
}
const pushed = run("git", ["push", "-u", "origin", branch], { cwd: root });
console.log(pushed.output.trim());
if (pushed.status !== 0) {
    fail("o envio foi recusado. Se a branch do fork tem commits que esta máquina não tem (enviados de outro computador), rode git pull origin " + branch + " e este script de novo. Nunca use --force.");
}

// 8. Pull request
title("Pull request");
mission = readFileSync(missionFile, "utf8");
const type = branch.split("/")[0];
const defaultTitle = `${type}: ${branch.split("/")[1].replaceAll("-", " ")}`;
const prTitle = await ask("Título do pull request no modelo <tipo>(<escopo>): <resumo>", defaultTitle);
const section = (name) => sectionBody(mission, name) || "-";
const body = `## Objetivo
${section("Objetivo")}

## O que entrou
${git(["log", "--oneline", "--no-decorate", "--no-merges", "upstream/main..HEAD"], root).split(/\r?\n/).filter(Boolean).map((line) => `- ${line}`).join("\n")}

## Estado
${section("Estado")}

## Decisões propostas
${section("Decisões propostas")}

## Validar jogando
${section("Validar jogando")}
`;
const prFile = join(top, ".git", "PULL_REQUEST.md");
writeFileSync(prFile, `${prTitle}\n\n${body}`, "utf8");
console.log(`\nTítulo:\n${prTitle}\n\nDescrição:\n${body}`);
console.log(paint("gray", `(o mesmo texto ficou salvo em ${prFile}, fora do repositório)`));

const fork = githubRepo(git(["remote", "get-url", "origin"], root));
const upstream = githubRepo(git(["remote", "get-url", "upstream"], root));
if (fork && upstream) {
    const head = fork.repo === upstream.repo ? `${fork.owner}:${branch}` : `${fork.owner}:${fork.repo}:${branch}`;
    console.log(`\nAbra o pull request (destino: main do repositório original), cole o título e a descrição:`);
    console.log(`https://github.com/${upstream.owner}/${upstream.repo}/compare/main...${head}?expand=1`);
} else {
    console.log("\nAbra o pull request no GitHub: na página do seu fork aparece 'Compare & pull request' para esta branch; o destino é a main do repositório original.");
}
console.log(paint("green", "\nFIM OK. Depois de abrir o pull request, o CI do GitHub roda o check e o dono revisa."));
console.log("Mais trabalho nesta mesma missão? Continue na branch e rode este script de novo: o pull request se atualiza sozinho.");
closeInput();
