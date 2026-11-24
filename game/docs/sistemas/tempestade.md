# Tempestade

## Propósito
Uma ameaça de tempo limitado numa noite: o barco balança forte, o céu fecha, a manutenção falha mais e aparecem os voadores.

## Componentes
- `night/storm_settings.gd` + `night/storm_settings.tres`: `StormSettings` (Resource), os ajustes do sorteio e do ritmo. A curva de dificuldade troca a chance e a duração a cada noite, numa cópia.
- `night/storm_plan.gd`: `StormPlan` (`RefCounted`), a tempestade sorteada para a noite: `has_storm`, `start_seconds` e `duration_seconds`.
- `night/storm_rules.gd`: `StormRules`, regras puras do sorteio (`plan`) e da intensidade ao longo do tempo (`strength`).
- `night/storm.gd`: `Storm`, nó da `Night`, ligado ao `NightClock`, ao `StormSettings` e ao `HudEvents` por `@export`. A `Night` chama `roll(night_number, rng)` no `_ready`. Emite `started`, `ended` e `strength_changed(strength)`.
- `night/sky_palettes/storm.tres`: paleta da tempestade (cinza-esverdeada, luz ambiente fraca, neblina mais densa).
- `night/storm_weather.tscn` / `storm_weather.gd`: `StormWeather`, nó da `Night` com o clima:
  - `Rain`: `GPUParticles3D` 9 m acima do barco, cobrindo 24×32 m, até 2500 gotas inclinadas pelo vento (+X), com a quantidade (`amount_ratio`) igual à intensidade;
  - `Lightning`: `DirectionalLight3D` azulada, apagada fora do clarão.
- `night/rain_drop.gdshader`: shader da gota, um traço de pé virado para a câmera. Descarta os pixels dentro do interior da cabine (`shelter_min` e `shelter_max`), para nunca chover lá dentro.

## Regras
- Sorteio, uma vez por noite:
  - só a partir da noite 2 (`first_night`). A chance e a duração de cada noite vêm da curva de dificuldade (50% na noite 2, crescendo; ver `docs/sistemas/dificuldade.md`), que a `Night` aplica numa cópia do `StormSettings`;
  - começa num ponto sorteado entre 15% e 70% da noite e dura de 60 a 90 s;
  - sempre acaba antes de 95% da noite; numa noite curta demais, encolhe para caber.
- Intensidade de 0 a 1: sobe em 8 s (`ramp_seconds`) depois do início, fica em 1 e desce nos últimos 8 s, com suavização. O `Storm` só anuncia mudanças de pelo menos 0,01, porque cada anúncio refaz a iluminação do céu.
- Dicas no HUD por 3 s: "The wind is picking up..." no início e "The storm is passing." no fim.
- A `Night` repassa a intensidade (`_on_storm_strength_changed`):
  - `SkyCycle.storm_weight`: o céu, a luz ambiente e a neblina vão para a paleta da tempestade;
  - `BoatSway.set_storm_strength`: o balanço vai de 1× a 3× (`storm_intensity`), só na amplitude;
  - `MoonArc.cloud_cover`: a lua apaga;
  - `BoatLighting.set_storm_strength`: as falhas do gerador e das lâmpadas ficam até 3× mais frequentes (`storm_failure_multiplier`);
  - `StormWeather.set_strength`: a quantidade de chuva.
- Voadores: aparecem só durante a tempestade e vão embora quando ela acaba (ver `docs/sistemas/inimigos.md`).
- Relâmpago: com a intensidade em 0,6 ou mais, cai um a cada 5–14 s (sorteado), num clarão duplo de cerca de 0,5 s.
- No amanhecer e na morte, a tempestade para onde estiver, junto com os personagens.
- Para testar: `first_night` = 1 e `chance` = 1 em `night/storm_settings.tres` forçam uma tempestade em toda noite.

## Sinais
- `Storm.strength_changed(strength)` → `Night._on_storm_strength_changed`.
- `Storm.started` e `Storm.ended` → `FlyerSpawner`.

## Testes
- `test/unit/storm_rules_test.gd`: sem tempestade antes da noite permitida, chance decide, início e duração nos intervalos e antes do fim, noite curta encolhe a tempestade, intensidade zero fora, rampa de subida, pico e descida, nunca acima de 1.
- `test/unit/sky_palette_test.gd`: mistura de paletas nas pontas e no meio, inclusive a neblina.
- `test/scenes/storm_test.gd`: com a tempestade forçada e curta, no pico o balanço passa do normal, o céu e a cobertura de nuvens passam de 0,9; no fim tudo volta ao normal.
- Conferidos com captura de tela: o convés na tempestade e fora dela, a chuva no convés, a cabine seca por dentro (com chuva só vista pelas janelas e pela porta) e o convés iluminado pelo relâmpago.
