# Guida di stile — da compilare

*Responsabile: art director. Nessun asset entra in `assets/` se non rispetta questa guida.*

Quello che è già deciso è nelle specifiche (§7). Qui vanno le regole operative, da compilare durante il prototipo e chiudere con il vertical slice.

## Parole chiave

3D cartoon · ufficio · satira · colori saturi · leggibile su un telefono · *(aggiungete le vostre)*

## Riferimenti

10-15 immagini in `guida-di-stile/riferimenti/`, ognuna con una riga che dice cosa prenderne (il colore, la silhouette, la luce...).

| File | Cosa prendere |
|---|---|
| | |

## Palette

| Uso | Nome | Hex |
|---|---|---|
| Junior | | |
| Manager | | |
| Risorse Umane | | |
| Pareti e pavimento | | |
| Oggetti interattivi | | |
| Urgente / pericolo | | |

Regola: ogni coppia di colori importante si distingue anche in scala di grigi e con un simulatore di daltonismo.

## Personaggi

- Proporzioni: *(es. testa = un terzo dell'altezza)*
- Junior: camicia troppo grande, badge al collo, zainetto.
- Manager: abito lucido, cravatta enorme, abbronzatura, sorriso fisso.
- Test obbligatorio: il personaggio si riconosce dalla sola silhouette, alto un centimetro sullo schermo di un telefono.

## Shading e contorni

- Toon shading a *(2 o 3)* bande di luce.
- Contorno: colore *(...)*, spessore *(...)*.
- Niente texture fotografiche.

## Budget tecnici

Vedi specifiche §6.2 (triangoli, texture, luci, draw call).

## Pipeline IA

Scrivete qui i prompt di base per Scenario e Meshy e le impostazioni usate, così tutti generano con le stesse parole e gli stessi parametri.

```
Prompt base personaggi:
Prompt base oggetti:
Impostazioni Meshy:
```

## Checklist di approvazione di un asset

- [ ] Rispetta palette, proporzioni e contorni
- [ ] Triangoli entro il budget
- [ ] Texture sull'atlante, alla dimensione giusta
- [ ] Nome del file con il prefisso giusto (vedi `CLAUDE.md`)
- [ ] File sorgente salvato in `source_assets/`
- [ ] Licenza commerciale dello strumento verificata
