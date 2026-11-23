package;
import js.Browser;
import js.html.*;

class Main {
  static function main():Void {
    final host = Browser.document.getElementById("app");
    final a = new ImbaStyle();
    final b = new HyperStyle();
    var count = 0;

    final metrics = Browser.document.createParagraphElement();
    final info = Browser.document.createParagraphElement();
    info.textContent = "Entrambi conservano gli stessi nodi DOM tra un aggiornamento e l'altro.";

    host.appendChild(info);
    host.appendChild(a.root);
    host.appendChild(b.root);
    host.appendChild(metrics);

    function update():Void {
      a.render(count);
      b.update(['Contatore: $count']);
      metrics.textContent = 'Valore: $count | Scritture Imba-style: ${a.writes} | Scritture hyper-style: ${b.writes}';
    }
    function increment():Void { count++; update(); }
    a.onClick(increment);
    b.onClick(increment);
    update();

    final same = Browser.document.createButtonElement();
    same.textContent = "Render senza modifica";
    same.onclick = _ -> update();
    host.appendChild(same);

    final burst = Browser.document.createButtonElement();
    burst.textContent = "1000 aggiornamenti";
    burst.onclick = _ -> {
      final start = js.lib.Performance.now();
      for (i in 0...1000) { count++; update(); }
      final elapsed = js.lib.Performance.now() - start;
      metrics.textContent += ' | 1000 update: ' + Math.round(elapsed * 100) / 100 + ' ms (include UI metriche)';
    };
    host.appendChild(burst);
  }
}
