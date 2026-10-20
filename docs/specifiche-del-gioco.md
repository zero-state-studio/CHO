# Open Space — Specifiche del gioco

*Titolo provvisorio, da decidere. Versione 0.4 del 15 ottobre 2026: aggiunti personaggi gommosi, strumenti per gli asset e livello demo.*

Altri documenti in questa cartella: `piano-prototipo.md` (i primi tre sprint), `registro-asset.csv` (gli asset generati con l'IA), `guida-di-stile.md` (da compilare), `decisioni-del-gioco.md` (il file originale delle decisioni).

Questo documento parte dal file **Le decisioni del gioco** e lo aggiorna con il brief del 15 ottobre: gioco d'ufficio in cui, a seconda del livello, sei il Manager tossico o il Junior; mobile e PC; 3D cartoon; missioni meme; personaggi che fanno solo versi. Dove nessuno dei due diceva niente ho fatto delle proposte, segnate come tali: sono un punto di partenza da discutere, non decisioni.

**Squadra:** 8 colleghi, nel tempo libero, con Godot e strumenti di generazione (Scenario, Meshy, ElevenLabs).

| Segno | Significato |
|---|---|
| ✅ | Deciso (nel file delle decisioni o nel brief) |
| 🔄 | Deciso, ma cambiato rispetto al file delle decisioni |
| 💡 | Proposta, da approvare |
| ❓ | Da decidere: vedi le domande aperte in fondo |
| ⚠️ | Attenzione: conflitto o rischio |

---

## 1. Cosa cambia rispetto al file delle decisioni

| Voce | Nel file | Ora | Conseguenza |
|---|---|---|---|
| Piattaforme | Windows, Mac, Linux | + iOS e Android, dopo il PC 🔄 | Steam vende solo la versione PC. Il mobile esce dopo, su App Store e Google Play, con pagine, prezzi, regole e revisioni separate. |
| Controlli | Tastiera e mouse | + touch 🔄 | Tutto il gioco va pensato per essere giocabile con un dito (§5.2). |
| Schermo | 16:9 e 16:10 | + formati di telefoni e tablet 🔄 | Interfaccia ancorata ai bordi, margini per notch e barra home. |
| Voci | Versi ed esclamazioni | Solo versi 🔄 | Nessuna parola, nemmeno esclamazioni riconoscibili: niente da tradurre. |
| Stile | 3D stilizzato | 3D cartoon ✅ | Compatibili: il cartoon è un 3D stilizzato con proporzioni esagerate. |
| Prestazioni | Anche un portatile vecchio | + telefoni di fascia media ✅ | Stesso budget grafico per tutti: il vincolo del portatile vecchio aiuta anche il mobile. |
| Uscita | Entro fine anno | Quando è pronto 🔄 | Niente scadenza esterna: serve una data bersaglio interna, altrimenti il progetto si allunga all'infinito (§13.4). |

---

## 2. Il gioco in breve

**Pitch** ✅. Un gioco d'azione a livelli, in 3D cartoon e visuale isometrica, ambientato in un ufficio: ogni livello è una giornata di lavoro a tempo, nel caos dell'open space. In ogni livello sei uno dei due: il **Junior**, che deve fare il bravo e guadagnarsi il contratto, o il **Manager tossico**, che deve far sembrare suo il lavoro degli altri senza farsi beccare. Le missioni sono i meme della vita d'ufficio. I personaggi sono pupazzi gommosi e snodati, e nessuno parla: tutti si esprimono a versi.

**Pilastri** 💡

1. **Due lati dello stesso ufficio.** Gli stessi spazi e gli stessi colleghi, visti da chi subisce e da chi comanda.
2. **Umorismo che si riconosce.** Chiunque abbia lavorato in un ufficio deve ridere entro cinque secondi dall'inizio di una missione.
3. **Si capisce senza parole.** Versi, gesti, icone e ambiente raccontano tutto.
4. **Un livello è una pausa caffè.** Livelli brevi, che funzionano allo stesso modo su PC e telefono.

**Il gancio** 💡: lo stesso ufficio in due giornate. Nel livello da Manager crei il caos (pratiche impossibili, riunioni inutili); nel livello da Junior che segue ti ritrovi nello stesso ufficio, il giorno dopo, a gestirne le conseguenze. Oltre a essere divertente fa risparmiare: ogni ambiente serve per due livelli.

**Riferimenti di gioco**: Overcooked ✅ (caos a tempo e compiti da destreggiare); 💡 anche Untitled Goose Game (dispetti e furtività in un ambiente quotidiano) e Two Point Hospital (satira leggera di un luogo di lavoro).

---

## 3. Visione e pubblico

| Voce | Decisione |
|---|---|
| Dimensione | Medio ✅ |
| Pubblico | Giocatori occasionali ✅ |
| Giocatori | Giocatore singolo ✅ |
| Sessione | Mezz'ora ✅ — 💡 livelli da 4-7 minuti: una sessione contiene 4-6 livelli e un singolo livello sta in una pausa sul telefono |
| Durata complessiva | 💡 3-4 ore per finirlo, di più per tre stelle, achievement e classifiche |

---

## 4. Gameplay

### 4.1 Struttura

- Livelli in sequenza ✅. Il ruolo lo decide il livello, non il giocatore ✅.
- 💡 **5 capitoli × 6 livelli = 30 livelli.** Ogni capitolo è una settimana di lavoro: i livelli si alternano Junior / Manager e il sesto è un *livello evento* in cui succede qualcosa di grosso.
- 💡 **Circa 15 ambienti**, ognuno usato da entrambi i ruoli.
- I livelli si possono rigiocare per migliorare stelle e punteggio in classifica.

| Capitolo 💡 | Tema | Livello evento |
|---|---|---|
| 1. Onboarding | Primo giorno: insegna i due ruoli | La foto aziendale |
| 2. Fine trimestre | Scadenze e numeri da gonfiare | La presentazione dei risultati |
| 3. Riorganizzazione | Si cambia scrivania, nessuno sa più niente | Il trasloco al piano nuovo |
| 4. Agosto | Ufficio semivuoto, chi resta fa tutto | Il climatizzatore rotto |
| 5. Valutazione annuale | Si decide chi resta | La review col CEO (finale) |

### 4.2 Com'è fatto un livello

La formula è decisa ✅: una giornata a tempo per livello. I numeri e i dettagli qui sotto restano 💡.

- Un livello è una giornata: l'orologio in alto va dalle 9:00 alle 18:00 in circa 5 minuti reali.
- Un obiettivo principale per superarlo, due obiettivi secondari per le stelle. 1 stella = superato, 3 stelle = perfetto.
- **La pausa pranzo è il checkpoint:** alle 13:00 il gioco salva in automatico ✅ e se perdi riparti da lì.
- A fine livello: riepilogo, stelle, buoni pasto guadagnati, posizione in classifica.

### 4.3 Il Junior

**Obiettivo:** fare il bravo e guadagnarsi il posto ✅.

- **Carriera** 💡: tra un capitolo e l'altro il contratto migliora: stage non retribuito → stage → tempo determinato → tempo indeterminato. È la storia del Junior, raccontata da badge, scrivania e cartellino.
- **Cosa fa:** prende e consegna pratiche, fa fotocopie, risponde al telefono, ripara la macchinetta del caffè, porta i caffè giusti alle persone giuste.
- **Cosa lo ostacola:** colleghi che lo fermano con un "hai un minuto?", sale riunioni che lo risucchiano, compiti extra lanciati dal Manager, la stampante.
- **Barre:** *Energia* (cala col tempo, si ricarica col caffè) e *Stress* (sale con gli imprevisti). Con lo stress al massimo il Junior crolla sulla scrivania e riparte dal checkpoint.
- **Punteggio:** *Reputazione*.

### 4.4 Il Manager tossico

**Obiettivo** 💡: finire la giornata col bonus più alto senza farsi scoprire dalle Risorse Umane.

- **Cosa fa:** assegna compiti "per ieri" lanciando pratiche sulle scrivanie, convoca riunioni inutili (un'area che blocca chi ci finisce dentro), si prende il merito intercettando i lavori finiti prima che arrivino al CEO, fa micromanagement standosene alle spalle dei dipendenti.
- **Cosa lo ostacola:** il giro di controllo delle Risorse Umane (un cono visivo da evitare, furtività leggera), il CEO che passa a sorpresa, i dipendenti che a fine giornata scappano.
- **Barre:** *Ego* (la sua salute: cala se viene ripreso o smascherato) e *Bonus* (il punteggio).
- **Il tono** 💡: il Manager lo controlli tu, ma la battuta è sempre su di lui. Le sue gag finiscono male per lui (karma cartoon) e il gioco non premia mai l'umiliazione degli altri fine a sé stessa.

### 4.5 Progressione: equipaggiamento e statistiche ✅

- **Valuta** 💡: i *buoni pasto*, guadagnati in ogni livello.
- **Negozio** 💡: il distributore automatico del piano, tra un livello e l'altro.
- Ogni ruolo ha le sue statistiche e 3 slot di equipaggiamento. Gli oggetti si vedono addosso al personaggio (utile anche per screenshot e trailer).

| | Junior | Manager |
|---|---|---|
| Statistiche | Velocità, Resistenza allo stress, Multitasking (quante cose porta), Concentrazione (velocità nelle azioni) | Velocità, Carisma (raggio d'influenza), Faccia tosta (quanto ci mettono le Risorse Umane ad accorgersene), Ego |
| Equipaggiamento (esempi) | Cuffie antirumore, scarpe comode, tazza termica, badge col cordino | Cravatta "power", smartphone aziendale con due SIM, tazza "Boss", gemelli d'oro |

💡 La progressione fa anche da paracadute per la difficoltà: chi resta bloccato può rigiocare i livelli vecchi, accumulare buoni pasto e diventare più forte, senza che la difficoltà cambi per nessuno.

### 4.6 Missioni meme 💡

**Regole**

- Meme **da ufficio**, che durano negli anni ("poteva essere una mail"), non meme di internet del momento, che invecchiano prima dell'uscita.
- **Niente immagini di meme famosi**: spesso sono foto protette da diritto d'autore o ritraggono persone reali. Il meme si ricrea come situazione, non si copia.
- Niente aziende, marchi o persone reali.
- I titoli si **adattano**, non si traducono: in inglese serve una battuta equivalente.

| Missione (IT / EN) | Ruolo | Cosa succede |
|---|---|---|
| Questa riunione poteva essere una mail / This Meeting Could Have Been an Email | Junior | Finisci il lavoro mentre le sale riunioni cercano di risucchiarti. |
| Per ieri / Needed It Yesterday | Manager | Riempi tutte le scrivanie di urgenze prima delle 10:00. |
| Hai un minuto? / Got a Minute? | Junior | Attraversa l'open space evitando chi ti blocca a chiacchierare. |
| Rispondi a tutti / Reply All | Junior | Una catena di email si moltiplica per l'ufficio: fermala prima che invada tutto. |
| Il merito è mio / Credit Thief | Manager | Intercetta il report del Junior e portalo al CEO prima di lui. |
| La stampante / The Printer | Junior | Primo boss: la stampante inceppata ha un attacco diverso per ogni fase. |
| Il microonde delle 13:00 / Microwave Rush Hour | Junior | La coda al microonde, il collega del pesce, un pranzo da salvare. |
| Siamo una famiglia / We're Like Family Here | Manager | Durante la festa aziendale taglia il budget a tutti senza che smettano di sorridere. |
| Venerdì, 17:55 / Friday, 5:55 PM | Manager | Scarica l'ultimo compito su qualcuno prima che escano tutti. |
| Venerdì, 17:56 / Friday, 5:56 PM | Junior | Il livello specchio: esci dall'ufficio senza che il Manager ti veda. |
| Ti pagheremo in visibilità / Paid in Exposure | Junior | Lo stage: tanto lavoro, ricompensa in "visibilità". |
| Facciamo un punto / Let's Circle Back | Manager | Tieni più persone possibile in riunione, il più a lungo possibile. |
| Il caffè è finito / Out of Coffee | Junior | L'energia cala a tutti: ripara la macchinetta prima del crollo generale. |
| Team building obbligatorio / Mandatory Fun | Evento | Percorso a ostacoli aziendale, con fiducia cieca nei colleghi. |

### 4.7 Difficoltà

- Impegnativa, uguale per tutti ✅.
- ⚠️ Tira in direzione opposta al pubblico occasionale (già segnalato nel file). 💡 Come tenerle insieme senza un selettore di difficoltà:
  - superare un livello (1 stella) è alla portata di tutti; la sfida vera sta nelle 3 stelle e nelle classifiche;
  - checkpoint a metà livello e ripartenza istantanea;
  - la progressione (buoni pasto → equipaggiamento) come aiuto implicito;
  - curva dolce in tutto il capitolo 1.

### 4.8 Storia raccontata dall'ambiente ✅

💡 Cosa cambia di livello in livello:

- la scrivania del Junior: da sedia pieghevole e post-it a scrivania tutta sua, con piante e foto;
- l'ufficio del Manager: sempre più grande e assurdo (trofei di cartone, una seconda poltrona per l'ego);
- la bacheca aziendale, le piante che muoiono ad agosto, la lavagna con l'organigramma che cambia;
- 💡 **finale:** il Junior ottiene l'indeterminato e una promozione, si siede nell'ufficio del Manager… e arriva un nuovo stagista. Il ciclo ricomincia (aggancio per un capitolo extra o un seguito).

### 4.9 Comunicare senza parole

- I versi esprimono le emozioni; le richieste stanno in nuvolette con icone (una tazza = vuole un caffè, una pila di fogli = ha una pratica per te, un punto esclamativo rosso = urgente).
- Tutorial mostrati, non spiegati: frecce, evidenziazioni, al massimo una parola sullo schermo.
- Il testo resta solo in menu, titoli delle missioni, obiettivi e achievement.

---

## 5. Piattaforme e controlli

### 5.1 Piattaforme 🔄

| Piattaforma | Negozio | Controlli | Note |
|---|---|---|---|
| Windows | Steam | Tastiera e mouse | ✅ |
| macOS | Steam | Tastiera e mouse | ✅ Build universale (Apple Silicon e Intel), firmata e notarizzata |
| Linux e Steam Deck | Steam | Tastiera e mouse; touch sul Deck | ✅ Giocabile su Deck |
| iOS / iPadOS | App Store | Touch | 🔄 Dopo il PC. Per esportare serve un Mac con Xcode |
| Android | Google Play | Touch | 🔄 Dopo il PC |

- Chi compra su Steam non ha la versione mobile, e viceversa. Progressi condivisi tra PC e telefono: 💡 non al lancio.
- **Prima il PC, poi il mobile** ✅. 💡 Il touch però si progetta e si prova da subito, con un telefono in ogni test di fine sprint: così il porting sarà un adattamento, non una riscrittura dei controlli.
- ❓ iOS, Android o entrambi si può decidere più avanti, prima di iniziare il porting.

### 5.2 Uno schema di controllo per tutti 💡

Visuale isometrica e punta-e-clicca: funziona allo stesso modo col mouse e col dito.

| Azione | Mouse e tastiera | Touch |
|---|---|---|
| Muoversi | Clic sul pavimento (WASD opzionale) | Tocco sul pavimento |
| Interagire / raccogliere | Clic sull'oggetto o sulla persona | Tocco |
| Lanciare (Manager) | Tieni premuto e rilascia verso il bersaglio | Trascina e rilascia |
| Abilità | Tasti 1-3 | Tre pulsanti in basso a destra |
| Zoom | Rotella | Pizzico |
| Pausa | Esc | Pulsante in alto |

- Telecamera fissa, senza rotazione 💡 (meno lavoro sugli ambienti). Pareti e mobili davanti al personaggio diventano trasparenti.
- Pulsanti touch di almeno 44 pt (iOS) / 48 dp (Android).
- Nessun gesto a più dita obbligatorio: tutto si fa con un dito solo.
- 💡 Valutare il supporto al **controller**: in Godot costa poco e apre la strada al "Verificato" su Steam Deck, che richiede il pieno supporto al controller. ❓

### 5.3 Risoluzione e formati

- PC: 16:9 e 16:10 ✅ (il Deck è 1280×800, cioè 16:10).
- 🔄 Telefoni da 19,5:9 a 20:9 e oltre, tablet 4:3. In Godot: stretch mode `canvas_items` con aspect `expand`, interfaccia ancorata ai bordi, margini per le zone sicure.
- Il testo più piccolo deve restare leggibile a 1280×800 e su un telefono da 6 pollici.

---

## 6. Tecnica

| Voce | Decisione |
|---|---|
| Motore | Godot ✅ — 💡 4.7.2, l'ultima stabile al 15 ottobre 2026, congelata fino all'uscita salvo bug bloccanti (versione standard, non .NET) |
| Linguaggio | GDScript ✅ — si esporta senza problemi su tutte e cinque le piattaforme |
| Renderer | 💡 *Compatibility*: il più leggero, gira sui portatili vecchi e sulla maggior parte dei telefoni; il toon shading si fa comunque con shader propri |
| Fisica | 💡 Jolt, più stabile con le articolazioni dei personaggi gommosi |
| Salvataggio | Automatico ai checkpoint ✅ (pausa pranzo e fine livello). PC: Steam Cloud ✅. Mobile: salvataggio locale 💡, cloud più avanti |
| Funzioni Steam | Achievement, Steam Cloud e classifiche tramite GodotSteam ✅ |
| Funzioni mobile | ❓ Game Center e Google Play Games (con plugin della community), oppure niente al lancio |
| Versioni del progetto | 💡 Git + Git LFS per modelli, texture e audio |
| Build | 💡 Una build per piattaforma a ogni fine sprint, provata da qualcuno che non l'ha fatta |

### 6.1 Obiettivi di prestazioni 💡

| Dispositivo | Riferimento | Obiettivo |
|---|---|---|
| PC minimo | Portatile con grafica integrata tipo Intel HD/UHD 620, 8 GB di RAM | 60 fps a 720p, almeno 30 fps a 1080p |
| Steam Deck | — | 60 fps a 1280×800 |
| Telefono | Android di fascia media del 2020-2021, iPhone di pari età | 30 fps stabili, 60 dove possibile; opzione "risparmio batteria" bloccata a 30 fps |

### 6.2 Budget grafico 💡

Indicativo, da verificare con il prototipo.

- Personaggi principali: 3.000-5.000 triangoli; colleghi di sfondo: 1.500-3.000.
- Oggetti d'arredo: 100-1.500 triangoli.
- Texture: 512-1024 px, raccolte in atlanti; pochi materiali condivisi.
- Luci: una direzionale più illuminazione precalcolata; ombre semplici.
- Meno di 100 draw call per inquadratura su mobile.
- Stesse risorse su PC e mobile: niente doppio lavoro.

---

## 7. Arte

### 7.1 Stile

- 3D cartoon ✅ con **personaggi gommosi e snodati in stile Human Fall Flat** ✅ (riferimento per la sensazione: il personaggio di quel gioco non si copia). Corpi morbidi e arrotondati come pupazzi di gomma, arti a segmenti che ciondolano e reagiscono agli urti, mani a muffola, viso minimale. Toon shading con contorno, colori saturi, materiale opaco da gomma.
- 💡 **Gommosi ma precisi:** il personaggio va dove tocchi; la gommosità è un effetto sopra il movimento (oscillazioni, schiacciamento e allungamento, ragdoll parziale per urti e cadute) e non deve mai far fallire un'azione. Quanto spingere sulla fisica si decide giocando il livello demo.
- Leggibilità prima di tutto: su un telefono un personaggio è alto un centimetro, e va riconosciuto dalla sola silhouette.
- Junior 💡: camicia troppo grande, badge al collo, zainetto. Manager 💡: abito lucido, cravatta enorme, abbronzatura, sorriso fisso. Il colore aiuta ma non basta: i ruoli si distinguono anche dalla forma (accessibilità).
- Visuale isometrica ✅: 💡 telecamera ortogonale inclinata di circa 30-35° e ruotata di 45°.

### 7.2 Cast 💡

| Personaggio | Ruolo nel gioco |
|---|---|
| Junior | Protagonista dei livelli Junior |
| Manager tossico | Protagonista dei livelli Manager, ostacolo in quelli Junior |
| Risorse Umane | La "guardia" dei livelli Manager |
| CEO | Non si vede quasi mai: se ne vedono solo le scarpe e si sente arrivare |
| Colleghi | Archetipi: quello del pesce al microonde, quella del "rispondi a tutti", lo stagista eterno, il tecnico informatico, l'entusiasta del team building |
| La stampante | Il primo boss |

### 7.3 Uso dell'IA ✅ 🔄 (per quasi tutto, con ritocchi)

Il rischio principale è la coerenza: asset generati con strumenti diversi, da persone diverse, sembrano presi da giochi diversi. 💡 Come contenerlo:

1. **Guida di stile** prima di generare qualsiasi asset: 10-15 immagini di riferimento, palette, regole su proporzioni e contorni.
2. **Un art director** nel team che approva ogni asset prima che entri nel gioco.
3. **Chi fa cosa** 🔄 *(15 ottobre 2026: Blender rinviato)*: i personaggi si costruiscono **in Godot, da codice**, con mesh primitive (capsule e sfere) agganciate a un unico scheletro umanoide creato da codice; proporzioni, colori e accessori sono parametri, così sono coerenti e pronti per la fisica. Oggetti e arredi si generano con Meshy tenendo bassi i poligoni con le sue opzioni (poligoni di destinazione bassi, remesh, texture alla risoluzione minima); le texture si limitano a 512 px dalle impostazioni d'importazione di Godot. Niente pulizia a mano: un oggetto che sfora il budget (§6.2) si rigenera. Concept, texture e icone con Scenario; versi, effetti e musica con ElevenLabs. ~~Blender (script dei personaggi, pulizia dei modelli, atlanti delle texture) è rinviato a dopo il prototipo.~~ 🔄 *(20 ottobre 2026)*: Blender torna disponibile per tutto il team già nel prototipo, in locale, pilotato da Claude con il server MCP `mcp-for-blender` (configurato in `.mcp.json`). ❓ Per cosa usarlo è ancora da decidere (pulizia dei modelli Meshy, atlanti delle texture, script dei personaggi...): finché il team non decide, i personaggi restano costruiti in Godot e un oggetto fuori budget si rigenera.
4. **Licenze:** verificate che ogni strumento, con il piano che pagate, permetta l'uso commerciale.
5. **Dichiarazione su Steam:** i contenuti generati con IA vanno dichiarati nel questionario dei contenuti, e la dichiarazione compare sulla pagina del gioco. Per App Store e Google Play verificate le regole aggiornate.
6. **Registro degli asset** (`registro-asset.csv`): per ogni asset generato, strumento, prompt e data. Rende facile la dichiarazione su Steam e il controllo delle licenze.
7. **Qualità per fase:** media nel prototipo (modalità di generazione leggere, texture da 512 px), rifinitura dal vertical slice in poi.

### 7.4 Interfaccia a tema ✅

Post-it, cartelline, timbri, finestre di email e notifiche del calendario. 💡 L'HUD del Junior sembra il suo telefono, quello del Manager la sua agenda di pelle. Font leggibile e con gli accenti italiani; scala dell'interfaccia regolabile.

### 7.5 Animazioni

Per ogni personaggio giocabile: fermo, camminata, corsa, trasporto, lancio (Manager), interazione, stress, crollo, esultanza, sconfitta, più 5-6 reazioni da abbinare ai versi. Per i colleghi un set ridotto. 💡 Con i personaggi gommosi molte animazioni possono essere procedurali (camminata dondolante, oscillazioni, crollo in ragdoll): meno lavoro a mano, da verificare nel livello demo.

---

## 8. Audio

### 8.1 Musica — generata e rifinita ✅

- 💡 Genere: musica d'attesa e lounge da ascensore, che si fa più nervosa con l'avanzare della giornata.
- 💡 Due temi: Junior (allegro e ansioso), Manager (pomposo, tutto fiati ed ego).
- 💡 Adattività leggera: dalle 17:00 entra uno strato in più (percussioni). Bastano due tracce sovrapposte, niente sistemi complicati.
- Loop puliti; licenza commerciale verificata.

### 8.2 Voci — solo versi ✅ 🔄

- Ogni personaggio ha una voce riconoscibile e un set di 10-15 versi: saluto, sorpresa, fastidio, rabbia, risata, fatica, sollievo, vittoria, sconfitta, richiesta, e il borbottio interrogativo del "hai un minuto?".
- Grammelot: nessuna parola vera in nessuna lingua, così non c'è niente da tradurre.
- Niente voci clonate da persone reali.

### 8.3 Effetti sonori — generati con ElevenLabs ✅

💡 Elenco minimo:

- **Interfaccia:** clic, timbro, foglio che scorre, notifica.
- **Ufficio:** stampante, telefono, tastiera, macchinetta del caffè, ding del microonde, email in arrivo.
- **Gioco:** lancio di carta, impatto cartoon, stress che sale, orologio, campanella delle 18:00.
- **Eventi:** gong della riunione, passi del CEO.

### 8.4 Regole

- Volumi separati per musica, effetti e versi.
- Ogni suono importante ha anche un segnale visivo: su mobile in tanti giocano senza audio.

---

## 9. Lingue

- Inglese e italiano ✅.
- Il testo è poco: menu, titoli e obiettivi delle missioni, achievement, pagine degli store.
- I titoli meme si adattano (§4.6) e 💡 un madrelingua inglese rilegge tutto.
- L'italiano è spesso più lungo dell'inglese del 20-30%: l'interfaccia deve avere spazio.
- Traduzioni gestite con i file CSV o PO di Godot.
- 💡 Senza doppiaggio, aggiungere lingue dopo il lancio costa poco: cinese semplificato, russo, spagnolo, portoghese brasiliano, tedesco e francese sono tra le lingue più usate su Steam.

---

## 10. Accessibilità — completa ✅

"Completa" va tradotto in una lista concreta da rispettare al lancio 💡. Riferimento utile: gameaccessibilityguidelines.com.

| Area | Al lancio |
|---|---|
| Vista | Testo e interfaccia scalabili; modalità per daltonici e nessuna informazione affidata solo al colore; contorni ad alto contrasto su personaggi e oggetti interattivi; niente lampeggi rapidi |
| Udito | Segnale visivo per ogni suono importante; didascalie opzionali dei versi ("[il Manager sbuffa]"); volumi separati |
| Movimento | Tasti rimappabili; niente pressioni ripetute obbligatorie; "tieni premuto" sostituibile da un tocco; tutto giocabile con un dito su mobile |
| Comprensione | Obiettivi sempre visibili; pausa in qualsiasi momento; tutorial rigiocabili |
| Comfort | Riduzione di scuotimenti e movimenti della telecamera |
| Tempo | ❓ Opzione "giornata più lunga": aiuta molto, ma va in conflitto con "uguale per tutti" e con le classifiche. 💡 Disponibile, ma i punteggi ottenuti con l'aiuto non entrano in classifica |

---

## 11. Contenuti sensibili e classificazione

- Violenza cartoon ✅: palline di carta, graffette, sedie girevoli lanciate. Nessun sangue, nessuna ferita: i personaggi crollano e si rialzano.
- 💡 Tono: è satira del lavoro tossico. Si ride del Manager e delle situazioni, mai di chi le subisce. Restano fuori dal gioco molestie sessuali e battute su genere, origine, età, disabilità e orientamento.
- Classificazione: questionario dei contenuti su Steam, questionario Apple sulla fascia d'età, questionario IARC su Google Play. Con violenza cartoon verso personaggi umani la classificazione probabile è tra PEGI 7 e PEGI 12, a seconda di quanto è esplicita.

---

## 12. Prezzo, pubblicazione e costi

### 12.1 Prezzo

- Steam: 4,99-9,99 € ✅. Steam trattiene il 30%.
- Mobile ❓ (da decidere prima del porting): a pagamento (2,99-4,99 €) oppure gratis da scaricare, con il gioco completo sbloccabile dopo il primo capitolo. Sul mobile i giochi a pagamento senza prova vendono poco; lo sblocco funziona come una demo senza farne una a parte. Apple e Google applicano una commissione ridotta del 15% sotto il milione di dollari di ricavi annui (in entrambi i casi va attivata).

### 12.2 Chi pubblica ❓

Nel file la risposta è "ricavi? quali ricavi?". Anche se i ricavi fossero pochi, Steam, Apple e Google pagano una persona o una società con dati fiscali e bancari, e tre store sono tre contratti. Va deciso prima di iscriversi:

- chi è il titolare degli account Steam, Apple e Google;
- come si dividono eventuali ricavi tra gli 8;
- di chi è il gioco e cosa succede se qualcuno lascia;
- tutto per iscritto. Per la parte fiscale e legale serve un commercialista o un consulente.

💡 Un account **organizzazione** su Google Play evita la regola dei 12 tester (§13.5), ma richiede un numero D-U-N-S, come l'account organizzazione Apple.

### 12.3 Costi da mettere in conto (piccolo budget ✅)

| Voce | Costo |
|---|---|
| Steam Direct | 100 $ per gioco, recuperabili dopo 1.000 $ di ricavi |
| Apple Developer Program | Circa 99 € l'anno (serve anche per firmare la versione Mac) |
| Google Play Console | 25 $ una tantum |
| Strumenti IA (Scenario, Meshy, ElevenLabs) | Abbonamenti con licenza commerciale, per tutta la produzione |
| Dispositivi di test | Un Android economico, un iPhone usato, accesso a un Mac |
| Facoltativo | Uno Steam Deck per i test |

---

## 13. Produzione

### 13.1 Squadra e ruoli 💡

Ogni area ha un responsabile, non per forza l'unico che ci lavora.

| Ruolo | Di cosa risponde |
|---|---|
| Producer | Sprint, priorità, scadenze, rapporti con gli store |
| Art director | Guida di stile, approvazione degli asset |
| Gameplay (2 persone) | Junior, Manager, progressione |
| Level designer | Livelli, missioni meme, difficoltà |
| Tecnica e build | Piattaforme, prestazioni, integrazioni Steam / Apple / Google |
| Audio | Musica, versi, effetti |
| QA e accessibilità | Test, lista accessibilità, tester esterni |

### 13.2 Metodo

Sprint di due settimane ✅, con 💡 una build giocabile a fine sprint.

### 13.3 Fasi 💡

Stima grezza, da ricalibrare dopo il prototipo.

| Fase | Sprint | Si chiude quando |
|---|---|---|
| Prototipo | 3 | Il livello demo, poi un livello Junior e uno Manager in grafica media, girano su PC e su un telefono e sono divertenti |
| Vertical slice | 3 | Un livello per ruolo con grafica, audio e interfaccia finali: diventa il riferimento di stile |
| Produzione | 8-12 | Tutti i livelli giocabili dall'inizio alla fine |
| Rifinitura | 3-4 | Bug, bilanciamento, lingue, accessibilità, prestazioni sul portatile vecchio |
| Lancio PC | 1-2 | Il gioco è su Steam |
| Mobile | 3-4 | Il gioco è su App Store e Google Play, partendo dalla versione PC già uscita e stabile |

Il PC esce dopo circa 18-24 sprint (8-11 mesi), il mobile dopo 21-28 sprint in tutto (10-13 mesi).

### 13.4 Data d'uscita — quando è pronto ✅ 🔄

Senza una scadenza esterna il rischio non è più il tempo che manca, ma il gioco che non finisce mai. 💡 Per evitarlo:

- **Data bersaglio interna**, decisa alla fine del vertical slice, quando sapete quanto ci mettete davvero a fare un livello. Non va annunciata: serve a voi.
- **Contenuti congelati** all'inizio della rifinitura: da lì in poi solo correzioni. Le idee nuove finiscono in una lista per gli aggiornamenti o per la versione mobile.
- **Pagina Steam** tre mesi prima della data bersaglio ✅, come da piano. Restano comunque obbligatori almeno 30 giorni tra la fee e l'uscita e almeno due settimane di pagina "Prossimamente".
- Evitare le settimane dei saldi di Steam e dei grandi lanci di fine anno, quando l'attenzione va altrove.

Con le fasi del §13.3 il PC esce indicativamente 8-11 mesi dopo l'inizio del prototipo, il mobile qualche mese dopo.

### 13.5 Test

- Solo noi ✅ → ⚠️ problemi:
  - Mac e Linux: servono tester che li usino davvero (già segnalato nel file);
  - Android: tantissimi modelli diversi;
  - **Google Play:** con un account personale nuovo serve un test chiuso con almeno 12 tester iscritti da 14 giorni di fila prima di poter pubblicare. Siete 8: servono persone esterne, meglio 15-20, perché se il numero scende sotto 12 il conteggio riparte.
- 💡 Strumenti: TestFlight per iOS, test chiuso su Google Play, **Steam Playtest** (gratuito, non è una demo) per trovare tester con Mac e Linux.

---

## 14. Steam e lancio

### 14.1 Decisioni

| Voce | Decisione | Nota |
|---|---|---|
| Modello | Direttamente la 1.0 ✅ | |
| Demo | Nessuna ✅ | ⚠️ Senza demo niente Steam Next Fest, una delle vetrine più forti per i giochi piccoli. 💡 Il capitolo 1 è già una demo naturale e costerebbe poco ❓ |
| Funzioni | Achievement, Steam Cloud, classifiche ✅ | 💡 Classifiche per livello e per ruolo |
| Steam Deck | Giocabile ✅ | I comandi touch fatti per il mobile funzionano anche sullo schermo del Deck; col controller si può puntare al Verificato |
| Pagina Steam | Tre mesi prima ✅ | Il minimo obbligatorio è due settimane come "Prossimamente" |
| Trailer e immagini | Li facciamo noi ✅ | Capsule, screenshot, trailer di 30-60 secondi |
| Promozione | Passaparola ✅ | 💡 vedi §14.3 |
| Uscita | Quando è pronto 🔄 | 💡 Data bersaglio interna dopo il vertical slice (§13.4) |

### 14.2 Achievement 💡

Esempi (20-30 al lancio, ognuno con la sua icona):

| Nome | Come si sblocca |
|---|---|
| Posto fisso | Finisci la carriera del Junior |
| Inbox zero | Consegna tutte le pratiche di un livello prima delle 17:00 |
| Poteva essere una mail | Finisci un livello Junior senza entrare in una sola riunione |
| Stampante domata | Sconfiggi la stampante |
| Il merito è mio | Ruba 50 report come Manager |
| Mai visto, mai sentito | Finisci un livello Manager senza farti notare dalle Risorse Umane |
| Dipendente del mese | Tre stelle in tutti i livelli di un capitolo |
| Alle 18:00 in punto | Esci dall'ufficio nell'ultimo secondo utile |

### 14.3 Farsi conoscere 💡

Il passaparola va bene, e il tema aiuta: ogni missione meme è già una clip.

- Clip verticali da 15 secondi per TikTok, Reels e Shorts: una situazione d'ufficio più il titolo del meme.
- LinkedIn, con ironia: chi vive questi meme ogni giorno è lì.
- Gli 8 colleghi hanno già un pubblico perfetto: i loro colleghi.
- Ogni clip porta alla pagina Steam e alle wishlist.

### 14.4 Checklist Steam

- [ ] Iscriversi a Steamworks con i dati legali, fiscali e bancari del titolare (la verifica richiede alcuni giorni lavorativi).
- [ ] Pagare la fee Steam Direct: 100 $ per gioco, recuperabili dopo 1.000 $ di ricavi.
- [ ] Contare almeno 30 giorni tra il pagamento della fee e l'uscita.
- [ ] Rendere pubblica la pagina "Prossimamente" almeno due settimane prima dell'uscita (il piano dice tre mesi).
- [ ] Preparare capsule, screenshot e trailer.
- [ ] Compilare il questionario dei contenuti, con la dichiarazione sull'uso dell'IA.
- [ ] Mettere in conto la revisione di pagina e build da parte di Valve: da 1 a 5 giorni ciascuna.
- [ ] Mettere per iscritto ruoli e divisione dei ricavi.
- [ ] Progettare la lista degli achievement e disegnarne le icone.
- [ ] Configurare e provare Steam Cloud su due PC diversi.
- [ ] Firmare la versione Mac e provare le build Mac e Linux.
- [ ] Preparare la pagina Steam in inglese e italiano.

### 14.5 Checklist mobile 🔄 (dopo il lancio PC)

- [ ] Iscriversi all'Apple Developer Program e a Google Play Console (con D-U-N-S se come organizzazione).
- [ ] Scrivere una privacy policy pubblicata online: entrambi gli store chiedono il link, e un questionario sui dati raccolti.
- [ ] Compilare i questionari per la fascia d'età (Apple e IARC).
- [ ] Preparare screenshot per telefono e tablet, in entrambe le lingue.
- [ ] Test con TestFlight (iOS) e test chiuso con 12+ tester per 14 giorni (Android, account personale).
- [ ] Mettere in conto la revisione di Apple e Google prima della pubblicazione.

---

## 15. Rischi da tenere d'occhio

| Rischio | Perché | Cosa fare 💡 |
|---|---|---|
| Difficoltà alta e pubblico occasionale | Tirano in direzioni opposte (dal file) | 1 stella facile, 3 stelle difficili; progressione come aiuto (§4.7) |
| Tre piattaforme PC, test solo interni | Mac e Linux non provati (dal file) | Steam Playtest, tester esterni (§13.5) |
| Il mobile allarga il progetto | Due store in più, touch, tanti dispositivi, regole diverse | Deciso: PC prima, mobile dopo ✅; controlli pensati per il touch da subito |
| Gioco che non finisce mai | "Quando è pronto" non ha una scadenza, e le idee nuove arrivano sempre | Data bersaglio interna e contenuti congelati (§13.4) |
| Coerenza degli asset IA | Strumenti e persone diverse | Guida di stile e art director (§7.3) |
| Diritti sui meme | Molte immagini di meme sono foto protette | Ricreare le situazioni, mai le immagini (§4.6) |
| Tono della satira | Un Manager tossico giocabile può sembrare celebrato | La battuta è sempre su di lui (§4.4, §11) |
| Accessibilità "completa" | Impegno grande per un team nel tempo libero | Lista concreta e misurabile (§10) |
| Accordo tra gli 8 | Nessuno ha ancora deciso chi incassa e come | Accordo scritto prima di iscriversi agli store (§12.2) |
| Regola dei 12 tester Android | Il team è di 8 persone | Reclutare 15-20 tester esterni o account organizzazione |

---

## 16. Domande aperte

Risolte il 15 ottobre: il mobile esce dopo il PC ✅, il gioco esce quando è pronto ✅, il gameplay a giornate a tempo è confermato ✅.

1. **Titolare e ricavi:** chi pubblica e come vi dividete eventuali ricavi? Da chiarire prima di iscrivervi a Steamworks.
2. **Demo:** il capitolo 1 come demo, per partecipare a uno Steam Next Fest?
3. **Controller:** lo supportiamo, per puntare al Verificato su Steam Deck?
4. **"Giornata più lunga":** la includiamo, e come la trattiamo in classifica?
5. **Titolo del gioco:** *Open Space* è solo un nome in codice.
6. **Quale mobile:** iOS, Android o entrambi? Prima del porting.
7. **Prezzo sul mobile:** a pagamento o gratis con sblocco? Prima del porting.
8. **Progressi tra PC e telefono:** servono? Prima del porting.
9. **Achievement e classifiche su mobile:** al lancio mobile o dopo?
10. **Gommosità:** quanta fisica nei movimenti dei personaggi? Si decide giocando il livello demo.
