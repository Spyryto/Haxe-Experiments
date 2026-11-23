# 000 – Baseline CLI

Prima misura: qual è il peso di un eseguibile Haxe/hxcpp **senza GUI**? Serve come controllo per non attribuire alla GUI tutto il peso del runtime.

- Build Windows: `haxe experiments/000-cli/native.hxml` dopo aver installato `hxcpp` e la toolchain C++.
- Build Node (smoke test): `haxe experiments/000-cli/node.hxml`, poi `node build/cli.js`.
- L'artefatto CI include `Main.exe` e `measurements.txt` con le dimensioni reali della build.

Non chiamiamo automaticamente "portable" un file se non è stato provato su Windows pulito. Non confrontiamo i tempi di build cold-cache con i tempi a cache calda.
