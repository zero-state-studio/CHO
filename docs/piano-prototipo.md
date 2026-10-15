# Piano del prototipo — Sprint 1 e 2

*Versione 0.1 del 15 ottobre 2026. Riferimento: specifiche §13.3, fase "Prototipo".*

## Obiettivo

In quattro settimane: **un livello Junior e un livello Manager, in grafica grigia, che girano su PC e su un telefono.**

Alla fine dovete saper rispondere a quattro domande:

1. La giornata a tempo è divertente, sia da Junior sia da Manager?
2. Il punta-e-clicca funziona davvero col dito, su uno schermo da 6 pollici?
3. Il gioco gira sul portatile più vecchio e sul telefono più vecchio del team?
4. Quante ore servono per portare in Godot un modello generato con l'IA, pulito e pronto? È il numero che serve per stimare la produzione.

## Ipotesi

- 8 persone, circa 5 ore a testa a settimana: un'ottantina di ore per sprint in tutto. Se sono di più o di meno, spostate i compiti "se avanza tempo".
- Se partite lunedì 19 ottobre: **Sprint 1** dal 19 ottobre al 1° novembre, **Sprint 2** dal 2 al 15 novembre.
- I ruoli sono quelli delle specifiche (§13.1). Chi ricopre quale ruolo lo decidete voi alla prima riunione.

## Fuori dal prototipo

Grafica finale, musica, menu completi, negozio ed equipaggiamento, Steam, traduzioni (le chiavi di testo invece sì, da subito), salvataggio tra una sessione e l'altra. Tutto questo arriva col vertical slice o dopo.

## Ritmo di ogni sprint

| Quando | Cosa | Durata |
|---|---|---|
| Primo giorno | Pianificazione: ognuno sceglie i suoi compiti | 30 min, anche online |
| Metà sprint | Aggiornamento scritto nel canale del team: cosa ho fatto, cosa mi blocca | 5 min a testa |
| Ultimo giorno | Demo e retrospettiva: si gioca, si decide cosa tenere, cambiare, buttare | 45 min |

Regola: alla demo si gioca la **build esportata**, mai il progetto aperto nell'editor. Una persona, un compito alla volta, finito prima di prenderne un altro.

---

## Sprint 1 — "Si cammina, si lavora, il tempo passa"

**Obiettivo:** il Junior si muove nell'ufficio grigio, porta pratiche e caffè mentre l'orologio corre, su PC e su un telefono.

| Ruolo | Compiti | Fatto quando |
|---|---|---|
| Producer | Repository Git con LFS a partire da questo scheletro; bacheca dei compiti; calendario delle riunioni; censimento dei dispositivi del team (Mac, Linux, Android, iPhone, portatile più vecchio) | Tutti hanno aperto il progetto e fatto almeno un commit |
| Tecnica e build | Godot 4.7.2 installato da tutti; esportazione Windows e Android funzionanti; contatore di fps a schermo nelle build di debug | Una build Android gira su un telefono vero entro la prima settimana |
| Gameplay 1 | Telecamera isometrica ortogonale; zoom con rotella, pizzico e pulsanti +/−; movimento col clic o col tocco su navmesh (`NavigationAgent3D`) | Si attraversa l'ufficio con un dito senza incastrarsi |
| Gameplay 2 | `WorkdayClock` (9:00 → 18:00 in 5 minuti) con segnale alla pausa pranzo; interazione "tocco un oggetto → il personaggio ci va → barra di avanzamento"; trasporto di una pratica; Energia e Stress in versione base | Una giornata completa dall'inizio alla fine, con vittoria e sconfitta |
| Level designer | Ufficio grigio con primitive: 8 scrivanie, stampante, macchinetta del caffè, sala riunioni, ufficio del Manager; i due livelli del prototipo disegnati su carta, con obiettivi e ostacoli | Mappa giocabile e i due livelli su carta |
| Art director | Prime 10-15 immagini di riferimento in `docs/guida-di-stile/riferimenti/`; prova della pipeline IA con un personaggio (Junior) e un oggetto (stampante), cronometrando ogni passaggio | Due modelli puliti dentro Godot e le ore di ogni passaggio scritte |
| Audio | 10-15 effetti segnaposto (clic, passi, stampante, caffè, campanella delle 18:00); 3 versi di prova del Junior generati con ElevenLabs | Tre persone capiscono l'emozione dei versi senza guardare lo schermo |
| QA e accessibilità | Protocollo di playtest: cosa osservare, cinque domande da fare dopo la partita; controllo che nessuna informazione stia solo nel colore | Protocollo pronto per lo Sprint 2 |

**Se avanza tempo:** pareti e mobili che diventano trasparenti davanti al personaggio; build Mac e Linux.

---

## Sprint 2 — "Due ruoli, una giornata"

**Obiettivo:** si gioca un livello Junior completo e un livello Manager completo, e li provano persone fuori dal team.

| Ruolo | Compiti | Fatto quando |
|---|---|---|
| Gameplay 1 | Manager in versione base: lancio delle pratiche (trascina e rilascia), zona riunione, furto del merito; Ego e Bonus | Il livello Manager si vince e si perde |
| Gameplay 2 | Junior completo: colleghi "hai un minuto?", sala riunioni che risucchia, stampante inceppata; obiettivo principale e due secondari; da 1 a 3 stelle; schermata di fine livello; checkpoint alle 13:00 | Il livello Junior si chiude con 1, 2 o 3 stelle |
| Level designer | Risorse Umane con giro di controllo e cono visivo; bilanciamento dei due livelli; prima scaletta dei 30 livelli a partire dalle missioni meme | Entrambi i livelli si finiscono, ma per le 3 stelle servono più tentativi |
| Tecnica e build | Pulsanti delle abilità a schermo per il touch; misura delle prestazioni sul portatile e sul telefono più vecchi (fps medi e minimi); build per tutti i playtester | Numeri di fps scritti nel resoconto dello sprint |
| Art director | Guida di stile v1 (palette, proporzioni, contorni); segnaposto che distinguono Junior, Manager e Risorse Umane per forma, non solo per colore | Si riconosce chi è chi a colpo d'occhio sul telefono |
| Audio | Versi di base per Junior, Manager e Risorse Umane; effetti per le azioni nuove; insieme a Gameplay, un segnale visivo per ogni suono importante | Il livello si gioca anche senza audio |
| QA e accessibilità | Playtest con almeno 5 persone esterne al team, di cui almeno una su Mac e una sul telefono | Resoconto con i problemi in ordine di gravità |
| Producer | Riunione di chiusura: si passa al vertical slice? cosa cambia? Aggiornare le specifiche con quello che si è imparato; pianificare lo Sprint 3 | Decisione presa e scritta nelle specifiche |

**Se avanza tempo:** vibrazione al tocco su mobile; la prima clip da 15 secondi per i social (specifiche §14.3).

---

## Il controllo di fine prototipo

Si passa al vertical slice se:

- [ ] almeno 3 playtester esterni su 5 vogliono rigiocare un livello;
- [ ] entrambi i ruoli sono divertenti (se uno dei due non lo è, il vertical slice si concentra su quello);
- [ ] un livello si gioca col dito senza tocchi sbagliati frequenti;
- [ ] il telefono più vecchio tiene almeno 30 fps e il portatile più vecchio almeno 60 fps a 720p, oppure c'è un piano concreto per arrivarci;
- [ ] il tempo medio per pulire un modello IA è misurato e la stima della produzione (specifiche §13.3) è aggiornata.

## Rischi di questo prototipo

| Rischio | Cosa fare |
|---|---|
| Tocchi imprecisi su schermi piccoli | Zone di tocco più grandi degli oggetti; evidenziare l'oggetto toccato prima che il personaggio parta |
| Personaggi nascosti dietro mobili e pareti | Dissolvenza degli oggetti tra telecamera e personaggio, già nello Sprint 1 se c'è tempo |
| Pulizia degli asset IA più lunga del previsto | È proprio quello che il prototipo deve misurare: meglio scoprirlo ora |
| Tempo libero discontinuo | Compiti piccoli, uno alla volta; chi si blocca lo scrive a metà sprint |
