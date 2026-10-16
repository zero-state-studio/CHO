# Open Space

*Nome in codice.* Gioco d'azione a livelli in 3D cartoon, ambientato in un ufficio: a seconda del livello sei il Junior che deve guadagnarsi il posto o il Manager tossico che si prende il merito di tutto. Prima su PC (Steam), poi su mobile.

## Cosa serve

- [Godot 4.7.2](https://godotengine.org/), versione standard (non .NET)
- Git con [Git LFS](https://git-lfs.com/)
- Python 3, per gli script in `tools/` (Blender per ora non serve: è rinviato)
- Un file `.env` con le chiavi di ElevenLabs, Meshy e Scenario: copiate `.env.example` e compilatelo (non va mai committato)

## Primo avvio

```bash
git lfs install
git clone <indirizzo-del-repository>
```

Poi in Godot: **Importa** → selezionate `project.godot`. Al primo avvio Godot importa tutte le risorse: può volerci qualche minuto.

## Il livello demo

Aprite il progetto e premete F5: parte il livello demo (`game/levels/demo/demo.tscn`). Si gioca col solo mouse: clic sul pavimento per camminare, clic su un oggetto per usarlo, rotella o pulsanti +/− per lo zoom. Il pannello "Debug" in alto a sinistra cambia personaggio, gommosità, velocità del tempo e volumi.

Per misurare le prestazioni sul vostro Mac, esportate la build ed eseguitela con `-- --benchmark` (i comandi sono in `CLAUDE.md`): stampa gli fps di ogni zona e li salva in un file. Al primo avvio una build non notarizzata va aperta con clic destro → Apri.

## Dove trovare cosa

- `docs/specifiche-del-gioco.md` — cos'è il gioco e cosa abbiamo deciso
- `docs/piano-prototipo.md` — cosa stiamo facendo adesso
- `docs/guida-di-stile.md` — regole per gli asset
- `docs/registro-asset.csv` — ogni asset generato con l'IA, con strumento e prompt
- `CLAUDE.md` — struttura delle cartelle, convenzioni e regole del progetto (le legge anche Claude)
