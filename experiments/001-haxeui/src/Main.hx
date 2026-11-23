import haxe.ui.HaxeUIApp;
import haxe.ui.Toolkit;
import haxe.ui.containers.VBox;
import haxe.ui.containers.HBox;
import haxe.ui.components.Label;
import haxe.ui.components.Button;
import haxe.ui.components.TextField;
import haxe.ui.components.HorizontalProgress;

class Main {
    static function main():Void {
        // On HTML5 mount HaxeUI in the actual demo element rather than in a nested iframe.
        #if js
        // Browsers already convert Retina physical pixels into CSS pixels.
        // HaxeUI autoScale uses physical DPI on HTML5 and would scale the GUI again.
        Toolkit.autoScale = false;
        var app = new HaxeUIApp({ container: js.Browser.document.getElementById("haxeui-host") });
        #else
        var app = new HaxeUIApp();
        #end
        app.ready(function() {
            var root = new VBox();
            #if js
            root.percentWidth = 100;
            #else
            root.width = 430;
            #end
            root.styleString = "padding: 14px;spacing: 10px;";

            var heading = new Label();
            heading.text = "HaxeUI · esperimento 001";
            heading.styleString = "font-size: 22px;";
            #if js
            heading.percentWidth = 100;
            heading.wordWrap = true;
            #end
            root.addComponent(heading);

            var intro = new Label();
            intro.text = "Stesso sorgente Haxe, backend intercambiabili.";
            #if js
            intro.percentWidth = 100;
            intro.wordWrap = true;
            #end
            root.addComponent(intro);

            var label = new Label();
            label.text = "Nome della versione (simulazione):";
            #if js
            label.percentWidth = 100;
            label.wordWrap = true;
            #end
            root.addComponent(label);

            var version = new TextField();
            version.text = "PHP 8.4";
            #if js
            version.percentWidth = 100;
            #else
            version.width = 260;
            #end
            root.addComponent(version);

            var progress = new HorizontalProgress();
            progress.pos = 0;
            #if js
            progress.percentWidth = 100;
            #else
            progress.width = 260;
            #end
            root.addComponent(progress);

            var status = new Label();
            status.text = "Pronto: nessun download reale.";
            #if js
            status.percentWidth = 100;
            status.wordWrap = true;
            #end
            root.addComponent(status);

            var buttons = new VBox();
            buttons.styleString = "spacing: 8px;";

            var advance = new Button();
            advance.text = "Simula progresso +20%";
            advance.onClick = function(_) {
                var next = progress.pos + 20;
                if (next > 100) next = 0;
                progress.pos = next;
                status.text = version.text + " · " + Std.string(next) + "% (solo simulazione)";
            };
            buttons.addComponent(advance);

            var reset = new Button();
            reset.text = "Azzera";
            reset.onClick = function(_) {
                progress.pos = 0;
                status.text = "Pronto: nessun download reale.";
            };
            buttons.addComponent(reset);

            root.addComponent(buttons);
            app.addComponent(root);
            app.start();
        });
    }
}
