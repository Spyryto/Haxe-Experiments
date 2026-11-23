# Haxe Experiments

Un laboratorio pubblico di piccoli programmi Haxe: **sorgenti**, **demo web**, **build native** e **misure riproducibili**.

## Esperimenti

| # | Esperimento | Tecnologia | Risultato |
|---|-------------|------------|-----------|
| 000 | Baseline CLI | Haxe → hxcpp | Eseguibile Windows + dimensione in CI |
| 001 | HaxeUI: stesso codice, due backend | `haxeui-html5` / `haxeui-hxwidgets` | Demo web automatica; versione wxWidgets predisposta per le successive prove native |

**Demo web (dopo il deploy Pages):** https://spyryto.github.io/Haxe-Experiments/

**Build:** [GitHub Actions](https://github.com/Spyryto/Haxe-Experiments/actions), dove scaricare gli artefatti prodotti dalla CI.

> La demo web usa realmente HaxeUI compilato in JavaScript. Il sito catalogo usa HTML/CSS; la sua UI non è un benchmark HaxeUI.
> La versione desktop wxWidgets è un candidato di prova, NON ancora una build Windows verificata.
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

Per provare la versione desktop wxWidgets, leggi [le istruzioni dell'esperimento 001](experiments/001-haxeui/README.md).

## CI e pubblicazione

- `validate.yml`: compila la demo HaxeUI per browser, esegue un test CLI su Node, compila la baseline C++ su Windows e carica un artefatto ZIP con l'eseguibile.
- `pages.yml`: pubblica la directory `site/` su GitHub Pages dopo una build riuscita su `main`.
- Se GitHub Pages non è già configurato: **Settings → Pages → Build and deployment → Source: GitHub Actions**. Potrebbe essere necessaria questa impostazione iniziale.

## Principi

Un esperimento = una domanda verificabile. Preferiamo codice essenziale, dipendenze dichiarate, build riproducibili, confronti su stessi requisiti, niente risultati inventati. I numeri verranno riportati solo se misurati e accompagnati dalla piattaforma.
