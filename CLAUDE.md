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

**Per ora il prototipo gira solo su macOS**, nell'editor e in una build esportata: niente preset di esportazione, test o funzioni per Windows, Linux, Android o iOS. **Mobile e Blender sono rinviati.** Le regole sui controlli (un solo puntatore, niente azioni solo da tastiera o col tasto destro) restano valide, così non si rifanno i controlli quando arriva il mobile.

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

# Creare l'ambiente virtuale per gli script della pipeline (una volta sola)
python3 -m venv tools/.venv && tools/.venv/bin/pip install -r tools/requirements.txt

# Controllare che le chiavi delle API funzionino (chiamate gratuite)
tools/.venv/bin/python tools/check_keys.py

# Eseguire uno script della pipeline
tools/.venv/bin/python tools/meshy/nome_script.py
```

`godot` è il nome dell'eseguibile nel PATH; se è diverso, usa `GODOT_BIN` da `.env` (su macOS di solito `/Applications/Godot.app/Contents/MacOS/Godot`). Blender per ora non si usa: non cercarlo, non installarlo e non scrivere script per Blender. Dopo ogni modifica agli script esegui almeno l'import headless e correggi errori e warning prima di dire che hai finito.

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
| Scenario (server MCP, con il login dell'utente) | Concept, texture, icone dell'interfaccia, riferimenti per la guida di stile | `tools/scenario/` (prompt e parametri) |
| ElevenLabs (server MCP, con il login dell'utente) | Versi, effetti sonori, musica segnaposto | `tools/elevenlabs/` (prompt e parametri) |

- **Personaggi:** costruiti in Godot (vedi "Stile dei personaggi"), non generati.
- **Blender: rinviato.** La cartella `tools/blender/` resta vuota per il futuro.
- **Qualità media nel prototipo:** modalità di generazione leggere ed economiche, texture da 512 px. La rifinitura arriva con il vertical slice.
- **Poligoni degli oggetti Meshy tenuti bassi senza ritocchi a mano:** poligoni di destinazione bassi e remesh dalle opzioni di Meshy, texture limitate a 512 px dalle impostazioni d'importazione di Godot. Il `.glb` va direttamente in `assets/models/props/`. Se un oggetto sfora i budget delle specifiche (§6.2) si rigenera, non si corregge a mano.
- **Generazioni ripetibili:** Meshy passa da uno script in `tools/meshy/` con la chiave in `.env`. Scenario ed ElevenLabs si usano dai loro server MCP, con il login dell'utente (decisione del 15 ottobre 2026: le chiavi API di questi due servizi non ci sono). Per ogni generazione si salvano in `tools/<strumento>/prompts.json` prompt, modello e parametri esatti, così chiunque nel team può rifarla. Dipendenze Python in `tools/requirements.txt`, dentro un ambiente virtuale.
- **Chiavi API solo in `.env`** (i nomi delle variabili sono in `.env.example`; quelle di Scenario ed ElevenLabs sono facoltative): mai nel codice, mai nei log, mai committate.
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
