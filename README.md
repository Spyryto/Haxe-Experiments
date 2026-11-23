# Haxe Experiments

Un laboratorio pubblico di piccoli programmi Haxe: **sorgenti**, **demo web**, **build native** e **misure riproducibili**.

## Esperimenti

| # | Esperimento | Tecnologia | Risultato |
|---|-------------|------------|-----------|
| 000 | Baseline CLI | Haxe → hxcpp | Eseguibile Windows + dimensione in CI |
| 001 | HaxeUI web | `haxeui-html5` | Demo JavaScript interattiva, provata su Safari iPhone |
| 002 | HaxeUI Windows | `haxeui-hxwidgets` + hxcpp | Stesso sorgente di 001, EXE nativo Windows e misure CI |

**Demo web:** https://spyryto.github.io/Haxe-Experiments/

**Build:** [GitHub Actions](https://github.com/Spyryto/Haxe-Experiments/actions), dove scaricare gli artefatti prodotti dalla CI.

> La demo web usa realmente HaxeUI compilato in JavaScript. Il sito catalogo usa HTML/CSS; la sua UI non è un benchmark HaxeUI.
> L'EXE wxWidgets ha superato la compilazione e un avvio automatico con finestra osservata in CI; resta da verificare su un Windows dell'utente.
> I tempi di compilazione in CI dipendono anche dalla rete e dal runner: non sono benchmark di runtime.

## Compilazione locale

Haxe 4.3.7:

```sh
# Esperimento web HaxeUI
haxelib install haxeui-core 1.7.0
haxelib install haxeui-html5 1.7.0
haxe experiments/001-haxeui/html5.hxml

# Baseline CLI (servono hxcpp e toolchain C++)
haxelib install hxcpp
haxe experiments/000-cli/native.hxml
```

Apri `site/experiments/001-haxeui/index.html`.

Per provare la versione desktop wxWidgets, leggi [l'esperimento 002](experiments/002-haxeui-wxwidgets/README.md), poi scarica il programma da [Native wxWidgets — Actions](https://github.com/Spyryto/Haxe-Experiments/actions/workflows/native-wxwidgets.yml).

## CI e pubblicazione

- `validate.yml`: compila la demo HaxeUI per browser, esegue un test CLI su Node, compila la baseline C++ su Windows e carica un artefatto ZIP con l'eseguibile.
- `native-wxwidgets.yml`: compila la GUI Windows in hxcpp con wxWidgets statico, osserva l'avvio e pubblica EXE e misure.
- `pages.yml`: pubblica la directory `site/` su GitHub Pages dopo una build riuscita su `main`.
- Se GitHub Pages non è già configurato: **Settings → Pages → Build and deployment → Source: GitHub Actions**. Potrebbe essere necessaria questa impostazione iniziale.

## Principi

Un esperimento = una domanda verificabile. Preferiamo codice essenziale, dipendenze dichiarate, build riproducibili, confronti su stessi requisiti, niente risultati inventati. I numeri verranno riportati solo se misurati e accompagnati dalla piattaforma.
