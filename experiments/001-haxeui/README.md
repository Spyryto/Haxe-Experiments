# 001 – HaxeUI / HTML5 e wxWidgets

**Domanda:** quanto cambia, mantenendo **esattamente lo stesso sorgente Haxe**, passare da una GUI browser (DOM) a una nativa wxWidgets?

Il codice in `src/Main.hx` usa `HaxeUIApp`, una casella di testo, una barra di avanzamento e pulsanti funzionanti. Il progresso è *simulato*: nessuna versione PHP viene scaricata.

## Browser – compilato in CI

```sh
haxelib install haxeui-core 1.7.0
haxelib install haxeui-html5 1.7.0
haxe experiments/001-haxeui/html5.hxml
```

Apri `site/experiments/001-haxeui/index.html`. Il JavaScript della GUI è generato da Haxe; il catalogo circostante è semplice HTML/CSS.

## Desktop nativo – fase successiva

Il file `hxwidgets.hxml` usa **lo stesso Main.hx** e compila verso C++ via hxcpp, con wxWidgets e il binding hxWidgets. È intenzionalmente *predisposto ma non ancora convalidato*. Per compilarlo servono una toolchain C++, `wxWidgets`, la variabile d'ambiente e le librerie:

```sh
haxelib install hxcpp
haxelib install hxWidgets
haxelib install haxeui-core 1.7.0
haxelib install haxeui-hxwidgets 1.7.0
haxe experiments/001-haxeui/hxwidgets.hxml
```

Su Windows il progetto hxWidgets richiede la configurazione wxWidgets tramite `WXWIN` e una build MSVC. Le istruzioni ufficiali sono in [HaxeUI/hxWidgets](https://github.com/haxeui/hxWidgets). Non pubblicare come funzionante una build non ancora verificata.

## Misure da raccogliere

Dimensione ZIP ed EXE, numero di DLL distribuite, dipendenze di runtime, RAM a riposo, avvio a freddo, reattività e tempo di build **con e senza cache**. Non inferire questi numeri dalla dimensione del sorgente.
