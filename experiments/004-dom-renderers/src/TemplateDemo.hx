package;
import js.Browser;
import js.html.*;

class TemplateDemo {
  public final root:DivElement;
  final template:TemplateSlots;
  final metrics:ParagraphElement;
  var count = 0;
  var disabled = false;

  public function new() {
    root = Browser.document.createDivElement();
    template = new TemplateSlots();
    metrics = Browser.document.createParagraphElement();
    root.appendChild(template.root);
    root.appendChild(metrics);
    final change = Browser.document.createButtonElement();
    change.textContent = "Cambia testo";
    change.onclick = _ -> { count++; refresh(); };
    root.appendChild(change);
    final toggle = Browser.document.createButtonElement();
    toggle.textContent = "Abilita/disabilita";
    toggle.onclick = _ -> { disabled = !disabled; refresh(); };
    root.appendChild(toggle);
    final noop = Browser.document.createButtonElement();
    noop.textContent = "Aggiorna senza cambiamenti";
    noop.onclick = _ -> refresh();
    root.appendChild(noop);
    refresh();
  }

  function refresh():Void {
    template.update('Versione $count', disabled, () -> {
      count++;
      refresh();
    });
    metrics.textContent = 'Scritture testo: ${template.textWrites}; proprietà disabled: ${template.attributeWrites}';
  }
}
