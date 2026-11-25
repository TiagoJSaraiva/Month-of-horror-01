// Contexto de início de sessão: versão do Godot e papel desta máquina na colaboração.
// Roda no hook SessionStart do Claude Code (a saída entra no contexto do agente) e no fluxo inicio.
// Uso: node scripts/inicio-sessao.mjs   (exit 1 só quando a versão do Godot está errada)
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { loadEnv, projectRoot } from "./lib/common.mjs";
import { baseRef, branchDir, currentBranch, currentRole, missionFirstLine } from "./lib/collab.mjs";
import { checkGodotVersion } from "./lib/godot-version.mjs";

loadEnv();
const version = checkGodotVersion();
console.log(version.message);

const role = currentRole();
const branch = currentBranch();
if (role === "") {
    console.log("AVISO: papel desta máquina não configurado. Rode /configurar antes de trabalhar.");
} else if (role === "colaborador") {
    if (branch === "" || branch === "main") {
        console.log("Modo colaborador, mas na main: não altere nada aqui. Crie a branch da tarefa com /colaborar.");
    } else {
        const missionPath = join(projectRoot, branchDir(branch), "missao.md");
        const mission = existsSync(missionPath) ? readFileSync(missionPath, "utf8") : "";
        const goal = mission ? missionFirstLine(mission, "Objetivo") : "(missão ausente: rode /colaborar)";
        console.log(`Modo colaborador | branch: ${branch} | base: ${baseRef()}`);
        console.log(`Missão: ${goal}`);
        console.log(`Leia ${branchDir(branch)}/missao.md antes de qualquer tarefa; o que não couber na missão vai para outra branch.`);
    }
} else {
    console.log(`Modo dono | branch: ${branch || "(HEAD solto)"}`);
}
process.exit(version.ok ? 0 : 1);
