package;
import js.Browser;
import js.html.*;

/**
 * Small hyperHTML-inspired template instance.
 * Static nodes are cloned once per instance; dynamic slots retain references.
 * This is NOT a full hyperHTML port (no parsing of arbitrary HTML template strings).
 */
class TemplateSlots {
  public final root:DivElement;
  final textNode:Text;
  final action:ButtonElement;
  var lastText:String = null;
  var lastDisabled:Null<Bool> = null;
  public var textWrites(default, null) = 0;
  public var attributeWrites(default, null) = 0;

  public function new() {
    root = Browser.document.createDivElement();
    final paragraph = Browser.document.createParagraphElement();
    paragraph.appendChild(Browser.document.createTextNode("Messaggio: "));
    textNode = Browser.document.createTextNode("");
    paragraph.appendChild(textNode);
    action = Browser.document.createButtonElement();
    action.textContent = "Azione";
    root.appendChild(paragraph);
    root.appendChild(action);
  }

  public function update(message:String, disabled:Bool, handler:Void->Void):Void {
    if (lastText != message) {
      textNode.data = message;
      lastText = message;
      textWrites++;
    }
    if (lastDisabled != disabled) {
      action.disabled = disabled;
      lastDisabled = disabled;
      attributeWrites++;
    }
    // Event binding is replaced; the listener is not accumulated.
    action.onclick = _ -> handler();
  }
}
