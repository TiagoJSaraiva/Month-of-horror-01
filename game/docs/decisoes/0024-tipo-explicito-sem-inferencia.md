# 0024 — Tipo sempre explícito, sem inferência por `:=`

- **Data**: 2026-11
- **Status**: aceita (amplia 0001; vem da decisão 0012 do `godot-template`)

## Contexto
A 0001 exige tipagem estática, e a convenção aceitava `:=` só com literal ou construtor à direita. A própria convenção se contradizia nos exemplos (`:= MAX_JUMPS`, `:= body as Enemy`), e nada a verificava: o projeto tinha 307 linhas com `:=` (105 no jogo e 202 nos testes), a maioria com `as`, chamada de função ou literal numérico.

`:=` não enfraquece a tipagem: o tipo fica fixo na compilação. O problema é a clareza e uma armadilha:
- com constante ou chamada de função à direita, o tipo só aparece para quem lê procurando a declaração, e muda sozinho se o retorno da função mudar;
- `var speed := 200` vira `int`, e um `speed = 150.5` posterior compila e trunca para `150`.

O desenvolvedor lê e revisa todo o código e quer tipagem explícita e forte em todo o projeto.

## Decisão
- Nenhuma inferência de tipo: variáveis (locais, membros, `@onready`, lambdas), constantes, parâmetros com valor padrão e iteradores de `for` têm o tipo escrito à esquerda, inclusive em `test/`.
- `project.godot` liga `gdscript/warnings/inferred_declaration=2` (aviso tratado como erro), ao lado do `untyped_declaration=2`. O parse do check reprova qualquer `:=` ou iterador de `for` inferido, e o editor marca o erro ao digitar. Os addons ficam de fora (`gdscript/warnings/exclude_addons`).
- A migração trocou todas as ocorrências sem mudar comportamento, um commit por sistema.

## Alternativas descartadas
- **`:=` só com o tipo escrito à direita (construtor ou `as`)**: o Godot não tem um aviso tão específico, e a regra dependeria só da revisão. A regra antiga, também só escrita, não era seguida.
- **`:=` também com constante**: mantém o tipo escondido em vários casos.

## Consequências
Código mais verboso onde o tipo já aparece à direita (`var timer: Timer = Timer.new()`), em troca de todo tipo visível na declaração e verificado pelo check. Mudar uma declaração dentro de uma função conta como função alterada para a revisão do `##` (decisão 0022).
