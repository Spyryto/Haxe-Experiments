package;
import js.Browser;
import js.html.*;

class HyperStyle {
  public final root:DivElement;
  final label:SpanElement;
  final button:ButtonElement;
  var previous:String = null;
  public var writes(default, null) = 0;

  public function new() {
    // Analogo minimale a un template persistente con uno slot dinamico.
    root = Browser.document.createDivElement();
    label = Browser.document.createSpanElement();
    button = Browser.document.createButtonElement();
    button.textContent = "Incrementa";
    root.appendChild(label);
    root.appendChild(button);
  }

  public function update(values:Array<String>):Void {
    // Un template statico e un solo placeholder; nessun Virtual DOM.
    final next = values[0];
    if (next != previous) {
      label.textContent = next;
      previous = next;
      writes++;
    }
  }

  public function onClick(f:Void->Void):Void {
    button.onclick = _ -> f();
  }
}
