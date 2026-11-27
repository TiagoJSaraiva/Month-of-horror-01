// Perguntas no terminal para os scripts que o colaborador roda sem agente de IA
// (colaborar.mjs sem argumentos e fim-colaborador.mjs). Só módulos nativos do Node.
// Lê linha a linha pelo iterador do readline, que funciona igual com teclado e com entrada
// redirecionada (o rl.question perde as linhas que chegam antes da pergunta).
import { createInterface } from "node:readline";

let lines = null;

function nextLine() {
    if (lines === null) {
        const rl = createInterface({ input: process.stdin, terminal: Boolean(process.stdin.isTTY) });
        lines = rl[Symbol.asyncIterator]();
    }
    return lines.next().then(({ value, done }) => (done ? "" : value.trim()));
}

/** Faz uma pergunta e devolve a resposta (sem espaços nas pontas). Vazia vira `fallback`. */
export async function ask(question, fallback = "") {
    const hint = fallback ? ` [${fallback}]` : "";
    process.stdout.write(`${question}${hint}: `);
    const answer = await nextLine();
    return answer === "" ? fallback : answer;
}

/** Pergunta até a resposta não ser vazia. */
export async function askRequired(question) {
    for (;;) {
        const answer = await ask(question);
        if (answer !== "") {
            return answer;
        }
        console.log("  (resposta obrigatória)");
    }
}

/** Lê vários itens, um por linha, até uma linha vazia. */
export async function askList(question) {
    console.log(`${question} (um por linha; linha vazia termina)`);
    const items = [];
    for (;;) {
        process.stdout.write("  - ");
        const item = await nextLine();
        if (item === "") {
            return items;
        }
        items.push(item);
    }
}

/** Pergunta sim/não. Enter vale `fallback`. */
export async function confirm(question, fallback = true) {
    const answer = (await ask(`${question} (${fallback ? "S/n" : "s/N"})`)).toLowerCase();
    if (answer === "") {
        return fallback;
    }
    return answer.startsWith("s") || answer.startsWith("y");
}

/** Escolha numa lista numerada; devolve o valor escolhido. */
export async function choose(question, options) {
    console.log(question);
    options.forEach(({ label }, index) => console.log(`  ${index + 1}. ${label}`));
    for (;;) {
        const answer = Number(await ask("Número"));
        if (Number.isInteger(answer) && answer >= 1 && answer <= options.length) {
            return options[answer - 1].value;
        }
        console.log(`  (escolha um número de 1 a ${options.length})`);
    }
}

/** Texto em kebab-case sem acento: "Corrige o pulo duplo!" -> "corrige-o-pulo-duplo". */
export function slug(text) {
    return text
        .normalize("NFD")
        .replace(/[̀-ͯ]/g, "")
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/^-+|-+$/g, "");
}

/** Encerra a leitura do teclado para o processo poder terminar. */
export function closeInput() {
    if (lines !== null) {
        process.stdin.destroy();
    }
}
