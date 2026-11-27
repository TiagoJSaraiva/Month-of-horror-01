// Diagnóstico e configuração desta máquina para trabalhar no projeto (fluxo configurar).
//
// Uso (a partir da raiz do projeto):
//   node scripts/configurar.mjs                      diagnóstico: o que está OK e o que falta
//   node scripts/configurar.mjs --godot <caminho>    grava GODOT_PATH no .env (cria a partir do .env.example)
//   node scripts/configurar.mjs --papel <dono|colaborador>
//   node scripts/configurar.mjs --upstream <url>     remoto do repositório original (colaborador)
// Instalar programas (Godot, Node, Python) não é feito aqui: o agente mostra o comando e pergunta.
import { copyFileSync, existsSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { isWindows, loadEnv, projectRoot as root, run } from "./lib/common.mjs";
import { currentRole, git } from "./lib/collab.mjs";
import { checkGodotVersion } from "./lib/godot-version.mjs";

const args = process.argv.slice(2);
const option = (name) => {
    const index = args.indexOf(name);
    return index >= 0 ? args[index + 1] : undefined;
};

function setEnvValue(key, value) {
    const envFile = join(root, ".env");
    if (!existsSync(envFile)) {
        copyFileSync(join(root, ".env.example"), envFile);
    }
    const text = readFileSync(envFile, "utf8");
    const line = `${key}=${value}`;
    const pattern = new RegExp(`^${key}=.*$`, "m");
    writeFileSync(envFile, pattern.test(text) ? text.replace(pattern, () => line) : `${text.trimEnd()}\n${line}\n`, "utf8");
}

if (option("--godot") !== undefined) {
    setEnvValue("GODOT_PATH", option("--godot"));
    console.log(`OK: GODOT_PATH gravado em .env`);
}
if (option("--papel") !== undefined) {
    const role = option("--papel");
    if (role !== "dono" && role !== "colaborador") {
        console.log("ERRO: papel deve ser dono ou colaborador.");
        process.exit(1);
    }
    git(["config", "projeto.papel", role]);
    console.log(`OK: papel desta máquina: ${role} (git config projeto.papel, fora do repositório)`);
}
if (option("--upstream") !== undefined) {
    const url = option("--upstream");
    const hasUpstream = git(["remote"]).split(/\s+/).includes("upstream");
    run("git", ["remote", hasUpstream ? "set-url" : "add", "upstream", url]);
    console.log(`OK: remoto upstream -> ${url}`);
}
if (args.length > 0) {
    process.exit(0);
}

// Diagnóstico
loadEnv();
const results = [];
const report = (status, item, detail) => results.push({ status, item, detail });

const nodeMajor = Number(process.versions.node.split(".")[0]);
report(nodeMajor >= 18 ? "OK" : "FALTA", "Node 18+", `encontrado ${process.versions.node}`);

const gitVersion = run("git", ["--version"]);
report(gitVersion.status === 0 ? "OK" : "FALTA", "Git", gitVersion.output.trim() || "não encontrado");
const userName = git(["config", "user.name"]);
const userEmail = git(["config", "user.email"]);
report(userName && userEmail ? "OK" : "FALTA", "Identidade do git", userName && userEmail ? `${userName} <${userEmail}>` : "defina git config --global user.name e user.email");

const pinned = readFileSync(join(root, "requirements.txt"), "utf8").match(/gdtoolkit==([\d.]+)/)?.[1];
const gdformat = run("gdformat", ["--version"]);
const installed = gdformat.output.match(/(\d+\.\d+\.\d+)/)?.[1];
if (gdformat.status !== 0 || !installed) {
    const command = isWindows ? "pip install -r requirements.txt" : `pipx install "$(grep '^gdtoolkit==' requirements.txt)" (ou: pip3 install --user --break-system-packages -r requirements.txt)`;
    report("FALTA", "gdtoolkit", `instale com: ${command}`);
} else {
    report(installed === pinned ? "OK" : "AVISO", "gdtoolkit", installed === pinned ? installed : `${installed} instalado; o projeto fixa ${pinned}`);
}

if (!existsSync(join(root, ".env"))) {
    report("FALTA", ".env", "crie com: node scripts/configurar.mjs --godot <caminho do executável do Godot>");
}
const version = checkGodotVersion(root);
report(version.ok ? "OK" : "FALTA", "Godot 4.7.x em GODOT_PATH", version.message.replace(/^(OK|ERRO|AVISO): /, ""));
if (!version.ok) {
    const candidates = godotCandidates();
    if (candidates.length > 0) {
        report("INFO", "Executáveis do Godot encontrados", candidates.join(" | "));
    }
}

const role = currentRole(root);
report(role ? "OK" : "FALTA", "Papel desta máquina", role || "defina com: node scripts/configurar.mjs --papel <dono|colaborador>");

const remotes = git(["remote"]).split(/\s+/).filter(Boolean);
const origin = git(["remote", "get-url", "origin"]);
report(origin ? "OK" : "FALTA", "Remoto origin", origin || "sem origin: clone o repositório (dono) ou o seu fork (colaborador)");
if (role === "colaborador") {
    const upstream = git(["remote", "get-url", "upstream"]);
    if (!remotes.includes("upstream")) {
        report("FALTA", "Remoto upstream (repositório original)", "defina com: node scripts/configurar.mjs --upstream <url do repositório original>");
    } else if (upstream === origin) {
        report("FALTA", "Remoto upstream (repositório original)", "upstream e origin apontam para o mesmo lugar; origin deve ser o seu fork");
    } else {
        report("OK", "Remoto upstream (repositório original)", upstream);
    }
}

for (const { status, item, detail } of results) {
    console.log(`${status}: ${item} — ${detail}`);
}
const missing = results.filter((result) => result.status === "FALTA").length;
console.log(missing === 0 ? "\nMáquina pronta." : `\n${missing} item(ns) faltando.`);
process.exit(missing === 0 ? 0 : 1);

/** Executáveis do Godot 4.7 em lugares comuns, para sugerir o GODOT_PATH. */
function godotCandidates() {
    const found = [];
    const look = (dir, test) => {
        try {
            for (const name of readdirSync(dir)) {
                if (test(name)) {
                    found.push(join(dir, name));
                }
            }
        } catch {
            // Pasta inexistente: nada a sugerir dela.
        }
    };
    if (isWindows) {
        look("C:\\Program Files (x86)\\Steam\\steamapps\\common\\Godot Engine", (name) => /^godot\.windows\..*\.exe$/i.test(name) && !/console/i.test(name));
        look(join(homedir(), "Downloads"), (name) => /^Godot_v4\.7.*\.exe$/i.test(name) && !/console/i.test(name));
        look("C:\\Godot", (name) => /^Godot_v4\.7.*\.exe$/i.test(name) && !/console/i.test(name));
    } else {
        for (const dir of [join(homedir(), "godot"), join(homedir(), "Downloads"), join(homedir(), ".local", "bin"), "/opt/godot"]) {
            look(dir, (name) => /^Godot_v4\.7.*(x86_64|arm64)$/.test(name));
        }
        look(join(homedir(), ".steam", "steam", "steamapps", "common", "Godot Engine"), (name) => /^godot\.(linuxbsd|x11)\./.test(name));
    }
    return found;
}
