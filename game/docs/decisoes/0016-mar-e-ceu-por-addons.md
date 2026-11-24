# 0016 — Mar e céu por addons, como solução provisória

- **Data**: 2026-11
- **Status**: aceita, provisória

## Contexto
Até o M8, o céu era um `ProceduralSkyMaterial` com paletas próprias e uma luz de lua, e o mar era um plano escuro. O escopo pede lua e estrelas que se movem, céu que fecha na tempestade e clareia no amanhecer, e mar animado. O desenvolvedor prevê mudar toda a estética do jogo depois do MVP, então mar e céu são solução temporária e devem custar pouco.

## Decisão
- O céu vem do addon **Sky3D** (MIT): sol, lua com fases, estrelas, nuvens e neblina. O relógio próprio do addon fica desligado; o horário vem do `NightClock` (23:00 a 06:00), e a tempestade mexe nas nuvens e na neblina.
- O mar vem do addon **Boujie Water Shader** (MIT): ondas de Gerstner num shader, sem compute shader. A física da água continua sendo o plano de colisão do `Water` (camada `water`).
- Os addons ficam em `addons/` sem modificações, registrados em `docs/assets.md`. A integração fica em scripts do jogo.
- Os plugins de editor dos addons não precisam estar ativos: as classes funcionam em tempo de execução.

## Alternativas descartadas
- **Shaders próprios para mar e céu**: mais controle e mais coerentes com o retrô, mas exigem mais tempo para algo que deve mudar.
- **GodotOceanWaves**: oceano FFT com compute shaders, experimental e sem formato de addon.

## Consequências
- O céu antigo (`SkyCycle`, `MoonArc`, `SkyPalette` e `SkyRules`) sai do projeto; o histórico do git o guarda.
- O mapa de estrelas é CC BY 4.0: os créditos do jogo precisam citar o autor (ver `docs/assets.md`).
- A boia segue o plano de colisão, e não a onda visível; ondas baixas mantêm a diferença pequena.
- Os addons não declaram suporte ao Godot 4.7; uma atualização do Godot pode exigir atualizar os addons.
- Trocar a estética depois significa remover os dois addons e a integração (`SkyDriver` e a cena do oceano), sem mexer na lógica do jogo.
