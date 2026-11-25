// Pipeline de verificação: versão do Godot, gdtoolkit, formatação, lint, documentação, parse e
// testes. Para na primeira etapa que falhar e sai com código 1.
//
// Uso (a partir da raiz do projeto, em Windows ou Linux):
//   node scripts/check.mjs               completo: antes de concluir uma tarefa
//   node scripts/check.mjs --fix --fast  formata e roda o check rápido (só test/unit)
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { chunks, isWindows, listGdFiles, loadEnv, paint, projectRoot as root, run } from "./lib/common.mjs";
import { checkDocReview, checkDocs } from "./lib/docs.mjs";
import { checkGodotVersion } from "./lib/godot-version.mjs";

const args = new Set(process.argv.slice(2));
for (const arg of args) {
    if (arg !== "--fast" && arg !== "--fix") {
        console.log(`Argumento desconhecido: ${arg}. Use --fast e/ou --fix.`);
        process.exit(1);
    }
}
const fast = args.has("--fast");
const fix = args.has("--fix");

/** Roda uma etapa: `action` devolve true (passou) ou false (falhou e encerra o check). */
function step(name, action) {
    console.log(paint("cyan", `\n== ${name} ==`));
    if (!action()) {
        console.log(paint("red", `FALHOU: ${name}`));
        process.exit(1);
    }
    console.log(paint("green", `OK: ${name}`));
}

/** Roda um programa mostrando a saída só quando ele falha. */
function quiet(command, commandArgs) {
    const { status, output, error } = run(command, commandArgs);
    if (error || status !== 0) {
        console.log(output.trim() || String(error));
        return false;
    }
    return true;
}

loadEnv();
const gdFiles = listGdFiles(root);
const config = JSON.parse(readFileSync(join(root, "scripts", "check.config.json"), "utf8"));

// 1. Versão do Godot (também valida o GODOT_PATH)
step("Versão do Godot", () => {
    const { ok, message } = checkGodotVersion(root);
    console.log(message);
    return ok;
});

// 2. gdtoolkit instalado. A versão fica fixada em requirements.txt porque versões diferentes do
//    gdformat podem formatar diferente, e colaboradores reformatariam o código um do outro.
step("gdtoolkit (gdformat e gdlint)", () => {
    const pinned = readFileSync(join(root, "requirements.txt"), "utf8").match(/gdtoolkit==([\d.]+)/)?.[1];
    for (const tool of ["gdformat", "gdlint"]) {
        const { status, output, error } = run(tool, ["--version"]);
        if (error || status !== 0) {
            console.log(paint("yellow", `${tool} não encontrado. Instale com: pip install -r requirements.txt (e confira se a pasta de scripts do Python está no PATH).`));
            return false;
        }
        const installed = output.match(/(\d+\.\d+\.\d+)/)?.[1];
        if (pinned && installed !== pinned) {
            console.log(paint("yellow", `AVISO: ${tool} ${installed} instalado, mas o projeto fixa ${pinned}. Rode pip install -r requirements.txt.`));
        }
    }
    return true;
});

// 3. Formatação e 4. lint
if (gdFiles.length > 0) {
    if (fix) {
        step("Aplicar formatação (gdformat)", () => chunks(gdFiles).every((files) => quiet("gdformat", files)));
    }
    step("Formatação (gdformat --check)", () => chunks(gdFiles).every((files) => quiet("gdformat", ["--check", ...files])));
    step("Lint (gdlint)", () => chunks(gdFiles).every((files) => quiet("gdlint", files)));
} else {
    console.log(paint("gray", "\n(sem scripts .gd do projeto: formatação e lint pulados)"));
}

// 5. Toda função do jogo com ## logo acima, revisado quando a função mudou
//    (docs/decisoes/*-documentacao-em-toda-funcao.md). Projeto que ainda não migrou as funções
//    existentes desliga a etapa em scripts/check.config.json.
if (config.documentacaoDasFuncoes) {
    step("Documentação das funções", () => {
        const { ok, lines } = checkDocs(root);
        lines.forEach((line) => console.log(line));
        return ok;
    });
    step("Revisão do ## das funções alteradas", () => {
        const { ok, lines } = checkDocReview(root);
        lines.forEach((line) => console.log(line));
        return ok;
    });
} else {
    console.log(paint("gray", "\n(documentação das funções desligada em scripts/check.config.json)"));
}

// 6. Parse de todos os scripts (docs/decisoes/*-parse-unico-com-autoloads.md).
//    O --import só atualiza cache e .uid: ele não compila scripts que nenhuma cena usa.
//    Por isso scripts/parse_check.gd compila cada script numa execução headless.
//    Não é --check-only: nesse modo o Godot não registra os autoloads e todo script que
//    usa um deles falharia com "Identifier not found".
//    A busca no texto cobre versões do Godot que não sinalizam o erro no exit code.
//    Não amplie o regex para "ERROR" genérico: há ruído conhecido (Remote Debugger).
step("Parse dos scripts (Godot headless)", () => {
    const godot = process.env.GODOT_PATH;
    const imported = run(godot, ["--headless", "--path", root, "--import"]);
    if (imported.output.trim() === "") {
        console.log(paint("yellow", "Saída vazia: o Godot não devolveu nada ao terminal."));
        return false;
    }
    // scripts/ tem .gdignore: o que está lá não é res:// e não entra no parse.
    const resPaths = gdFiles.filter((path) => !path.startsWith("scripts/")).map((path) => `res://${path}`);
    const parser = join(root, "scripts", "parse_check.gd");
    for (const batch of chunks(resPaths, 250)) {
        const { status, output } = run(godot, ["--headless", "--path", root, "--script", parser, "--", ...batch]);
        if (status !== 0 || /SCRIPT ERROR|Parse Error|Failed to load script/.test(output)) {
            console.log(output);
            return false;
        }
        output.split(/\r?\n/).filter((line) => line.startsWith("Scripts compilados")).forEach((line) => console.log(line));
    }
    return true;
});

// 7. Testes (gdUnit4). Os executores do addon leem o Godot em GODOT_BIN e rodam a partir da
//    raiz do projeto. runtest.sh não é versionado como executável, por isso via bash.
const testDir = fast ? "test/unit" : "test";
if (!existsSync(join(root, testDir))) {
    console.log(paint("red", `\nFALHOU: pasta ${testDir} não existe`));
    process.exit(1);
}
step(`Testes gdUnit4 (${testDir})`, () => {
    const env = { ...process.env, GODOT_BIN: process.env.GODOT_PATH };
    const testArgs = ["-a", `res://${testDir}`];
    if (isWindows) {
        return run("addons\\gdUnit4\\runtest.cmd", testArgs, { env, shell: true, inherit: true }).status === 0;
    }
    // O executor abre o Godot com janela: sem --headless, porque sem tela o Godot não entrega
    // eventos de input e os testes de cena com interação falham. Sem tela (CI, SSH), usa uma
    // tela virtual (Xvfb).
    const runner = ["bash", "addons/gdUnit4/runtest.sh", ...testArgs];
    if (hasLinuxDisplay()) {
        return run(runner[0], runner.slice(1), { env, inherit: true }).status === 0;
    }
    if (run("sh", ["-c", "command -v xvfb-run"]).status === 0) {
        console.log(paint("gray", "(sem tela: testes numa tela virtual, via xvfb-run)"));
        return run("xvfb-run", ["-a", ...runner], { env, inherit: true }).status === 0;
    }
    console.log(paint("yellow", "Sem tela gráfica para os testes do gdUnit4. Rode numa sessão gráfica ou instale o Xvfb (Debian/Ubuntu: sudo apt install xvfb)."));
    return false;
});

/** Diz se há uma tela X11 ou Wayland utilizável (a variável sozinha não basta: o socket pode ter sumido). */
function hasLinuxDisplay() {
    const display = process.env.DISPLAY?.match(/^[^:]*:(\d+)/)?.[1];
    if (display !== undefined && (existsSync(`/tmp/.X11-unix/X${display}`) || !process.env.DISPLAY.startsWith(":"))) {
        return true;
    }
    const wayland = process.env.WAYLAND_DISPLAY;
    if (wayland) {
        const socket = wayland.startsWith("/") ? wayland : join(process.env.XDG_RUNTIME_DIR ?? "", wayland);
        return existsSync(socket);
    }
    return false;
}

console.log(paint("green", "\nCHECK OK"));
process.exit(0);
