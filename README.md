# Open Space

*Nome in codice.* Gioco d'azione a livelli in 3D cartoon, ambientato in un ufficio: a seconda del livello sei il Junior che deve guadagnarsi il posto o il Manager tossico che si prende il merito di tutto. Prima su PC (Steam), poi su mobile.

## Cosa serve

- [Godot 4.7.2](https://godotengine.org/), versione standard (non .NET)
- Git con [Git LFS](https://git-lfs.com/)
- Python 3, per gli script in `tools/`
- [Blender](https://www.blender.org/) e [uv](https://docs.astral.sh/uv/) (`brew install uv`), se usate Blender tramite Claude (vedi sotto)
- Un file `.env` con le chiavi di Meshy, Scenario ed ElevenLabs, se generate asset: copiate `.env.example` in `.env` e seguite le istruzioni dentro il file (non va mai committato). Poi controllate le chiavi con `tools/.venv/bin/python tools/check_keys.py` e i crediti con `python3 tools/credits.py`: nessuna generazione può scendere sotto la riserva di `tools/credit_limits.json`

## Primo avvio

```bash
git lfs install
git clone <indirizzo-del-repository>
```

Poi in Godot: **Importa** → selezionate `project.godot`. Al primo avvio Godot importa tutte le risorse: può volerci qualche minuto.

### Blender con Claude (facoltativo)

Il server MCP di Blender è già configurato in `.mcp.json`: Claude Code lo propone la prima volta che aprite il progetto (approvatelo). Al resto pensa Claude: prima di usare Blender esegue `tools/blender/start_blender.sh`, che installa e attiva l'add-on se manca, apre Blender e aspetta che il server dell'add-on sia pronto. Potete lanciarlo anche voi, eventualmente con un file `.blend` come argomento. Lasciate spente le integrazioni del pannello che generano modelli (Hyper3D, Hunyuan3D, Meshy, Sketchfab).

## Il livello demo

Aprite il progetto e premete F5: parte il livello demo (`game/levels/demo/demo.tscn`). Si gioca col solo mouse: clic sul pavimento per camminare, clic su un oggetto per usarlo, rotella o pulsanti +/− per lo zoom. Il pannello "Debug" in alto a sinistra cambia personaggio, gommosità, velocità del tempo e volumi.

Per misurare le prestazioni sul vostro Mac, esportate la build ed eseguitela con `-- --benchmark` (i comandi sono in `CLAUDE.md`): stampa gli fps di ogni zona e li salva in un file. Al primo avvio una build non notarizzata va aperta con clic destro → Apri.

## Dove trovare cosa

- `docs/specifiche-del-gioco.md` — cos'è il gioco e cosa abbiamo deciso
- `docs/piano-prototipo.md` — cosa stiamo facendo adesso
- `docs/guida-di-stile.md` — regole per gli asset
- `docs/registro-asset.csv` — ogni asset generato con l'IA, con strumento e prompt
- `CLAUDE.md` — struttura delle cartelle, convenzioni e regole del progetto (le legge anche Claude)
