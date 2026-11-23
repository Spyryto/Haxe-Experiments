# 004 — DOM renderers: Imba, hyperHTML, Haxe

## Stato
**Fase 1: modelli didattici minimi, NON port completi.** Le due classi dimostrano il riutilizzo dei nodi e l'aggiornamento mirato; non implementano il compilatore Imba né l'API completa hyperHTML.

## Fonti
- Imba: https://github.com/imba/imba — compiler, tag tree e Memoized DOM.
- hyperHTML: https://github.com/WebReflection/hyperHTML — template, bind, wire, aggiornamenti.
- domdiff: https://github.com/WebReflection/domdiff — algoritmo di riconciliazione delle liste.

## Compilazione
```sh
haxe experiments/004-dom-renderers/build.hxml
```
Apri `site/experiments/004-dom-renderers/index.html`.

## Roadmap
1. Leggere e annotare i percorsi sorgente reali di Imba e hyperHTML; distinguere versioni e comportamento.
2. Port hyperHTML: template cache, slot testo/attributi/eventi, wire/bind, liste e keyed diff.
3. Port Imba: macro compile-time, tag tree memoizzato, aggiornamenti DOM mirati, controllo del lifecycle.
4. Rielaborazione Haxe: API idiomatica, macro facoltative, runtime minimo, interop JS/PHP remoting separato.
5. Test di correttezza con DOM identity, input focus, reorder keyed, cleanup, nested components.
6. Benchmark isolati: mount, update no-op, update text, liste e reorder, memoria, JS gzip; confronti con originali nelle stesse condizioni.

## Avvertenze
La demo misura il tempo di 1000 aggiornamenti **incluso** il rendering delle metriche; non è un benchmark comparativo. Le due classi sono volutamente quasi identiche per isolare il concetto dei nodi persistenti. Nessuna superiorità prestazionale è stata dimostrata.
