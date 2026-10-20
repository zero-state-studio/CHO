# CLAUDE.md — Open Space

Istruzioni per Claude su questo progetto. Valgono per ogni sessione.

## Il progetto in breve

*Open Space* (nome in codice) è un gioco d'azione a livelli in 3D cartoon, con visuale isometrica, ambientato in un ufficio. Ogni livello è una giornata di lavoro a tempo (9:00 → 18:00 in circa 5 minuti reali). A seconda del livello si gioca il **Junior**, che deve guadagnarsi il contratto, o il **Manager tossico**, che deve prendersi il merito senza farsi beccare dalle Risorse Umane. Le missioni sono meme della vita d'ufficio. I personaggi sono pupazzi 3D gommosi e snodati, in stile Human Fall Flat, e non parlano: fanno solo versi.

Lo sviluppano 8 colleghi nel tempo libero. Esce prima su PC (Steam: Windows, macOS, Linux, Steam Deck), poi su iOS e Android.

## Documenti

| File | A cosa serve |
|---|---|
| `docs/specifiche-del-gioco.md` | La fonte di verità su design e decisioni |
| `docs/piano-prototipo.md` | Cosa si fa negli sprint in corso |
| `docs/guida-di-stile.md` | Regole visive per asset e interfaccia |
| `docs/registro-asset.csv` | Ogni asset generato con l'IA: strumento, prompt, data, approvazione |
| `docs/decisioni-del-gioco.md` | Il file originale delle decisioni: storico, non modificarlo |

Nelle specifiche: ✅ deciso, 🔄 deciso ma cambiato, 💡 proposta, ❓ aperto.

- Prima di implementare una funzione di gameplay, leggi la sezione delle specifiche che la riguarda.
- Se una richiesta contraddice una decisione ✅, fallo notare prima di procedere.
- Non trasformare da solo una 💡 o una ❓ in una decisione: chiedi.
- Quando il team prende o cambia una decisione, aggiorna le specifiche usando la legenda.

## Stato attuale

**Fase: prototipo (Sprint 1-3).** Primo obiettivo: il **livello demo** (`game/levels/demo/`), una scena di prova per movimenti, personaggi gommosi, asset e suoni, da fare prima dei livelli veri. Grafica di qualità media, nessuna integrazione Steam, nessun menu completo. Vedi `docs/piano-prototipo.md`.

**Per ora il prototipo gira solo su macOS**, nell'editor e in una build esportata: niente preset di esportazione, test o funzioni per Windows, Linux, Android o iOS. **Il mobile è rinviato.** Blender è di nuovo disponibile (decisione del 20 ottobre 2026), tramite MCP: vedi "Strumenti per grafica e audio". Le regole sui controlli (un solo puntatore, niente azioni solo da tastiera o col tasto destro) restano valide, così non si rifanno i controlli quando arriva il mobile.

## Stack tecnico

- **Godot 4.7.2**, versione standard (non .NET). È congelata: non usare funzioni di versioni successive e non proporre aggiornamenti senza una decisione del team.
- **Solo GDScript**, con tipizzazione statica. Niente C#.
- **Renderer Compatibility** su tutte le piattaforme. Prima di usare un effetto grafico, verifica nella documentazione che sia supportato da questo renderer.
- **Fisica: Jolt** (impostata in `project.godot`), più stabile con le articolazioni dei personaggi.
- Viewport base 1280×720, stretch `canvas_items`, aspect `expand`: l'interfaccia deve adattarsi da 4:3 a 20:9.
- Plugin di terze parti in `addons/`. Previsto più avanti: GodotSteam (non ancora installato).

## Comandi

```bash
# Aprire l'editor
godot --path . -e

# Importare le risorse e uscire (controlla anche risorse mancanti)
godot --headless --path . --import

# Controllare un singolo script senza eseguirlo
godot --headless --path . --check-only -s res://percorso/script.gd

# Avviare una scena
godot --path . res://game/levels/demo/demo.tscn

# Test automatici del livello demo (senza interfaccia): attraversamento, interazioni, vetrina
godot --headless --path . --fixed-fps 60 -s res://tests/demo_walkthrough.gd
godot --headless --path . --fixed-fps 60 -s res://tests/demo_interactions.gd
godot --headless --path . --fixed-fps 60 -s res://tests/demo_showcase.gd

# Esportare la build macOS (universale, firma ad-hoc) e misurare gli fps
godot --headless --path . --export-release "macOS" builds/macos-release/OpenSpace.app
"builds/macos-release/OpenSpace.app/Contents/MacOS/Open Space" -- --benchmark

# Creare l'ambiente virtuale per gli script della pipeline (una volta sola)
python3 -m venv tools/.venv && tools/.venv/bin/pip install -r tools/requirements.txt

# Controllare che le chiavi delle API funzionino (chiamate gratuite)
tools/.venv/bin/python tools/check_keys.py

# Crediti rimasti rispetto alla riserva, o controllo di una spesa (exit 2 se oltre il limite)
python3 tools/credits.py
python3 tools/credits.py meshy 30

# Eseguire uno script della pipeline
tools/.venv/bin/python tools/meshy/nome_script.py

# Aprire Blender pronto per l'MCP (non fa nulla se è già aperto)
tools/blender/start_blender.sh [file.blend]
```

Gli script in `tests/` si compilano prima degli autoload: non possono nominare classi che usano `DebugSettings` (usano variabili `Variant`).

`godot` è il nome dell'eseguibile nel PATH; se è diverso, usa `GODOT_BIN` da `.env` (su macOS di solito `/Applications/Godot.app/Contents/MacOS/Godot`). Per Blender vale lo stesso con `BLENDER_BIN` (su macOS di solito `/Applications/Blender.app/Contents/MacOS/Blender`). Dopo ogni modifica agli script esegui almeno l'import headless e correggi errori e warning prima di dire che hai finito.

## Struttura delle cartelle

```
open-space/
├── CLAUDE.md, README.md, project.godot, icon.svg, .env.example
├── addons/            Plugin di terze parti (GodotSteam, ecc.)
├── assets/            Solo asset puliti e approvati, divisi per tipo
│   ├── audio/         music/, sfx/, voices/
│   ├── fonts/  materials/  shaders/  textures/  ui/
│   └── models/        characters/, environments/, props/
├── autoload/          Singleton globali (stato di gioco, salvataggi, audio)
├── data/              Risorse .tres con i dati: equipment/, levels/, missions/
├── docs/              Documentazione (ignorata da Godot)
├── game/              Scene e script, divisi per funzione
│   ├── characters/    junior/, manager/, npc/
│   ├── core/          Orologio della giornata, obiettivi, punteggio, checkpoint
│   ├── levels/        demo/ (livello di prova), prototype/, poi una cartella per capitolo
│   ├── platform/      Steam, Game Center, Google Play Games dietro un'unica interfaccia
│   ├── props/         Oggetti interattivi (stampante, macchinetta del caffè, ...)
│   └── ui/            hud/, menus/
├── localization/      translations.csv (chiavi, en, it)
├── source_assets/     File sorgente e generazioni IA grezze (ignorata da Godot)
├── tests/             Test automatici (strumento da decidere)
└── tools/             Script della pipeline: blender/, meshy/, scenario/, elevenlabs/ (ignorata da Godot)
```

Scene e script stanno insieme, nella cartella della funzione a cui servono: `game/characters/junior/junior.tscn` + `junior.gd`.

## Convenzioni del codice

- Segui la guida di stile ufficiale di GDScript: tab per l'indentazione; `snake_case` per file, cartelle, variabili e funzioni; `PascalCase` per `class_name` e nomi dei nodi; `CONSTANT_CASE` per le costanti.
- Tipizzazione statica ovunque: `var speed: float = 4.0`, `func deliver(task: Task) -> void:`.
- **Nomi nel codice in inglese, commenti e messaggi di commit in italiano.** Per i termini di gioco usa il glossario in fondo.
- Segnali al passato: `task_delivered`, `stress_maxed`, `workday_ended`.
- Ogni valore da bilanciare (tempi, velocità, quantità, costi) è un `@export` o sta in una risorsa in `data/`. Mai numeri magici nel codice: i designer devono poterli cambiare senza toccare gli script.
- Comunicazione tra nodi: segnali verso l'alto, chiamate verso il basso. Niente percorsi come `get_node("../../..")`.
- Godot crea file `.uid` accanto a script e risorse: si committano e si spostano insieme al file. Sposta e rinomina i file dall'editor quando possibile, così i riferimenti restano validi.
- Non modificare a mano i file `.import`.

## Stile dei personaggi: gommosi e snodati

I personaggi sono **pupazzi 3D gommosi e snodati, in stile Human Fall Flat**. È un riferimento per la sensazione: il personaggio di quel gioco non si copia.

- **Forme:** corpo morbido a fagiolo, testa tonda e liscia, arti fatti di segmenti arrotondati con le articolazioni ben visibili, mani a muffola senza dita separate. Viso minimale: due occhi, al massimo una bocca semplice.
- **Materiale:** colori pieni, aspetto opaco da gomma o plastilina, toon shading con contorno.
- **Il ruolo si riconosce da vestiti, accessori e silhouette**, non dal viso: cravatta enorme e giacca lucida per il Manager, camicia troppo grande e badge per il Junior.
- **Un solo scheletro per tutti**, umanoide e semplice, con i nomi delle ossa del profilo umanoide di Godot (`SkeletonProfileHumanoid`): animazioni, fisica e accessori si condividono tra i personaggi.
- **Costruzione: in Godot, da codice.** Mesh primitive di Godot (capsule e sfere per corpo, testa, segmenti degli arti, mani a muffola) agganciate a uno `Skeleton3D` creato da codice. Un solo corpo e un solo scheletro per tutti: proporzioni, colori e accessori (cravatta, badge, giacca...) sono parametri, in `@export` o in una risorsa in `data/`. Così i personaggi restano coerenti, leggeri e già pronti per la fisica. Budget: 1.500-3.000 triangoli. Le scene dei personaggi stanno in `game/characters/`.
- **Gommosi ma precisi.** Il personaggio va esattamente dove il giocatore tocca (`CharacterBody3D` + `NavigationAgent3D`). La gommosità è un effetto sopra il movimento: oscillazioni (`SpringBoneSimulator3D`), schiacciamento e allungamento, camminata dondolante procedurale, e ragdoll parziale (`PhysicalBoneSimulator3D`, dosato con `influence`) solo per le reazioni: urti, cadute, palline di carta, crollo da stress. La goffaggine fa ridere, ma non deve mai far fallire un'azione. Quanto spingere sulla fisica si decide giocando il livello demo, con lo slider della gommosità.

## Strumenti per grafica e audio

| Strumento | Per cosa | Script |
|---|---|---|
| Meshy (API) | Oggetti e arredi: scrivanie, sedie, stampante, macchinetta del caffè... | `tools/meshy/` |
| Scenario (server MCP `scenario`, in `.mcp.json`) | Concept, texture, icone dell'interfaccia, riferimenti per la guida di stile | `tools/scenario/` (prompt e parametri) |
| ElevenLabs (API, chiave in `.env`) | Versi, effetti sonori, musica segnaposto, voci dei personaggi (Voice Design) | `tools/elevenlabs/` |
| Blender (server MCP `blender`, in locale) | Da decidere (specifiche §7.3 ❓) | `tools/blender/` |

- **Personaggi:** costruiti in Godot (vedi "Stile dei personaggi"), non generati.
- **Blender tramite MCP:** il server `mcp-for-blender` (versione fissata in `.mcp.json`, con telemetria spenta e safe mode attivo) parla con l'add-on "MCP for Blender" dentro Blender. **Prima di usare uno strumento `mcp__blender__*`, esegui `tools/blender/start_blender.sh`** (accetta un `.blend` come argomento): se Blender è già in ascolto non fa nulla, altrimenti installa e attiva l'add-on se manca, apre Blender e aspetta che il server dell'add-on risponda sulla porta 9876. Lo lancia anche un hook in `.claude/settings.json` prima di ogni strumento `mcp__blender__*`. Se uno strumento risponde "Could not connect to Blender", rilancia lo script e riprova. Per cosa usare Blender non è ancora deciso: non sostituire da solo i personaggi costruiti in Godot né la regola "fuori budget si rigenera". Lascia spente le integrazioni del pannello che generano modelli (Hyper3D, Hunyuan3D, Meshy, Sketchfab): Meshy passa da `tools/meshy/`, così le generazioni restano ripetibili e registrate. Ogni script Blender che diventa parte della pipeline si salva in `tools/blender/`.
- **Qualità media nel prototipo:** modalità di generazione leggere ed economiche, texture da 512 px. La rifinitura arriva con il vertical slice.
- **Poligoni degli oggetti Meshy tenuti bassi senza ritocchi a mano:** poligoni di destinazione bassi e remesh dalle opzioni di Meshy, texture limitate a 512 px dalle impostazioni d'importazione di Godot. Il `.glb` va direttamente in `assets/models/props/`. Se un oggetto sfora i budget delle specifiche (§6.2) si rigenera, non si corregge a mano.
- **Generazioni ripetibili:** Meshy passa da uno script in `tools/meshy/` con la chiave in `.env`. Scenario si usa dal server MCP `scenario` del progetto (`.mcp.json`), nel progetto Scenario **CHO** (id in `tools/scenario/prompts.json`): con `SCENARIO_API_KEY` e `SCENARIO_API_SECRET` in `.env` si autentica con la chiave (lo script `tools/scenario/mcp_headers.sh` prepara l'header), senza chiave chiede il login dal browser (decisione del 20 ottobre 2026). ElevenLabs si usa direttamente con `ELEVENLABS_API_KEY` in `.env` (decisione del 20 ottobre 2026): è la chiave `open-space` dell'account Creator, con permessi limitati e un tetto di crediti per periodo di rinnovo. L'audio dello Sprint 1, fatto coi modelli ElevenLabs dentro Scenario, resta valido. Gli script leggono `.env` con la precedenza sulle variabili della shell. Per ogni generazione si salvano in `tools/<strumento>/prompts.json` prompt, modello e parametri esatti, così chiunque nel team può rifarla. Dipendenze Python in `tools/requirements.txt`, dentro un ambiente virtuale.
- **Chiavi API solo in `.env`** (i nomi delle variabili, a cosa servono e dove si creano sono in `.env.example`; quelle di Scenario sono facoltative ma consigliate; quella di ElevenLabs serve a chi genera audio): mai nel codice, mai nei log, mai committate.
- **Limiti dei crediti: regola ferrea.** Nessuna generazione può far scendere i crediti rimasti di Meshy, Scenario o ElevenLabs sotto la riserva di `tools/credit_limits.json`, né superare il tetto della chiave. I crediti si leggono dal vivo (`python3 tools/credits.py`). Gli script della pipeline si fermano da soli (`tools/common/credits.py`); per Claude lo impone l'hook `.claude/hooks/credit_guard.py`: Meshy dall'MCP è bloccato (si usa solo lo script), Pixellab e `generate_3d` di Blender sono bloccati, e su Scenario ogni `model_run` o `workflow_run` vero passa solo dopo una stima `dry_run=true` con gli stessi identici parametri e se rientra nei limiti. Non aggirare la guardia (chiamate dirette alle API, altri strumenti): se un limite blocca il lavoro, dillo e lascia decidere al team. I limiti si cambiano solo con un commit su `tools/credit_limits.json`.
- **Prima di spendere crediti** mostra cosa generi, con i prompt esatti e una stima dei crediti, e aspetta l'ok. Lavora a lotti piccoli: 2-3 varianti, poi si sceglie.
- Il risultato grezzo va in `source_assets/ai_raw/<strumento>/`, la versione pulita in `assets/`.
- **Ogni asset generato va in `docs/registro-asset.csv`:** serve per la dichiarazione dei contenuti IA su Steam e per le licenze.
- Per le API consulta sempre la documentazione ufficiale aggiornata: parametri e modelli cambiano spesso.

## Regole di design da rispettare sempre

1. **Basta un dito.** Ogni azione si fa con un clic o un tocco singolo, al massimo con un trascinamento. Niente azioni solo da tastiera, solo col tasto destro, solo al passaggio del mouse o con più dita. Unica eccezione: il pizzico per lo zoom, che deve avere anche un'alternativa a un dito (pulsanti + e −).
2. **Input solo tramite azioni.** Usa l'InputMap, mai tasti scritti nel codice. Il tocco emula il mouse (`emulate_mouse_from_touch` è attivo): scrivi il gameplay sugli eventi del mouse con un solo puntatore e gestisci a parte solo il pizzico.
3. **Nessuna parola parlata.** I personaggi fanno solo versi; il testo sta solo nell'interfaccia.
4. **Mai testo scritto nel codice.** Ogni testo visibile è una chiave in `localization/translations.csv` (colonne `en` e `it`). Chiavi in maiuscolo con prefisso: `UI_`, `HUD_`, `ROLE_`, `MISSION_`, `ACH_`. Quando aggiungi una chiave, scrivi entrambe le lingue.
5. **Ogni suono importante ha anche un segnale visivo**, e nessuna informazione è affidata solo al colore.
6. **Deve girare su tutto.** Rispetta i budget delle specifiche (§6.1 e §6.2): portatile vecchio con grafica integrata e telefono di fascia media. Poche luci dinamiche, niente post-processing pesante.
7. **Il gioco funziona senza Steam.** Achievement, cloud e classifiche passano solo da `game/platform/`; il resto del codice non chiama mai Steam direttamente. Senza Steam (editor, mobile) quelle chiamate non fanno nulla e non generano errori.
8. **Salvataggi** solo tramite il sistema di salvataggio, in `user://`. Si salva in automatico ai checkpoint: pausa pranzo (13:00) e fine livello.
9. **Tono.** È satira: si ride del Manager e delle situazioni, mai di chi le subisce. Niente marchi, aziende o persone reali, niente immagini di meme esistenti.
10. **Gommosi ma precisi.** La fisica dei personaggi fa ridere, ma non deve mai far fallire un'azione del giocatore.

## Asset

- I file grezzi (generazioni IA, `.blend`, `.psd`) stanno in `source_assets/`. In `assets/` entra solo la versione pulita e approvata dall'art director (checklist in `docs/guida-di-stile.md`).
- Formati: modelli `.glb`, texture `.png`, musica `.ogg`, effetti e versi `.wav` se brevi, altrimenti `.ogg`.
- Prefissi dei nomi: `chr_` personaggi, `prop_` oggetti, `env_` ambienti, `tex_` texture, `mat_` materiali, `shd_` shader, `mus_` musica, `sfx_` effetti, `vox_` versi, `ui_` interfaccia, `fnt_` font.
- I file binari vanno in Git LFS (vedi `.gitattributes`).

## Git

- Un ramo per compito (`feature/manager-lancio-pratiche`, `fix/navigazione-bloccata`), commit piccoli, messaggi in italiano.
- Non si committano `.godot/`, `builds/` e soprattutto `.env`, che contiene le chiavi delle API.
- `export_presets.cfg` si committa; le credenziali di firma restano in `.godot/`, cioè in locale.

## Chiedi prima di

- spendere crediti di Meshy, Scenario o ElevenLabs;
- aggiungere plugin o dipendenze;
- cambiare `project.godot` (renderer, risoluzione, autoload, InputMap);
- riscrivere a mano scene `.tscn` complesse: per cambi grossi descrivi cosa fare nell'editor, oppure crea una scena nuova;
- cambiare una decisione ✅ delle specifiche.

## Glossario

| Nel design | Nel codice |
|---|---|
| Junior | `junior` |
| Manager tossico | `manager` |
| Risorse Umane | `hr` |
| CEO | `ceo` |
| Collega (personaggio non giocabile) | `npc` |
| Giornata (un livello) | `workday` |
| Orologio della giornata | `WorkdayClock` |
| Pausa pranzo (checkpoint) | `lunch_checkpoint` |
| Pratica, compito | `task` |
| Energia / Stress / Reputazione | `energy` / `stress` / `reputation` |
| Ego / Bonus | `ego` / `bonus` |
| Buoni pasto | `meal_vouchers` |
| Distributore automatico (negozio) | `vending_machine` |
| Equipaggiamento / Statistiche | `equipment` / `stats` |
| Stelle | `stars` |
| Missione | `mission` |
| Livello demo | `demo` |
| Gommosità (slider di debug) | `wobble` |
