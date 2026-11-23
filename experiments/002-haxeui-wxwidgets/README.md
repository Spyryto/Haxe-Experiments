# Esperimento 002 — HaxeUI + wxWidgets su Windows

**Domanda:** mantenendo *esattamente lo stesso* `Main.hx` della demo web 001, quanto costa ottenere una GUI desktop con veri controlli Windows?

Sorgente: [001 / Main.hx](../001-haxeui/src/Main.hx). Qui cambiamo solo il backend e le opzioni di build.

## Cosa produce la CI

Workflow **[Native wxWidgets](../../.github/workflows/native-wxwidgets.yml)**. Il job Windows:

1. Configura Haxe 4.3.7, hxcpp, HaxeUI 1.7.0 e hxWidgets 1.12.0.
2. Compila **wxWidgets 3.1.3 statico** con MSVC 64 bit (oppure recupera dalla cache la libreria già compilata).
3. Compila lo stesso sorgente della demo web via Haxe → hxcpp → C++/wxWidgets.
4. Avvia il processo con un timeout e verifica che non termini subito. Cerca anche una finestra Win32: nei runner CI headless potrebbe non essere osservabile.
5. Misura le dimensioni dell'EXE, delle DLL affiancate, del pacchetto complessivo e delle dipendenze con `dumpbin /dependents`. Registra un tempo **approssimativo** per osservare la finestra e l'uso di RAM, se disponibili.
6. Compila anche l'esperimento 000 CLI con la stessa ABI MSVC, registrando la dimensione dell'EXE e il rapporto GUI/CLI.
7. Crea l'artefatto `haxeui-wxwidgets-windows-x64`, contenente la cartella da distribuire e un file `measurements.json`.

**Non usare l'esito della sola compilazione come prova che la GUI funzioni visivamente.** Il controllo definitivo dell'aspetto e dell'interazione va effettuato su un Windows reale.

## Avvio

Scarica l'artefatto ZIP dalla pagina [Actions](https://github.com/Spyryto/Haxe-Experiments/actions/workflows/native-wxwidgets.yml), estrailo e lancia `HaxeUI-Windows.exe`. Non serve installare Haxe.

L'app è un **simulatore**: cambiare la barra di avanzamento non installa PHP. Il codice è condiviso con la versione web così da isolare il costo del backend.

## Perché wxWidgets 3.1.3?

È la versione utilizzata nei workflow upstream di HaxeUI/hxWidgets, una scelta iniziale per verificare la compatibilità; **non è una raccomandazione per prodotti finali**. Prima di distribuire un programma reale bisognerà aggiornare a una release wxWidgets mantenuta e verificare supporto e patch di sicurezza.

## Misure e limitazioni

- I byte dell'EXE non includono le DLL del sistema operativo, che sono usate da wxWidgets.
- Anche usando wxWidgets statico, possono restare dipendenze dinamiche MSVC o Windows.
- Il tempo compilazione comprende una prima compilazione hxcpp e varia per cache e runner.
- I tempi di avvio misurati dalla CI non sono equivalenti a un benchmark locale e possono essere omessi se il runner non espone una finestra.
- Prima della prova, confrontare la dimensione del pacchetto con l'eseguibile CLI dell'esperimento 000 (stessa architettura).

## Prima misura reale (CI PR #4, 23 novembre 2026)

La prima compilazione Windows è riuscita e il processo ha mostrato una finestra:

| Metrica | Valore osservato |
|---|---:|
| EXE GUI | 13.419.008 byte (13,42 MB decimali) |
| ZIP distribuzione | 5.191.472 byte (5,19 MB) |
| DLL affiancate | 0 |
| Finestra osservata | sì |
| Avvio → finestra, runner CI | 334 ms |
| RAM working set, runner CI | 36.597.760 byte (~36,6 MB) |

[Prima build valida della PR #4](https://github.com/Spyryto/Haxe-Experiments/actions/runs/45172245483)

Queste misure non dimostrano automaticamente portabilità su installazioni Windows pulite: la prova manuale è ancora necessaria. Le successive build registrano anche la dimensione della baseline CLI, compilata nello stesso ambiente.

## Confronto con hxWidgets diretto

La [versione 003](../003-hxwidgets-direct/README.md) riproduce gli stessi componenti e interazioni senza il livello HaxeUI; la CI misura le dimensioni dei due EXE nello stesso runner Windows.
