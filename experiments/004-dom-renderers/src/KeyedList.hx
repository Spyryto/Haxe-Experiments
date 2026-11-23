package;
import js.Browser;
import js.html.*;

class KeyedList {
  public final root:UListElement;
  final nodes:Map<String, LIElement> = new Map();
  public var created(default, null) = 0;
  public var moved(default, null) = 0;
  public var removed(default, null) = 0;

  public function new() {
    root = Browser.document.createUListElement();
  }

  public function update(keys:Array<String>):Void {
    // A deliberately simple right-to-left keyed reconciler.
    // The same LI object is retained when a key moves.
    final desired:Map<String, Bool> = new Map();
    for (key in keys) {
      if (desired.exists(key)) throw 'Duplicate key: $key';
      desired.set(key, true);
    }
    for (key in nodes.keys()) {
      if (!desired.exists(key)) {
        final old = nodes.get(key);
        root.removeChild(old);
        nodes.remove(key);
        removed++;
      }
    }
    var next:Node = null;
    var i = keys.length;
    while (i > 0) {
      i--;
      final key = keys[i];
      var item = nodes.get(key);
      if (item == null) {
        item = Browser.document.createLIElement();
        item.textContent = key;
        nodes.set(key, item);
        created++;
      }
      if (item.parentNode != root || item.nextSibling != next) {
        root.insertBefore(item, next);
        moved++;
      }
      next = item;
    }
  }

  public function identity(key:String):LIElement {
    return nodes.get(key);
  }
}
