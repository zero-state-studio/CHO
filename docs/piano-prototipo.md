# Piano del prototipo — Sprint 1, 2 e 3

*Versione 0.3 del 15 ottobre 2026: Sprint 1 solo su Mac, mobile e Blender rinviati. Riferimento: specifiche §13.3, fase "Prototipo".*

## Obiettivo

Prima un **livello demo** per provare movimenti, personaggi gommosi, asset e suoni; poi **un livello Junior e un livello Manager**, in grafica di qualità media, che girano su PC e su un telefono.

Alla fine dovete saper rispondere a cinque domande:

1. La giornata a tempo è divertente, sia da Junior sia da Manager?
2. Il punta-e-clicca funziona davvero col dito, su uno schermo da 6 pollici?
3. Il gioco gira sul portatile più vecchio e sul telefono più vecchio del team?
4. Quanto tempo e quanti crediti servono per ogni tipo di asset (personaggio, oggetto, texture, verso, effetto)? È il numero che serve per stimare la produzione.
5. Quanta gommosità: i personaggi fanno ridere senza far sbagliare le azioni?

## Ipotesi

- 8 persone, circa 5 ore a testa a settimana: un'ottantina di ore per sprint in tutto. Se sono di più o di meno, spostate i compiti "se avanza tempo".
- Se partite lunedì 19 ottobre: **Sprint 1** dal 19 ottobre al 1° novembre, **Sprint 2** dal 2 al 15 novembre, **Sprint 3** dal 16 al 29 novembre.
- Il prototipo passa da 2 a 3 sprint per fare spazio al livello demo (le specifiche sono aggiornate).
- Qualità grafica media: Meshy, Scenario ed ElevenLabs nelle modalità più leggere; personaggi costruiti in Godot da forme primitive; poligoni degli oggetti Meshy tenuti bassi con le opzioni di Meshy e le impostazioni d'importazione di Godot. Blender è rinviato. La rifinitura arriva con il vertical slice.
- I ruoli sono quelli delle specifiche (§13.1). Chi ricopre quale ruolo lo decidete alla prima riunione.

## Fuori dal prototipo

Grafica finale, menu completi, negozio ed equipaggiamento, Steam, traduzioni (le chiavi di testo invece sì, da subito), salvataggio tra una sessione e l'altra.

## Ritmo di ogni sprint

| Quando | Cosa | Durata |
|---|---|---|
| Primo giorno | Pianificazione: ognuno sceglie i suoi compiti | 30 min, anche online |
| Metà sprint | Aggiornamento scritto nel canale del team: cosa ho fatto, cosa mi blocca | 5 min a testa |
| Ultimo giorno | Demo e retrospettiva: si gioca, si decide cosa tenere, cambiare, buttare | 45 min |

Regole: alla demo si gioca la **build esportata**, mai il progetto aperto nell'editor. Una persona, un compito alla volta, finito prima di prenderne un altro.

---

## Sprint 1 — Il livello demo

**Obiettivo:** una scena di prova, non un livello del gioco, in cui si provano movimento, personaggi gommosi, interazioni, asset e suoni.

**Piattaforma di riferimento: il Mac**, nell'editor e in una build macOS esportata (firma ad-hoc, senza notarizzazione). I controlli seguono comunque le regole del mobile: un solo puntatore, niente azioni solo da tastiera o col tasto destro.

**Cosa contiene** (`game/levels/demo/demo.tscn`):

| Zona | Cosa si prova |
|---|---|
| Movimento | Spazio aperto, corridoio stretto tra scrivanie, una porta, una rampa e tre gradini; bersagli grandi e piccoli da cliccare |
| Interazione | Stampante, macchinetta del caffè e scrivania: clicco l'oggetto, il personaggio ci va, parte la barra di avanzamento; prendere una pratica e consegnarla |
| Fisica | Scatole e sedie da urtare, una sedia girevole da spingere, un lanciatore di palline di carta, un pulsante "crollo" |
| Vetrina | Tutti i modelli di `assets/models/` e i personaggi in fila, per confrontare scala e stile, con il numero di triangoli; si popola da sola leggendo le cartelle |
| Audio | Ogni verso ed effetto si può far partire e mostra il suo segnale visivo |

**Pannello di debug** (solo nelle build di debug, tutto a clic): fps e draw call, cambio Junior / Manager, slider della gommosità (0 rigido, 1 oscillazioni e schiacciamento, 2 ragdoll parziale sulle reazioni), velocità del tempo, zoom, dissolvenza delle pareti, reset della scena.

| Ruolo | Compiti | Fatto quando |
|---|---|---|
| Producer | Repository Git con LFS; `.env` per chi genera asset; bacheca dei compiti; censimento dei Mac del team (Apple Silicon o Intel); **budget di crediti** per Meshy, Scenario ed ElevenLabs in questo sprint | Tutti hanno aperto il progetto e fatto un commit; budget deciso |
| Tecnica e build | Godot 4.7.2 per tutti; esportazione macOS universale con firma ad-hoc; pannello di debug | La build esportata si apre sui Mac del team |
| Gameplay 1 | Telecamera isometrica; zoom con rotella e pulsanti +/−; movimento col clic su navmesh; zona movimento | Si attraversa la zona movimento col solo mouse o trackpad senza incastrarsi |
| Gameplay 2 | Gommosità procedurale (oscillazioni, schiacciamento e allungamento, ragdoll parziale); interazione e trasporto; zona fisica | Lo slider della gommosità funziona su tutti e tre i valori |
| Level designer | Allestimento delle cinque zone; disegno su carta dei livelli Junior e Manager | Zone complete e i due livelli su carta |
| Art director | Junior, Manager e un collega costruiti in Godot da forme primitive; 8 oggetti da Meshy con poligoni bassi; texture, icone e due concept da Scenario; prime voci della guida di stile | Vetrina piena; tempi e crediti per asset annotati qui sotto |
| Audio | Con ElevenLabs: 3 versi a testa per Junior e Manager, 10 effetti, una musica d'attesa segnaposto; zona audio | Tre persone capiscono l'emozione dei versi senza guardare lo schermo |
| QA e accessibilità | Protocollo di playtest; registro degli asset sempre aggiornato; controllo che nessuna informazione stia solo nel colore | Protocollo pronto; registro completo |

**Se avanza tempo:** varianti del collega con accessori diversi.

**Rinviato** (dopo lo Sprint 1, quando si riprende il mobile o serve Blender):

- esportazione Windows, Linux, Android e iOS, e prova su un telefono vero;
- zoom col pizzico e test dei controlli col dito su uno schermo da 6 pollici;
- Blender per tutti: script dei personaggi e pulizia dei modelli Meshy (`tools/blender/` resta vuota).

---

## Sprint 2 — Il livello Junior

**Obiettivo:** un livello Junior completo, dalle 9:00 alle 18:00.

| Ruolo | Compiti | Fatto quando |
|---|---|---|
| Gameplay 1 | `WorkdayClock` (9:00 → 18:00 in 5 minuti); Energia e Stress; checkpoint alla pausa pranzo | Una giornata completa, con vittoria e sconfitta |
| Gameplay 2 | Ostacoli: colleghi "hai un minuto?", sala riunioni che risucchia, stampante inceppata | Ogni ostacolo funziona e si vede arrivare |
| Level designer | Il livello costruito dal disegno su carta; obiettivo principale e due secondari; da 1 a 3 stelle; bilanciamento | Si chiude con 1, 2 o 3 stelle; per le 3 stelle servono più tentativi |
| Tecnica e build | Pulsanti delle abilità a schermo; schermata di fine livello; prima misura delle prestazioni su portatile e telefono più vecchi | Numeri di fps annotati |
| Art director | Varianti dei colleghi; l'ufficio del livello con gli oggetti della vetrina; guida di stile v1 | Junior, Manager e colleghi si distinguono per forma sul telefono |
| Audio | Versi dei colleghi; effetti delle azioni nuove; segnale visivo per ogni suono importante | Il livello si gioca anche senza audio |
| QA e accessibilità | Playtest interno: ognuno gioca 3 volte e compila il protocollo | Problemi in ordine di gravità |
| Producer | Decisione sulla gommosità, presa giocando il livello demo, scritta nelle specifiche | Specifiche aggiornate |

---

## Sprint 3 — Il livello Manager e i playtest

**Obiettivo:** un livello Manager completo, nello stesso ufficio del livello Junior, e i primi playtest con persone esterne.

| Ruolo | Compiti | Fatto quando |
|---|---|---|
| Gameplay 1 | Manager: lancio delle pratiche (trascina e rilascia), zona riunione, furto del merito; Ego e Bonus | Il livello Manager si vince e si perde |
| Gameplay 2 | Risorse Umane con giro di controllo e cono visivo; correzioni dal playtest del livello Junior | I problemi gravi del playtest sono risolti |
| Level designer | Livello Manager nello stesso ufficio (il "gancio" delle specifiche §2); bilanciamento; prima scaletta dei 30 livelli | Entrambi i livelli si finiscono, ma le 3 stelle sono una sfida |
| Tecnica e build | Build per i playtester (Windows, Mac, Android); misura finale delle prestazioni | Fps del portatile e del telefono più vecchi annotati |
| Art director | Risorse Umane e CEO; ufficio del Manager; lista di cosa serve per il vertical slice | Personaggi nuovi nella vetrina |
| Audio | Versi delle Risorse Umane; tema del Manager segnaposto | Il Manager ha il suo tema |
| QA e accessibilità | Playtest con almeno 5 persone esterne al team, di cui almeno una su Mac e una sul telefono | Resoconto con i problemi in ordine di gravità |
| Producer | Riunione di chiusura: si passa al vertical slice? Cosa cambia? Pianificazione dello Sprint 4 | Decisione scritta nelle specifiche |

**Se avanza tempo:** vibrazione al tocco su mobile; la prima clip da 15 secondi per i social (specifiche §14.3).

---

## Il controllo di fine prototipo

Si passa al vertical slice se:

- [ ] almeno 3 playtester esterni su 5 vogliono rigiocare un livello;
- [ ] entrambi i ruoli sono divertenti (se uno non lo è, il vertical slice si concentra su quello);
- [ ] un livello si gioca col dito senza tocchi sbagliati frequenti;
- [ ] la gommosità fa ridere e nessun playtester ha fallito un'azione per colpa della fisica;
- [ ] il telefono più vecchio tiene almeno 30 fps e il portatile più vecchio almeno 60 fps a 720p, oppure c'è un piano concreto per arrivarci;
- [ ] tempi e crediti per ogni tipo di asset sono misurati e la stima della produzione (specifiche §13.3) è aggiornata.

## Rischi di questo prototipo

| Rischio | Cosa fare |
|---|---|
| La gommosità rende il controllo impreciso | Il movimento resta guidato dalla navigazione; la fisica interviene solo sulle reazioni; slider nel livello demo |
| Tocchi imprecisi su schermi piccoli | Zone di tocco più grandi degli oggetti; evidenziare l'oggetto toccato prima che il personaggio parta |
| Personaggi nascosti dietro mobili e pareti | Dissolvenza degli oggetti tra telecamera e personaggio |
| Crediti delle API finiti a metà sprint | Budget per sprint, lotti piccoli, ok prima di ogni generazione |
| Pulizia degli asset IA più lunga del previsto | È quello che il livello demo deve misurare: meglio scoprirlo ora |
| Tempo libero discontinuo | Compiti piccoli, uno alla volta; chi si blocca lo scrive a metà sprint |

---

## Note dello Sprint 1

*Da compilare durante lo sprint.*

| Asset | Strumento | Tempo | Crediti | Note |
|---|---|---|---|---|
| Personaggi Junior, Manager e collega | Godot, costruiti da codice | — | 0 | 2.300-2.500 triangoli ciascuno; una draw call più il contorno |
| Texture ripetibili: moquette e intonaco, 512 px (2 varianti ciascuna) | Scenario, PATINA Material | circa 3 min di generazione | 14 CU (7 a texture) | Ha prodotto anche mappe PBR non richieste, senza costi in più; servono le mipmap all'import |
| Icone con sfondo trasparente: Energia, Stress, caffè, pratica (2 varianti ciascuna) | Scenario, GPT Image 2.5 Flare | 15-30 s ciascuna | 24 CU (6 a icona) | Tutte usabili al primo colpo |
| Concept di Junior e Manager (2 varianti ciascuno) | Scenario, FLUX.2 Klein 9b | circa 40 s ciascuno | 4 CU (2 a concept) | Lotto Scenario completo: 42 CU, circa 10 minuti con revisione e download |
| Versi in grammelot di Junior e Manager (6, una versione ciascuno) | ElevenLabs v4 (via Scenario), voci preimpostate Liam e Brian | 6-15 s ciascuno | 96 CU (16 a verso) | Voice Design non disponibile su Scenario; grammelot da verificare a orecchio |
| Effetti sonori (10, una versione ciascuno) | ElevenLabs Sound Effects 2 (via Scenario) | 4-8 s ciascuno | 300 CU (30 a effetto, fissi anche per 1 s) | Sonilo V1.1 avrebbe fatto gli stessi 10 effetti per 13 CU |
| Musica d'attesa in loop, 60 s | ElevenLabs Music v2.5 (via Scenario) | 15 s | 30 CU | Convertita in OGG e resa ciclica con dissolvenza incrociata; lotto audio completo: 426 CU in circa 6 minuti |
| Oggetti, lotto 1: scrivania e sedia girevole | Meshy, Smart Topology `meshy-t2.5` + texture `meshy-6` a 2K | 2-5 min ciascuno | 60 crediti (30 scartati) | Il primo tentativo è scartato: forma sbagliata e faccine nella texture, perché il prompt diceva "cartoon, toy-like". Approvati con prompt da oggetto inanimato: 1.174 e 1.206 triangoli. Origine al centro, appoggiati a terra dal gioco |
| Oggetti, lotto 2: stampante, macchinetta del caffè, schedario, pianta, pallina di carta, pila di pratiche | Meshy, stesse impostazioni | 2-4 min ciascuno | 80 crediti (75 per 5 oggetti + 5 per la forma della pila) | Approvata solo la stampante (1.004 triangoli). Senza colori espliciti nel prompt della texture Meshy sceglie i colori a caso; i prompt corretti sono in `tools/meshy/prompts.json`. La texture della pila di pratiche è fallita 2 volte ("too complex"), senza addebito. Totale Meshy dello sprint finora: 140 crediti |

Prestazioni misurate:

- 16 ottobre, build release finale (tutti gli asset, mipmap attive), Mac mini M4 Pro (Apple Silicon), 1280×720, vsync spento, `-- --benchmark`: 480-900 fps in tutte le zone con gommosità 0, 1 e 2; frame peggiore sotto i 9 ms. La gommosità non cambia gli fps in modo misurabile.
- Draw call per zona: movimento 110, interazione 125, fisica 129-131, vetrina 109, audio 158. Tutte sopra il budget di 100 per il mobile (specifiche §6.2): ogni blocco del livello, cartello e tasto audio è una draw call a sé.
- Il Mac di prova è molto più potente del "portatile vecchio" delle specifiche: va misurato su un Mac del team più datato (e su un Mac Intel, che la build universale supporta).

Decisioni prese:

- 15 ottobre: lo Sprint 1 gira solo su macOS (editor e build esportata universale, firma ad-hoc); mobile e Blender rinviati (specifiche §7.3 🔄).
- 15 ottobre: i personaggi si costruiscono in Godot da codice, con un solo scheletro e una sola mesh skinnata per personaggio (2.300-2.500 triangoli, una draw call più il contorno).
- 15 ottobre: Scenario ed ElevenLabs si usano dai server MCP con il login dell'utente, salvando prompt e parametri in `tools/<strumento>/prompts.json` (non ci sono chiavi API per questi due servizi).
- 15 ottobre: audio con l'opzione "tutto ElevenLabs" (426 CU), invece degli effetti Sonilo (139 CU in tutto).
- 16 ottobre: la pallina di carta resta una sfera fatta in Godot, senza modello Meshy.
- I `.glb` di Meshy hanno l'origine al centro: il gioco li appoggia a terra da solo (`ModelFit`), non si ritoccano i file.
- Gommosità: da decidere giocando il livello demo (Sprint 2, compito del producer). Vedi il riepilogo della tappa 10 qui sotto.

### Riepilogo della tappa 10 (16 ottobre)

**Funziona** (verificato con i test automatici, gli screenshot e la build esportata):

- le cinque zone si attraversano col solo mouse senza incastrarsi (test: 12 tappe su 12, comprese porta, rampa, pedana, gradini e corridoio da 1,2 m);
- Junior, Manager e collega costruiti in Godot, con camminata procedurale e gommosità regolabile da 0 a 2;
- interazioni con stampante, macchinetta del caffè e scrivania, pratica in mano, oggetti fisici, palline di carta, crollo (test: 11 controlli);
- vetrina automatica con triangoli e "fuori budget"; zona audio automatica con segnali visivi e volumi separati;
- build macOS universale firmata ad-hoc, con la modalità benchmark.

**Non verificato o da sistemare:**

- nessuno ha ancora giocato il livello a mano: il comportamento della gommosità è stato visto solo negli screenshot;
- i versi in grammelot non sono stati ascoltati da una persona (servono tre persone che capiscano l'emozione senza guardare);
- draw call sopra il budget mobile in tutte le zone (vedi sopra);
- la build non è stata aperta su un altro Mac né su un Mac Intel;
- da approvare dall'art director: le varianti di Scenario, l'ultimo lotto Meshy (macchinetta, schedario, pila di pratiche, pianta), i colori accesi della scrivania Meshy.

**Da decidere sulla gommosità** (giocando il livello demo con lo slider):

- 0, rigido: legge bene ma è piatto; resta solo il crollo stilizzato;
- 1, molle e schiacciamento: braccia, testa, cravatta e badge oscillano, il corpo si allunga e si schiaccia; proposta come valore di partenza;
- 2, ragdoll parziale negli urti e nel crollo: il più comico, da verificare se distrae o se sembra un errore;
- domande aperte: valore di default; ragdoll in tutti gli urti o solo nel crollo; quanto spesso il lanciatore tira (ora ogni 2 s); se il personaggio debba fermarsi un attimo dopo un urto (ora non si ferma mai).

