# 004 — Banana, gorilla e giungla

Confronto controllato di tre modi di esprimere la **stessa computazione** in Haxe:
ereditarietà OOP, composizione OOP e funzioni pure (FP).

Ogni variante esegue 10.000 chiamate a `banana(x) = 3*x + 7` per `x = i % 97`, e deve produrre `checksum=1508812`. Le prime due versioni allocano oggetti: la terza usa funzioni statiche e non è quindi un benchmark di performance a parità di allocazioni. Il nostro obiettivo primario è la **dimensione del codice**, non stabilire quale paradigma sia più veloce.

In ogni variante esiste anche `gorilla()`: un metodo **non utilizzato** che fa riferimento alla classe `Jungle`. La classe contiene una stringa sintetica di circa 10 KB: identica per tutte le varianti. È una sonda intenzionale della raggiungibilità, non una dipendenza di produzione.

### Matrice delle compilazioni

| Modalità | Haxe DCE | Chiamata a gorilla raggiungibile |
|---|---|---|
| `full` | `-dce full` | No |
| `no` | `-dce no` | No |
| `kept` | `-dce full -D keep_gorilla` | Sì: solo quando l'app viene lanciata con `--gorilla` |

La CI misura **9 JavaScript** (3 paradigmi × 3 modalità) e **7 eseguibili Windows hxcpp** (3× full/no, più ereditarietà + kept). Verifica sempre l'output corretto; riporta la presenza effettiva della sentinella nella JS generata senza presupporla.

I risultati attesi sono **ipotesi**: DCE dovrebbe poter rimuovere i rami non raggiungibili, e l'ereditarietà potrebbe mantenere più infrastruttura in alcuni target. Le misure, non la teoria, decideranno. Non confondere la dimensione dell'EXE con quella del codice sorgente o con gli oggetti temporanei.

Questo esperimento confronta uno scenario volutamente ridotto: la presenza di metaprogrammazione, riflessione, plugin dinamici, classi usate tramite stringhe o `@:keep` cambierebbe radicalmente la raggiungibilità.

[Workflow e artefatti](../../.github/workflows/code-anatomy.yml) · [Codici delle tre varianti](.)
