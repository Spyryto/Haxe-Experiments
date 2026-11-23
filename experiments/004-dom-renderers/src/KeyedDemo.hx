package;
import js.Browser;
import js.html.*;

class KeyedDemo {
  public final root:DivElement;
  final list:KeyedList;
  final metrics:ParagraphElement;
  var keys = ["A", "B", "C", "D"];

  public function new() {
    root = Browser.document.createDivElement();
    list = new KeyedList();
    metrics = Browser.document.createParagraphElement();
    root.appendChild(list.root);
    root.appendChild(metrics);
    final reverse = Browser.document.createButtonElement();
    reverse.textContent = "Inverti";
    reverse.onclick = _ -> {
      keys.reverse();
      refresh();
    };
    root.appendChild(reverse);
    final rotate = Browser.document.createButtonElement();
    rotate.textContent = "Ruota";
    rotate.onclick = _ -> {
      keys.push(keys.shift());
      refresh();
    };
    root.appendChild(rotate);
    final remove = Browser.document.createButtonElement();
    remove.textContent = "Rimuovi ultimo";
    remove.onclick = _ -> {
      if (keys.length > 0) keys.pop();
      refresh();
    };
    root.appendChild(remove);
    final reset = Browser.document.createButtonElement();
    reset.textContent = "Ripristina";
    reset.onclick = _ -> {
      keys = ["A", "B", "C", "D"];
      refresh();
    };
    root.appendChild(reset);
    refresh();
  }

  function refresh():Void {
    list.update(keys);
    metrics.textContent = 'Nodi creati: ${list.created}; inserimenti/spostamenti: ${list.moved}; rimossi: ${list.removed}';
  }
}
