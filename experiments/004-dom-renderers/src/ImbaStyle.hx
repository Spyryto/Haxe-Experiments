package;
import js.Browser;
import js.html.*;

class ImbaStyle {
  public final root:DivElement;
  final label:SpanElement;
  final button:ButtonElement;
  var previous = -1;
  public var writes(default, null) = 0;

  public function new() {
    root = Browser.document.createDivElement();
    label = Browser.document.createSpanElement();
    button = Browser.document.createButtonElement();
    button.textContent = "Incrementa";
    root.appendChild(label);
    root.appendChild(button);
  }

  public function render(count:Int):Void {
    if (count != previous) {
      label.textContent = 'Contatore: $count';
      previous = count;
      writes++;
    }
  }

  public function onClick(f:Void->Void):Void {
    button.onclick = _ -> f();
  }
}
