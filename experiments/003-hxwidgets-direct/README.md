# Esperimento 003 — hxWidgets diretto vs HaxeUI

**Domanda:** quanto spazio, tempo di avvio e memoria risparmiamo eliminando **HaxeUI** ma utilizzando gli stessi controlli nativi **wxWidgets**?

L'esperimento 003 riproduce il comportamento di [002 — HaxeUI con wxWidgets](../002-haxeui-wxwidgets/README.md): campo "PHP 8.4", barra da 0 a 100%, pulsanti "+20%" e "Azzera", stato testuale. **Non utilizza lo stesso sorgente**, perché il codice GUI deve essere riscritto usando i wrapper diretti `hx.widgets.*`. Non effettua alcun download PHP.

## Build CI

Il workflow [Native wxWidgets](../../.github/workflows/native-wxwidgets.yml) compila e misura **tre programmi nello stesso runner Windows x64**: baseline CLI 000, GUI HaxeUI 002 e GUI hxWidgets diretto 003.

- Haxe 4.3.7, hxcpp 4.3.2, hxWidgets 1.12.0, wxWidgets 3.1.3 compilato staticamente con MSVC /MD.
- Artefatto 003: `hxwidgets-direct-windows-x64`, comprendente `hxWidgets-Direct.exe`, `measurements.json` e `dependencies.txt`.
- Le misure riportano byte dell'EXE e del pacchetto, DLL affiancate, dipendenze con `dumpbin`, presenza della finestra, tempo CI fino al primo handle finestra, memoria working set dopo circa due secondi.
- Il rapporto HaxeUI/diretto misura l'**overhead osservato di una build completa**: non separa perfettamente l'astrazione HaxeUI da differenze di codice, dead-code elimination o linking.
- L'avvio su runner è un controllo automatico, non una prova visiva o una misura attendibile delle prestazioni sul PC dell'utente.

Apri [Actions — Native wxWidgets](https://github.com/Spyryto/Haxe-Experiments/actions/workflows/native-wxwidgets.yml), scarica entrambi gli archivi, estraili in cartelle diverse e apri i due EXE. Non serve installare Haxe per provarli. I build artifact scadono.

## Build locale

Installa Haxe, hxcpp, hxWidgets e wxWidgets 3.1.3 (con `WXWIN` e toolchain MSVC x64 configurati), poi dal root del repository:

```powershell
haxe experiments/003-hxwidgets-direct/native-windows.hxml
```

Il risultato viene generato in `build/hxwidgets-direct`.

## Limiti importanti

L'EXE statico può ancora dipendere dalle librerie di sistema Windows e dal runtime VC++. La prova su una macchina Windows senza ambiente di sviluppo rimane necessaria. wxWidgets 3.1.3 è una versione storica scelta per riprodurre la configurazione upstream, non una raccomandazione per nuovi prodotti di distribuzione.
