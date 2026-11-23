# 005 — Radiografia degli eseguibili GUI Haxe

**Domanda:** i 13,42 MB di HaxeUI rispetto ai 6,51 MB di hxWidgets diretto corrispondono a più **codice macchina**, più dati/metadata o più risorse?

La CI ricompila 000, 003 e 002 con le **stesse impostazioni di prima**, aggiungendo soltanto `-D HXCPP_MAP_FILE=...`. Questo usa una funzionalità già prevista dal linker MSVC configurato da hxcpp, che genera una mappa di simboli pubblici. Analizziamo quindi:

- dimensione esatta dell'EXE e sezioni PE (`.text`, `.rdata`, `.data`, `.pdata`, `.rsrc`, ...), con dimensioni raw allineate;
- file `*.map` prodotto dal linker, con nomi e provenienza di simboli pubblici (quando disponibili);
- dipendenze dinamiche con `dumpbin /dependents`;
- file oggetto Haxe/hxcpp e librerie wxWidgets **prima del collegamento**, tenendo questa misura separata dalle dimensioni finali.

La somma delle dimensioni degli oggetti e librerie pre-link **non va interpretata come quantità di byte nell'EXE**: il linker può escludere funzioni, unificare sezioni e aggiungere allineamenti. E il numero di simboli in una mappa non è una misura dei loro byte.

### Output

Il workflow [Code anatomy and paradigms](../../.github/workflows/code-anatomy.yml) pubblica `gui-binary-anatomy-windows` con `measurements.json`, `000-cli.map`, `003-direct.map`, `002-haxeui.map`, e gli output di `dumpbin`.

Lo scopo di questa prima fase è ottenere **prove verificabili** sulla ripartizione tra codice, dati e risorse. Per attribuire esattamente ogni byte a una singola libreria dovremo fare un'analisi successiva dei contributi di sezione o dei file PDB: non inventiamo percentuali attribuite a HaxeUI, hxWidgets o hxcpp.
