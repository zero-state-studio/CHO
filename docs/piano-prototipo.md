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
| | | | | |

Prestazioni misurate:

Decisioni prese:
