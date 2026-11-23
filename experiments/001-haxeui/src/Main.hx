import haxe.ui.HaxeUIApp;
import haxe.ui.containers.VBox;
import haxe.ui.containers.HBox;
import haxe.ui.components.Label;
import haxe.ui.components.Button;
import haxe.ui.components.TextField;
import haxe.ui.components.Progress;

class Main {
    static function main():Void {
        var app = new HaxeUIApp();
        app.ready(function() {
            var root = new VBox();
            root.width = 430;
            root.styleString = "padding: 18px;spacing: 10px;";

            var heading = new Label();
            heading.text = "HaxeUI · esperimento 001";
            heading.styleString = "font-size: 22px;";
            root.addComponent(heading);

            var intro = new Label();
            intro.text = "Stesso sorgente Haxe, backend intercambiabili.";
            root.addComponent(intro);

            var label = new Label();
            label.text = "Nome della versione (simulazione):";
            root.addComponent(label);

            var version = new TextField();
            version.text = "PHP 8.4";
            version.width = 260;
            root.addComponent(version);

            var progress = new Progress();
            progress.pos = 0;
            progress.width = 310;
            root.addComponent(progress);

            var status = new Label();
            status.text = "Pronto: nessun download reale.";
            root.addComponent(status);

            var buttons = new HBox();
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
