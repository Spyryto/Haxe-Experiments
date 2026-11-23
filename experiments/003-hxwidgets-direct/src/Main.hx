import hx.widgets.*;
import hx.widgets.styles.*;

/**
 * Esperimento 003: stessi controlli/funzioni dell'esperimento 002,
 * ma con i wrapper hxWidgets diretti, senza HaxeUI.
 *
 * Non include logica di download/installazione PHP.
 */
class Main {
    static function main():Void {
        var app = new App();
        app.init();

        var frame = new Frame(null, "hxWidgets diretto - esperimento 003");
        frame.resize(460, 410);
        var panel = new Panel(frame);

        frame.sizer = new BoxSizer(Orientation.VERTICAL);
        frame.sizer.add(panel, 1, Stretch.EXPAND);

        var layout = new BoxSizer(Orientation.VERTICAL);
        panel.sizer = layout;
        layout.addSpacer(12);

        var heading = new StaticText(panel, "HaxeUI · esperimento 001");
        layout.add(heading, 0, Stretch.EXPAND | Direction.LEFT | Direction.RIGHT, 14);
        layout.addSpacer(12);

        var intro = new StaticText(panel, "Stessa funzionalità, senza il livello HaxeUI.");
        layout.add(intro, 0, Stretch.EXPAND | Direction.LEFT | Direction.RIGHT, 14);
        layout.addSpacer(12);

        var description = new StaticText(panel, "Nome della versione (simulazione):");
        layout.add(description, 0, Stretch.EXPAND | Direction.LEFT | Direction.RIGHT, 14);
        layout.addSpacer(6);

        var version = new TextCtrl(panel, "PHP 8.4");
        layout.add(version, 0, Stretch.EXPAND | Direction.LEFT | Direction.RIGHT, 14);
        layout.addSpacer(14);

        var progress = new Gauge(panel, 100);
        progress.value = 0;
        layout.add(progress, 0, Stretch.EXPAND | Direction.LEFT | Direction.RIGHT, 14);
        layout.addSpacer(14);

        var status = new StaticText(panel, "Pronto: nessun download reale.");
        layout.add(status, 0, Stretch.EXPAND | Direction.LEFT | Direction.RIGHT, 14);
        layout.addSpacer(12);

        var advance = new Button(panel, "Simula progresso +20%");
        advance.bind(EventType.BUTTON, function(e:Event) {
            var next = progress.value + 20;
            if (next > 100) next = 0;
            progress.value = next;
            status.label = version.value + " · " + Std.string(next) + "% (solo simulazione)";
        });
        layout.add(advance, 0, Stretch.EXPAND | Direction.LEFT | Direction.RIGHT, 14);
        layout.addSpacer(8);

        var reset = new Button(panel, "Azzera");
        reset.bind(EventType.BUTTON, function(e:Event) {
            progress.value = 0;
            status.label = "Pronto: nessun download reale.";
        });
        layout.add(reset, 0, Stretch.EXPAND | Direction.LEFT | Direction.RIGHT, 14);

        frame.layout();
        frame.center();
        frame.show();

        app.run();
        app.exit();
    }
}
