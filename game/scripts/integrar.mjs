// Análise de uma branch recebida antes de integrá-la (fluxo integrar). Só lê o git: não faz
// checkout nem executa nada da branch, porque o código dela ainda não foi revisto.
// Uso: node scripts/integrar.mjs --analisar <ref> [--base main]
//   <ref> é a branch local buscada do pull request (ex.: pr/42).
import { projectRoot as root } from "./lib/common.mjs";
import { ALLOWED_COMMITS, COMMIT_PATTERN, branchNameError, git } from "./lib/collab.mjs";

const args = process.argv.slice(2);
const refIndex = args.indexOf("--analisar");
const ref = refIndex >= 0 ? args[refIndex + 1] ?? "" : "";
const baseIndex = args.indexOf("--base");
const base = baseIndex >= 0 ? args[baseIndex + 1] : "main";
if (ref === "") {
    console.log("Uso: node scripts/integrar.mjs --analisar <ref> [--base main]");
    process.exit(1);
}
const mergeBase = git(["merge-base", base, ref], root);
if (mergeBase === "") {
    console.log(`ERRO: não achei a base comum entre ${base} e ${ref}.`);
    process.exit(1);
}

const prefix = git(["rev-parse", "--show-prefix"], root);
const top = git(["rev-parse", "--show-toplevel"], root);
const show = (path) => git(["show", `${ref}:${path}`], top);
const changed = git(["-c", "core.quotepath=off", "diff", "--name-status", mergeBase, ref], top)
    .split(/\r?\n/)
    .filter(Boolean)
    .map((line) => {
        const [status, ...paths] = line.split("\t");
        return { status: status[0], path: paths.at(-1) };
    });

// Classificação. "Infraestrutura" roda na máquina de quem integra (check, hooks, editor, MCP).
const INFRA = /^(scripts\/|\.claude\/|\.gemini\/|\.agents\/|addons\/|\.mcp\.json$|project\.godot$|AGENTS\.md$|CLAUDE\.md$|GEMINI\.md$|requirements\.txt$|\.gitignore$|\.editorconfig$)/;
const SHARED_MEMORY = /^(docs\/status\.md$|docs\/decisoes\/)/;
const SENSITIVE = /OS\.(execute|execute_with_pipe|create_process|create_instance|shell_open|shell_show_in_file_manager|kill|move_to_trash)\b|HTTPRequest|HTTPClient|StreamPeerTCP|TCPServer|PacketPeerUDP|WebSocketPeer|ENetMultiplayerPeer|JavaScriptBridge|(FileAccess|DirAccess)\.\w+\(\s*"(?!res:\/\/|user:\/\/)/;
const groups = { infra: [], memory: [], branch: [], docs: [], content: [] };
const toolScripts = [];
const sensitive = [];
let missionPath = "";
for (const file of changed) {
    const inProject = file.path.startsWith(prefix);
    const path = inProject ? file.path.slice(prefix.length) : `../${file.path}`;
    const entry = `${file.status} ${path}`;
    if (!inProject) {
        (file.path.startsWith("notes/") ? groups.docs : groups.infra).push(entry);
    } else if (INFRA.test(path)) {
        groups.infra.push(entry);
    } else if (SHARED_MEMORY.test(path)) {
        groups.memory.push(entry);
    } else if (path.startsWith("docs/branches/")) {
        groups.branch.push(entry);
        if (path.endsWith("/missao.md") && file.status !== "D") {
            missionPath = file.path;
        }
    } else if (path.startsWith("docs/")) {
        groups.docs.push(entry);
    } else {
        groups.content.push(entry);
    }
    // Scripts @tool rodam dentro do editor assim que o projeto é aberto.
    if (inProject && path.endsWith(".gd") && file.status !== "D" && /^@tool\b/m.test(show(file.path))) {
        toolScripts.push(path);
    }
    // APIs que executam programas, acessam a rede ou mexem em arquivos fora do projeto, nas
    // linhas adicionadas: num jogo, quase nunca são necessárias, e merecem justificativa.
    if (inProject && path.endsWith(".gd") && file.status !== "D") {
        const added = git(["diff", "-U0", mergeBase, ref, "--", file.path], top)
            .split(/\r?\n/)
            .filter((line) => line.startsWith("+") && !line.startsWith("+++"));
        for (const line of added) {
            if (SENSITIVE.test(line)) {
                sensitive.push(`${path}: ${line.slice(1).trim()}`);
            }
        }
    }
}

const branch = missionPath.replace(`${prefix}docs/branches/`, "").replace(/\/missao\.md$/, "");
const commits = git(["log", "--no-merges", "--format=%h %s", `${mergeBase}..${ref}`], top).split(/\r?\n/).filter(Boolean);
const allowed = ALLOWED_COMMITS[branch.split("/")[0]] ?? [];

const out = [];
const section = (title, items) => {
    out.push(`\n## ${title} (${items.length})`);
    items.forEach((item) => out.push(`  ${item}`));
};
out.push(`# Análise de ${ref} contra ${base} (base comum ${mergeBase.slice(0, 8)})`);
out.push(branch
    ? `Branch pela missão: ${branch}${branchNameError(branch) ? " — ATENÇÃO: nome fora do padrão" : ""}`
    : "ATENÇÃO: missão não encontrada (docs/branches/<branch>/missao.md); a branch não passou pelo /colaborar.");
section("Commits", commits.map((line) => {
    const type = line.split(" ").slice(1).join(" ").match(COMMIT_PATTERN)?.[1];
    const flag = !type ? "  <- fora do modelo" : branch && !allowed.includes(type) ? `  <- tipo não cabe em ${branch.split("/")[0]}/` : "";
    return `${line}${flag}`;
}));
section("ATENÇÃO: infraestrutura (roda na sua máquina; revise o diff abaixo antes de executar qualquer coisa)", groups.infra);
section("ATENÇÃO: scripts @tool (rodam no editor ao abrir o projeto)", toolScripts);
section("ATENÇÃO: APIs sensíveis em linhas novas (programas, rede, arquivos fora do projeto)", sensitive);
section("ATENÇÃO: memória compartilhada alterada (o colaborador não deveria)", groups.memory);
section("Pasta da branch (missão e decisões propostas)", groups.branch);
section("Documentação", groups.docs);
section("Código e conteúdo", groups.content);
if (missionPath) {
    out.push("\n## Missão");
    out.push(show(missionPath));
}
for (const entry of groups.infra) {
    const path = entry.slice(2).replace(/^\.\.\//, "");
    const full = entry.slice(2).startsWith("../") ? path : `${prefix}${path}`;
    out.push(`\n## Diff de infraestrutura: ${entry.slice(2)}`);
    out.push(git(["-c", "core.quotepath=off", "diff", mergeBase, ref, "--", full], top) || "(sem diff de texto)");
}
console.log(out.join("\n"));
