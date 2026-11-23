# 004 — Quanto costa lo stile? OOP ereditarietà vs composizione vs FP

La stessa operazione su una sequenza di interi, 3 implementazioni, stesso linguaggio e toolchain.

- **Ereditarietà:** tre sottoclassi di una classe base con override del metodo `apply`.
- **Composizione:** un oggetto riutilizzabile che combina tre campi immutabili (`multiplier`, `offset`, `mask`), con lo stesso metodo `apply`.
- **FP:** tre funzioni di prima classe con chiusure che catturano i parametri.

Tutte calcolano `((x * multiplier + offset) ^ mask) & 1023` con gli stessi parametri e iterazioni. L'eseguibile stampa conteggio, checksum e tempo del solo ciclo.

## Perché non è un confronto assoluto

Il paradigma non determina da solo il codice compilato. Qui *variano anche* dispatch virtuale, accesso a campi e chiusure, per cui non si può dedurre "OOP è più pesante" oppure "FP è più veloce" in generale. Un compilatore può devirtualizzare, incorporare, specializzare o eliminare i costi.

I dati registrano:
- dimensioni degli EXE; differenza rispetto a CLI 000 nello **stesso runner**;
- dimensioni delle sezioni PE (`dumpbin /headers`) e dipendenze (`dumpbin /dependents`);
- dimensione totale dei file oggetto (solo un indicatore: NON equivale al contributo del codice nel binario);
- tempi di compilazione, separando il primo passaggio dai test di runtime;
- sette esecuzioni native con mediana; checksum uguale per tutti e tre.

Il test riproducibile è nella [CI Paradigms and binary anatomy](../../.github/workflows/paradigms-and-anatomy.yml). Scarica l'artefatto `paradigms-windows-x64` dopo una build verde. `measurements.json` conterrà i numeri reali, non stimati.

**Nota:** eseguibili molto semplici finiscono spesso dominati dal runtime comune e mostrano differenze minime. È un risultato interessante, non un problema del benchmark.
