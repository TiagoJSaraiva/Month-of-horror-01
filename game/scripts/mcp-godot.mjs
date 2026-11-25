// Inicia o servidor MCP do Godot (@coding-solo/godot-mcp) com o GODOT_PATH do .env.
// O .mcp.json aponta para este script porque o mesmo arquivo precisa servir ao Windows, onde o
// npx é um .cmd e exige shell, e ao Linux. O MCP conversa pela entrada e saída padrão, que
// passam direto para o processo filho.
import { spawn } from "node:child_process";
import { isWindows, loadEnv, projectRoot } from "./lib/common.mjs";

loadEnv();
const child = spawn("npx", ["-y", "@coding-solo/godot-mcp@0.1.1"], {
    cwd: projectRoot,
    env: process.env,
    shell: isWindows,
    stdio: "inherit",
});
for (const signal of ["SIGINT", "SIGTERM"]) {
    process.on(signal, () => child.kill(signal));
}
child.on("exit", (code) => process.exit(code ?? 1));
